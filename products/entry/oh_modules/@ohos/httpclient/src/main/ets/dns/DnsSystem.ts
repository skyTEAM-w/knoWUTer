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

import connection from '@ohos.net.connection';
import { Dns } from '../Dns';

export class DnsSystem implements Dns {
    async lookup(hostname: string): Promise<Array<connection.NetAddress>> {
        return await new Promise((resolve, reject) => {
            connection.getAddressesByName(hostname).then(function (netAddress) {
                resolve(netAddress)
            }).catch(err => {
                resolve(err)
            });
        })
    }
}