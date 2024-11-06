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

import { Route } from './Route';
import { Address } from '../Address';
import connection from '@ohos.net.connection';
import { Dns } from '../Dns';
import { Proxy, Type } from './Proxy';
import List from '@ohos.util.List';
import { DnsSystem } from '../dns/DnsSystem';
import { Utils } from '../utils/Utils';
import { Chain } from '../Interceptor';

export class RouteSelector {
    netAddresses = new List<Route>()
    nextRouteIndex: number = 0
    dns: Dns
    proxies = new List<Proxy>()
    nextProxyIndex:number = 0
    address:Address
    postponedRoutes = new List<Route>();
    inetSocketAddresses = new List<Address>();
    chain: Chain;

    constructor(dns: Dns,chain: Chain,proxy?:Proxy,add?:Address) {
        this.dns = dns
        this.address = add
        this.chain = chain
        this.resetNextProxy(proxy);
    }

    hasNext():Boolean {
        return this.hasNextProxy() || !this.postponedRoutes.isEmpty()
    }

    async next():Promise<Selection>{
        if(!this.hasNext) throw Error('no such element')
        let routs = new List<Route>();
        while (this.hasNextProxy) {
            let proxy = await this.nextProxy()
            this.inetSocketAddresses.forEach(address => {
                let route = new Route(address,proxy);
                routs.add(route)
            });
            if(!routs.isEmpty()) {
                break
            }
        }
        if(routs.isEmpty()) {
            this.postponedRoutes.forEach(element => {
                routs.add(element)
            });
            this.postponedRoutes.clear()
        }
        this.netAddresses.clear()
        this.inetSocketAddresses.clear()
        return new Selection(routs);
    }

    async nextProxy():Promise<Proxy> {
        if(!this.hasNextProxy) {
            throw Error(`No route to exhausted proxy configurations: $proxies`)
        }
        let result = this.proxies[this.nextProxyIndex++]
        await this.resetNextInetSocketAddress(result)
        return result
    }

    async resetNextInetSocketAddress(proxy:Proxy) {
        let mutableInetSocketAddresses = new List<Address>();
        this.inetSocketAddresses = mutableInetSocketAddresses
        let socketHost: string
        let socketPort: number
        if (proxy.type === Type.DIRECT || proxy.type === Type.SOCKS) {
            socketHost = this.address.uriHost
            socketPort = this.address.uriPort
        } else {
            socketHost = proxy.host
            socketPort = proxy.port
        }
        if(proxy.type === Type.SOCKS) {
            let isIPv6 = Utils.isIPv6(socketHost)
            let address = new Address(socketHost,socketPort,isIPv6 ? 2 : 1)
            mutableInetSocketAddresses.add(address)
        } else {
            if(!!!this.dns) {
                this.dns = new DnsSystem()
            }
            let isIPv6 = Utils.isIPv6(socketHost)
            const userRequest = this.chain.requestI()
            if (!!userRequest.client && !!userRequest.client.eventListeners) {
                userRequest.client.eventListeners.dnsStart(this.chain.callI(), socketHost);
            }
            let addressArray = await this.dns.lookup(socketHost);
            for (var i = 0;i < addressArray.length; i++) {
                let address = new Address(addressArray[i].address,socketPort,isIPv6 ? 2 : 1)
                mutableInetSocketAddresses.add(address)
            }
            if (!!userRequest.client && !!userRequest.client.eventListeners) {
                userRequest.client.eventListeners.dnsEnd(this.chain.callI(), socketHost, mutableInetSocketAddresses);
            }
        }
    }

    resetNextProxy(proxy:Proxy) {
        this.proxies = this.selectProxies(proxy)
        this.nextProxyIndex = 0
    }

    selectProxies(proxy: Proxy):List<Proxy> {
        let list = new List<Proxy>()
        if(proxy != null) {
            list.add(proxy)
        } else {
            let NO_PROXY = new Proxy(Type.DIRECT,null,null);
            list.add(NO_PROXY)
        }
        return list;
    }

    hasNextRoute(): boolean {
        return this.nextRouteIndex < this.netAddresses.length
    }

    hasNextProxy():Boolean{
        return this.nextProxyIndex < this.proxies.length
    }

}

export class Selection{
    routes: List<Route>
    nextRouteIndex: number = 0

    constructor(routes: List<Route>) {
        this.routes = routes
    }

    hasNextRoute(): boolean {
        return this.nextRouteIndex < this.routes.length
    }

    next(): Route {
        if (!!this.routes) {
            let result = this.routes[this.nextRouteIndex++]
            return result
        }
    }
}

