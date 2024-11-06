/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import HttpCall from '../HttpCall';
import { X509TrustManager } from '../tls/X509TrustManager';
import { CertificatePinner } from '../CertificatePinner';
import { Logger } from '../utils/Logger';

export class Dispatcher {

    // The maximum number of requests to execute concurrently
    private maxRequests = 64;

    // The maximum number of requests for each host to execute concurrently
    private maxRequestsPerHost = 5;

    // Running synchronous calls. Includes canceled calls that haven't finished yet
    private runningSyncCalls = Array<HttpCall>();

    // Ready async calls in the order they'll be run
    private readyAsyncCalls = Array<HttpCall>();

    // Running asynchronous calls. Includes canceled calls that haven't finished yet
    private runningAsyncCalls = Array<HttpCall>();

    private certificateManager : X509TrustManager;

    private certificatePinner: CertificatePinner;

    /**
     * 设置运行队列的最大请求数
     * @param max
     */
    async setMaxRequestCount(max: number) {
        this.maxRequests = max;
        this.promoteAndExecute();
    }

    /**
     * 获取运行队列的最大请求数
     * @returns
     */
    getMaxRequestCount(): number {
        return this.maxRequests;
    }

    /**
     * 设置同host的最大并发请求数
     * @param max
     */
    async setMaxRequestPreHostCount(max: number) {
        this.maxRequestsPerHost = max;
        this.promoteAndExecute();
    }

    /**
     * 获取同host的最大请求数
     * @returns
     */
    getMaxRequestPreHostCount(): number {
        return this.maxRequests;
    }

    getFirstReadyCallPriority(): number {
        return this.readyAsyncCalls.length > 0 ? this.readyAsyncCalls[0].originalRequest.priority : 0;
    }

    executed(call: HttpCall) {
        this.runningSyncCalls.push(call);
    }

    enqueue(call: HttpCall) {
        this.certificateManager = call.certificateManager;
        this.certificatePinner = call.certificatePinner;
        // 如果运行中请求小于最大请求数并且同host请求数小于最大请求数则直接发起请求，否则放入等待队列中
        if (this.runningAsyncCalls.length < this.maxRequests && this.getSameHostCount(call) < this.maxRequestsPerHost) {
            this.runningAsyncCalls.push(call);
            call.executeOn();
        } else {
            // 如果有设置请求优先级，就按照优先级重新排序
            if (call.originalRequest.priority > 0) {
                this.sortReadyCalls(call);
            } else {
                this.readyAsyncCalls.push(call);
            }
        }
    }

    /**
     * Used by [execute/enqueue] to signal completion.
     */
    finished(call: HttpCall, isSyncCall: boolean) {
        this.finishedAll(isSyncCall ? this.runningSyncCalls : this.runningAsyncCalls, call);
    }

    private finishedAll<T>(calls: Array<T>, call: T) {
        // 异步任务执行队列移除当前请求任务
        if (!calls.splice(calls.indexOf(call))) throw Error("Call wasn't in-flight!");
        // 继续执行promoteAndExecute获取异步任务执行队列里面的任务数是否大于0
        // 大于0 ，还有任务需要执行，循环执行任务队列里面的任务
        if (this.readyAsyncCalls.length > 0) {
            this.promoteAndExecute();
        }
    }

    private promoteAndExecute(): boolean {
        Logger.info('Dispatcher promoteAndExecute readyAsyncCalls size =' + this.getReadyCallsCount());
        // 等待队列中没有请求就不再查询
        if (this.readyAsyncCalls.length <= 0) return;
        let executableCalls = Array<HttpCall>();
        let isRunning: boolean;
        let i = 0;
        // 循环查询等待队列
        while (this.readyAsyncCalls[i]) {
            // 判断异步任务执行队列里面的任务数是否超出允许的最大任务数64
            if (this.runningAsyncCalls.length >= this.maxRequests) break;
            let asyncCall = this.readyAsyncCalls[i];
            // 判断与等待队列取出的异步任务域名相同的请求并发数是否超过允许的单一host最大并发数5
            // 是的话跳出本次循环，继续下次循环
            if (this.getSameHostCount(asyncCall) >= this.maxRequestsPerHost) {
                i++;
                continue;
            }
            // 从异步任务等待队列里面移除取出的异步任务
            this.readyAsyncCalls.splice(this.readyAsyncCalls.indexOf(asyncCall), 1);
            // 将取出的异步任务添加到列表以及添加到任务管理器的异步任务执行队列
            executableCalls.push(asyncCall);
            // 将取出的异步任务添加到任务管理器的异步任务执行队列
            this.runningAsyncCalls.push(asyncCall);
        }

        isRunning = this.getRunningCallsCount() > 0;
        // 循环异步任务列表executableCalls
        for (let j = 0; j < executableCalls.length; j++) {
            let asyncCall = executableCalls[j];
            // 执行异步任务executeOn
            asyncCall.executeOn();
        }
        return isRunning;
    }

    /**
     * 获取运行队列中与当前请求同host的请求个数
     * @param call 当前请求
     * @returns  同host请求个数
     */
    private getSameHostCount(call: HttpCall): number {
        let result = 0;
        for (let i = 0; i < this.runningAsyncCalls.length; i++) {
            if (call.getHost() != null && call.getHost() === this.runningAsyncCalls[i].getHost()) {
                result++;
            }
        }
        return result;
    }

    /**
     * 获取当前等待队列中的请求数量
     * @returns 等待队列中的请求数量
     */
    getReadyCallsCount(): number {
        return this.readyAsyncCalls.length;
    }

    /**
     * 获取当前运行队列中的请求数量
     * @returns 运行队列中的请求数量
     */
    getRunningCallsCount(): number {
        return this.runningAsyncCalls.length + this.runningSyncCalls.length;
    }

    /**
     * 根据请求的优先级对等待队列进行排序
     * @param call 高优先级请求
     */
    private sortReadyCalls(call: HttpCall) {
        if (this.readyAsyncCalls.length == 0) {
            this.readyAsyncCalls.push(call);
            return;
        }
        for (let i = 0; i < this.readyAsyncCalls.length; i++) {
            if (i > this.readyAsyncCalls.length) {
                this.readyAsyncCalls.push(call);
                break;
            }
            if (call.originalRequest.priority >= this.readyAsyncCalls[i].originalRequest.priority) {
                Logger.info('Dispatcher sortReadyCalls readyAsyncCalls size = ' + this.getReadyCallsCount() +
                    ", priority insert index is " + i);
                this.readyAsyncCalls.splice(i, 0, call);
                break;
            }
        }
    }

    getRunningCalls():Array<HttpCall> {
        return this.runningAsyncCalls
    }

    getQueuedCalls() :Array<HttpCall>{
        return this.readyAsyncCalls
    }
}

export default Dispatcher;