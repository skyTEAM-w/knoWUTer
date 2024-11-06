/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import hilog from '@ohos.hilog'


export class Logger {
    private static debugSwitch: boolean = false;
    private static domain: number = 0x0001;
    private static tag: string = 'httpclient---';
    private static FORMAT: string = `%{public}s`;

  /**
   * set log switch method
   *
   * @param {boolean} debugSwitch - log switch
   */
    public static setDebugSwitch(debugSwitch: boolean) {
        this.debugSwitch = debugSwitch;
    }

    /**
     * get log switch method
     *
     * @returns debugSwitch value
     */
    public static getDebugSwitch(): boolean {
        return this.debugSwitch;
    }


    /**
     * set tag to distinguish log
     *
     * @param {string} log - Log needs to be printed
     */
    public static setTag(tagStr: string) {
        if (tagStr) {
            this.tag = tagStr;
        }
    }

    /**
     * set domain to distinguish log
     *
     * @param {string} log - Log needs to be printed
     */
    public static setDomain(domain: number) {
        this.domain = domain;
    }

    /**
     * print info level log
     *
     * @param {string} log - Log needs to be printed
     */
    public static info(...args: any) {
        if (this.debugSwitch) {
            hilog.info(this.domain, this.tag, this.FORMAT, args.join(` `));
        }
    }

    /**
     * print debug level log
     *
     * @param {string} log - Log needs to be printed
     */
    public static debug(...args) {
        if (this.debugSwitch) {
            hilog.debug(this.domain, this.tag, this.FORMAT, args.join(` `));
        }
    }

    /**
     * print error level log
     *
     * @param {string} log - Log needs to be printed
     */
    public static error(...args) {
        if (this.debugSwitch) {
            hilog.error(this.domain, this.tag, this.FORMAT, args.join(` `));
        }
    }

    /**
     * print warn level log
     *
     * @param {string} log - Log needs to be printed
     */
    public static warn(...args) {
        if (this.debugSwitch) {
            hilog.warn(this.domain, this.tag, this.FORMAT, args.join(` `));
        }
    }

    /**
     * print fatal level log
     *
     * @param {string} log - Log needs to be printed
     */
    public static fatal(...args) {
        if (this.debugSwitch) {
            hilog.fatal(this.domain, this.tag, this.FORMAT, args.join(` `));
        }
    }
}
