/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import HttpCall from './HttpCall';
import Request from './Request';
import { Response } from './response/Response';
import { IOException } from './eventListener/IOException';

export default class EventListener {

  /**
   * 在由客户端执行呼叫开始时立即调用。
   * */
  callStart(call: HttpCall): void { };

  /**
   * 在DNS查找之前调用，仅在添加的dns()时回调用
   * 能够重用现有的池化连接，测此方法不会被调用
   * */
  dnsStart(call: HttpCall, domainName: string): void { };

  /**
   * 在DNS查找之后立即调用，仅在添加的dns()时回调用
   * <p>此方法总是在{@link #dnsStart(调用)}之后调用
   * */
  dnsEnd(call: HttpCall, domainName: string, inetAddressList: []): void {};

  /**
   * 在建立连接开始时被调用。
   * */
  connectStart(call: HttpCall): void {};

  /**
   * 在安全连接开始时被调用。
   * */
  secureConnectStart(call: HttpCall): void {};

  /**
   * 在安全连接结束时被调用。
   * */
  secureConnectEnd(call: HttpCall): void {};

  /**
   * 在连接完成时被调用。
   * */
  connectEnd(call: HttpCall): void {};

  /**
   * 在连接失败时被调用。
   * */
  connectFailed(call: HttpCall): void {}

  /**
   * 在连接被获取时被调用。
   * */
  connectionAcquired(call: HttpCall): void {}

  /**
   * 在连接被释放时被调用。
   * */
  connectionReleased(call: HttpCall): void {}

  /**
   * 在发送请求头之前调用。
   * */
  requestHeadersStart(call: HttpCall): void {}

  /**
   * 发送请求头后立即调用。
   * <p>此方法总是在{@link #requestHeadersStart(调用)}之后调用
   * */
  requestHeadersEnd(call: HttpCall, request: Request): void {}

  /**
   * 在发送请求正文之前调用。
   * */
  requestBodyStart(call: HttpCall): void {}

  /**
   * 发送请求体后立即调用。
   * <p>此方法总是在{@link #requestBodyStart}之后调用
   * */
  requestBodyEnd(call: HttpCall, request: Request): void {}

  /**
   * 当请求写入失败时调用。
   * 请求失败不一定会导致整个调用失败
   * */
  requestFailed(call: HttpCall, ioe: IOException): void {}

  /**
   * 在接收响应头之前调用。
   * */
  responseHeadersStart(call: HttpCall): void {}

  /**
   * 接收到响应头后立即调用。
   * <p>此方法总是在{@link #responseHeadersStart}之后调用
   * */
  responseHeadersEnd(call: HttpCall, response: Response): void {}

  /**
   * 在接收响应体之前调用。
   * <p>对于单个{@link Call}通常只会调用1次
   * */
  responseBodyStart(call: HttpCall): void {}

  /**
   * 接收到响应体并完成读取后立即调用。
   * <p>此方法总是在{@link #responseBodyStart}之后调用
   * */
  responseBodyEnd(call: HttpCall, response: Response): void {}

  /**
   * 读取响应失败时调用。
   * <p>此方法总是在{@link #responseHeadersStart}或{@link #responseBodyStart}之后调用
   * 请注意，响应失败不一定会导致整个呼叫失败
   * */
  responseFailed(call: HttpCall, ioe: IOException): void {}

  /**
   * 在调用结束后立即调用。
   * <p>此方法总是在{@link #callStart(调用) }之后调用
   * */
  callEnd(call: HttpCall): void {}

  /**
   * 当调用永久失败时调用。
   * <p>此方法总是在{@link #callStart(调用) }之后调用
   * */
  callFailed(call: HttpCall, ioe: IOException): void {}
}

