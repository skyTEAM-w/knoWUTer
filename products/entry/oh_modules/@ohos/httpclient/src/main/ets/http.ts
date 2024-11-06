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
import socket from '@ohos.net.socket';
import Url from '@ohos.url'
import Request from './Request';
import buffer from '@ohos.buffer';
import { Logger } from './utils/Logger';
import ConstantManager from './ConstantManager'
import connection from '@ohos.net.connection';
import { Utils } from './utils/Utils';
import hilog from '@ohos.hilog';
import certFramework from '@ohos.security.cert';
import { X509TrustManager } from './tls/X509TrustManager';
import { CertificatePinner } from './CertificatePinner';
import { Proxy, Type } from './connection/Proxy';
import { Route } from './connection/Route';

export class Http {
    public static createHttp(): HttpRequest {
        let httpRequest = new HttpRequest();
        return httpRequest;
    }
}

export class HttpRequest {
    responseHeader = new Map();
    private port: string;
    private ALPNProtocols: Array<string> = ["spdy/1", "http/1.1"];
    private originUrl: string;
    private isFirstSegment: boolean = true;
    private response: HttpResponse;
    private contentLength: number;
    private gzipDataLength: number;
    private isContainChunked: boolean;
    private contentType: string;
    private responseData: string = "";
    private isHttps: boolean = true;
    private callback: AsyncCallback<HttpResponse>;
    private isClose: boolean = true;
    private isGzip: Boolean = false;
    private socketObject;
    private certificateManager:X509TrustManager;
    private certificatePinner:CertificatePinner;
    private secureOptions: socket.TLSSecureOptions = {
        ca: [],
        cert: '',
        key: '',
        password: '',
        protocols: [socket.Protocol.TLSv12],
        useRemoteCipherPrefer: true,
        signatureAlgorithms: '',
        cipherSuite: ''
    };

    constructor() {
        this.isClose = false
    }

    /**
     * Initiates an HTTP request to a given URL.
     *
     * @param url URL for initiating an HTTP request.
     * @param options Optional parameters {@link HttpRequestOptions}.
     * @param callback Returns {@link HttpResponse}.
     * @permission ohos.permission.INTERNET
     */
    public request(
        url: string,
        originUrl: string,
        request: Request,
        options: HttpRequestOptions,
        callback: AsyncCallback<HttpResponse>,
        certificateManager?: X509TrustManager,
        certificatePinner?: CertificatePinner
    ) {
        if (certificateManager) {
            this.certificateManager = certificateManager;
        }
        if (certificatePinner) {
            this.certificatePinner = certificatePinner;
        }
        Logger.info('http request--> url >>>>>> ' + url)
        this.originUrl = originUrl
        let urlObject = Url.URL.parseURL(url);
        let protocol = urlObject.protocol.toLowerCase()
        if (protocol == "http:") {
            this.isHttps = false
            this.socketObject = socket.constructTCPSocketInstance();
        }

        if (protocol == "https:") {
            this.isHttps = true
            this.socketObject = socket.constructTLSSocketInstance();
        }

        Logger.info('http request--> option >>>>>> ' + JSON.stringify(options))
        Logger.info('http request--> request >>>>>>  ' + JSON.stringify(request))
        this.callback = callback
        this.bind(() => {
            this.on("message", value => {
                let content = Utils.Utf8ArrayToStr(value.message)
                if (this.isFirstSegment) {
                    let arr: string[] = content.split("\r\n")
                    for (let i = 0; i < arr.length; i++) {
                        Logger.info('http request--> serve response >>>>>>  ' + JSON.stringify(arr[i]))
                        let header = arr[i].split(": ")
                        if (header[0] == "Content-Encoding") {
                            if (header[1] == "gzip") {
                                this.isGzip = true
                                this.gzipDataLength = 0
                            }
                            continue
                        }
                        if (header[0] == "Content-Type") {
                            let arrType = header[1].split("charset=")
                            if (arrType.length > 0) {
                                this.contentType = arrType[1]
                            }
                            continue
                        }
                        if (!!!this.isContainChunked && header[0] == "Transfer-Encoding" && header[1] == "chunked") {
                            this.isContainChunked = true
                            continue
                        }
                    }
                }

                this.isFirstSegment = false
                if (!!this.contentType && (this.contentType == "GB2312" || this.contentType == "GB18030" || this.contentType == "GBK")) {
                    content = Utils.strAnsi2Unicode(content)
                } else {
                    if (this.isGzip) {
                        let gzipData:string[] = Utils.getGzipBodyStrAndGzipLength(value.message)
                        this.gzipDataLength = this.gzipDataLength + Number.parseInt(gzipData[0])
                        content = gzipData[1]
                    } else {
                        content = buffer.from(value.message).toString('utf8')
                    }
                }
                this.dealSuccessResult(content)
            });

            this.on('error', err => {
                hilog.error(0x0001, 'http request-->on: error ', JSON.stringify(err))
                if (!this.isClose) {
                    this.dealFailResult(err.code, err.message, err.name)
                }
            });

            this.on('close', () => {
                Logger.info("http request-->on: close")
            });

            this.connect(url, originUrl, options, () => {
                if (this.certificateManager && !this.certificatePinner) {
                    this.verifyCertificate(url, request, options);
                } else if (this.certificatePinner && !this.certificateManager) {
                    let pinFlag = this.checkPin();
                    if (pinFlag) {
                        this.send(url, request, options);
                    }
                } else if (this.certificateManager || this.certificatePinner) {
                    let pinFlag = this.checkPin();
                    if (pinFlag) {
                        this.verifyCertificate(url, request, options);
                    }
                } else {
                    this.send(url, request, options);
                }
            })
        })
    }

    /**
     * 设置CA证书
     * @param caStr
     */
    public setCaData(caStr: string[]) {
        this.secureOptions.ca = caStr;
    }

    /**
     * 设置本地客户端的数字证书
     * @param caStr
     */
    public setCert(certStr: string) {
        this.secureOptions.cert = certStr;
    }

    /**
     * 设置本地数字证书的私钥
     * @param caStr
     */
    public setKey(keyStr: string) {
        this.secureOptions.key = keyStr;
    }

    /**
     * 设置本地数字证书的密码
     * @param caStr
     */
    public setPassword(passwordStr: string) {
        this.secureOptions.password = passwordStr;
    }


    /**
     * Destroys an HTTP request.
     */
    public destroy() {
        this.isClose = true;
        this.socketObject.close()
            .then(() => {
                Logger.info('http request--> socket is closed')
            }).catch(err => {
            hilog.error(0x0001, 'http request-->socket close fail ', JSON.stringify(err))
        })
    }

    public on(type: string, callback: Callback<any>) {
        switch (type) {
            case 'message':
                this.socketObject.on('message', (v) => {
                    callback(v)
                });
                break
            case 'connect':
                this.socketObject.on('connect', (v) => {
                    callback(null)
                });
                break
            case 'close':
                this.socketObject.on('close', (v) => {
                    callback(null)
                });
                break
            case 'error':
                this.socketObject.on('error', (v) => {
                    callback(v)
                });
                break
        }
    }

    public off(type: string, callback: Callback<Object>) {
        switch (type) {
            case 'message':
                this.socketObject.off('message', (v) => {
                    callback(v)
                });
                break
            case 'connect':
                this.socketObject.off('connect', (v) => {
                    callback(null)
                });
                break
            case 'close':
                this.socketObject.off('close', (v) => {
                    callback(null)
                });
                break
            case 'error':
                this.socketObject.off('error', (v) => {
                    callback(v)
                });
                break
        }
    }

    private parseHeaderAndBody(res: string) {
        let segmentData = ""
        if (!!!this.response.responseCode && !!!this.contentLength) {
            let arr: string[] = res.split("\r\n")
            let isStartReadData: boolean = false
            for (let i = 0; i < arr.length; i++) {
                if (!!!this.response.responseCode) {
                    let status = arr[0].split(' ')
                    this.response.responseCode = Number.parseInt(status[1])
                    continue
                }

                let header = arr[i].split(": ")
                if (!!!this.contentLength && header[0] == "Content-Length") {
                    this.contentLength = Number.parseInt(header[1])
                    continue
                }

                if (arr[i] == "") {
                    isStartReadData = true
                    continue
                }

                if (!!!isStartReadData) {
                    this.responseHeader.set(header[0], header[1])
                }

                if (isStartReadData) {
                    if (this.isContainChunked) {
                        // 过滤响应体分块的大小说明：十六进制数；防止部分场景加密内容正文会错误识别为分块的大小，通过限制长度大小{1,8}。
                        let blockSizeCharRegex = /^[0-9a-fA-F]{1,8}$/
                        if (!blockSizeCharRegex.test(arr[i])) {
                            segmentData += arr[i]
                        }
                    } else {
                        segmentData += arr[i]
                    }
                }
            }
        } else {
            segmentData = res
        }
        return segmentData
    }

    private dealSuccessResult(res: string) {
        if (this.callback) {
            if (!!!this.response) {
                this.response = new HttpResponse();
            }
            if (Logger.getDebugSwitch()) {
                // 计算总共可以分成多少段，每段3000个字符
                let segments = Math.ceil(res.length / 3000);
                for (let i = 0; i < segments; i++) {
                    // 计算每段的起始和结束索引
                    let start = i * 3000;
                    // 确保不会超出字符串长度
                    let end = Math.min(start + 3000, res.length);
                    // 使用substring方法打印每段
                    Logger.info(`http request--> serve res >>>>>>  ${res.substring(start, end)}`);
                }
                Logger.info('http request--> serve res.length >>>>>>  ' + res.length);
            }
            if (this.isContainChunked) {
                this.responseData += res;
                // 判断当前是否是结束符标识，0\r\n\r\n或者是\r\n0\r\n\r\n结尾的
                let resRegex = /(?<=\r\n)0\r\n\r\n$/;
                if (resRegex.test(res) || res === "0\r\n\r\n") {
                    this.response.result = this.parseHeaderAndBody(this.responseData);
                } else {
                    return;
                }
            } else {
                this.responseData += this.parseHeaderAndBody(res);
                let resultLength = 0;
                if (this.isGzip) {
                    resultLength = this.gzipDataLength;
                }else {
                    resultLength = Utils.strToArrayBuffer(this.responseData).byteLength;
                }
                if (resultLength < this.contentLength) {
                    return;
                }
                this.response.result = this.responseData;
            }

            this.response.header = Object.fromEntries(this.responseHeader.entries());
            this.callback(null, this.response);
        }
    }

    private dealFailResult(code: number, msg: string, name: string) {
        if (this.callback) {
            let errContent = {
                code: code,
                message: msg,
                name: name
            }
            Logger.error('http request--> fail：' + JSON.stringify(errContent))
            this.callback(errContent, null)
        }
    }

    private bind(callback) {
        let that = this;
        connection.getDefaultNet().then(function (netHandle) {
            connection.getConnectionProperties(netHandle, function (error, info) {
                if (!!!error) {
                    let ip = info.linkAddresses[0].address.address
                    that.socketObject.bind({ address: ip }, err => {
                        if (err) {
                            hilog.error(0x0001, 'http request-->', " bind socket fail " + JSON.stringify(err))
                            that.dealFailResult(err.code, 'bind fail', err.name)
                            return;
                        }
                        Logger.info('http request--> bind socket success')
                        callback()
                    })
                } else {
                    callback(JSON.stringify(error))
                }
            })
        })
    }

    private connect(url: string, originUrl:string, options: HttpRequestOptions, callback) {
        let urlObject = Url.URL.parseURL(url);
        let portObject = Url.URL.parseURL(originUrl);
        let host = urlObject.hostname
        let pathname = urlObject.pathname
        let search = urlObject.search
        let family = Utils.isIPv6(host) ? 2:1
        let protocol = urlObject.protocol.toLowerCase()
        if (protocol == "http:") {
            this.port = portObject.port || '80'
        } else if (protocol == "https:") {
            this.port = portObject.port || '443'
        } else {
            this.port = "-1"
        }
        let route = options.route
        if (route) {
            host = route.add.uriHost
            this.port = route.add.uriPort.toString()
            family = route.add.family
        }
        Logger.info(`http request--> connecting......    url:${url} , host:${host} , port:${this.port} , pathname=${pathname} , search=${search}`)
        let connectOptions = this.isHttps ? {
                                                ALPNProtocols: this.ALPNProtocols,
                                                address: { address: host, port: Number.parseInt(this.port), family: 1 },
                                                secureOptions: this.secureOptions,
                                            } : {
                                                    address: {
                                                        address: host,
                                                        port: Number.parseInt(this.port),
                                                        family: family
                                                    },
                                                    timeout: options.connectTimeout
                                                }
        this.socketObject.connect(connectOptions, (err) => {
            if (!err) {
                Logger.info('http request--> connect socket success')
                callback()
                return
            }
            hilog.error(0x0001, 'http request--> connect socket fail ', JSON.stringify(err))
            this.dealFailResult(err.code, 'connect fail', err.name)
        });
    }

    private async checkPin() {
        let serverCer: socket.X509CertRawData;
        try {
            serverCer = await this.socketObject.getRemoteCertificate();
            Logger.info("getRemoteCertificate callback success= " + serverCer);
        }
        catch (err) {
            Logger.info("getRemoteCertificate callback error = " + err);
            return false;
        }
        const res = await this.certificatePinner.check(serverCer);
        if (res) {
            Logger.error("getRemoteCertificate callback error = " + JSON.stringify(res));
            this.dealFailResult(666666, 'check certSHA fail', res);
            return false;
        } else {
            return true;
        }
    }

    private async verifyCertificate(url: string, request: Request, options: HttpRequestOptions) {
        let checkClientTrusted = true;
        let checkServerTrusted = true;
        let clientCer: socket.X509CertRawData;
        let serverCer: socket.X509CertRawData;
        let serverX509Cert;
        let clientX509Cert;

        checkServerTrusted = false;
        try {
            serverCer = await this.socketObject.getRemoteCertificate();
            Logger.info("getRemoteCertificate callback success= " + serverCer);
        }
        catch (err) {
            Logger.error("getRemoteCertificate callback error = " + err.code + ', errMsg: ' + err.message);
            this.dealFailResult(err.code, 'getRemoteCertificate failed', err.message)
            return;
        }
        try {
            serverX509Cert = await certFramework.createX509Cert(serverCer);
            Logger.info("create Remote X509Cert success=  " + serverX509Cert);
        } catch (err) {
            Logger.error('create Remote X509Cert failed, errCode: ' + err.code + ', errMsg: ' + err.message);
            this.dealFailResult(err.code, 'create Remote X509Cert failed', err.message);
            return;
        }
        try {
            this.certificateManager!.checkServerTrusted(serverX509Cert);
            checkServerTrusted = true;
        } catch (err) {
            Logger.error('http request-->check server certificate fail ', JSON.stringify(err));
            this.dealFailResult(err.code, 'check server certificate fail', err.message);
            return;
        }

        if (this.secureOptions.cert && this.secureOptions.key) {
            checkClientTrusted = false;
            try {
                clientCer = await this.socketObject.getCertificate();
                Logger.info("getCertificate callback success= " + clientCer);
            }
            catch (err) {
                Logger.error("getCertificate callback error = " + err.code + ', errMsg: ' + err.message);
                this.dealFailResult(err.code, 'getCertificate failed', err.message);
                return;
            }
            try {
                clientX509Cert = await certFramework.createX509Cert(clientCer);
                Logger.info("create client X509Cert success=  " + serverX509Cert);
            } catch (err) {
                Logger.error('create client X509Cert failed, errCode: ' + err.code + ', errMsg: ' + err.message);
                this.dealFailResult(err.code, 'create client X509Cert failed', err.message);
                return;
            }
            try {
                this.certificateManager!.checkClientTrusted(clientX509Cert);
                checkClientTrusted = true;
            } catch (err) {
                Logger.error('http request-->check client certificate fail ', JSON.stringify(err));
                this.dealFailResult(err.code, 'check client certificate fail', err.message);
                return;
            }
        }

        if (checkClientTrusted && checkServerTrusted) {
            this.send(url, request, options)
        }
    }

    /**
     *
     * Function: Splice the first three lines of the POST request message. The format is as follows:
     *
     * POST /user/requestParamPost HTTP/1.1
     * Host: 1.94.37.200:7070
     * Content-Type: application/x-www-form-urlencoded
     *
     *
     *
     * @param hostName
     * @param path
     * @returns String
     */
    private buildPostSendBody(path: string, hostName: Url.URL, contentTypeValue: string, connectionValue?: string): string {
        let result: string = "POST " + path + " HTTP/1.1\r\n";
        result += "Host: " + hostName.hostname + ":" + hostName.port + "\r\n";
        result += "Content-Type: " + (contentTypeValue ? contentTypeValue : "application/json") + "\r\n";
        result += "Connection: " + (connectionValue ? connectionValue : "keep-alive") + "\r\n";
        return result;
    }

    private send(url: string, request: Request, options: HttpRequestOptions) {
        let sendBody = ''
        let route = options.route
        if(!!!route) {
            let noProxy = new Proxy(Type.DIRECT,null,null);
            route = new Route(null,noProxy);
        }
        let urlObject = Url.URL.parseURL(url);
        let host = urlObject.hostname || ''
        let pathname = urlObject.pathname || ''
        let search = urlObject.search || ''
        Logger.info(`http request--> sending......    url:${url}  host:${host}, port=${this.port}, pathname=${pathname}, search=${search}`);

        let headers = ''
        if (options.header !== undefined) {
            for (let headerKey in options.header) {
                if (headerKey !== ConstantManager.CONTENT_TYPE) {
                    headers += headerKey + ': ' + options.header[headerKey] + '\r\n'
                }
            }
        }
        Logger.info('http request--> headers = ' + headers.replace(/\r\n/g, "........."));

        let hostName = Url.URL.parseURL(this.originUrl)
        switch (options.method.toString()) {
            case RequestMethod.GET:
                if(this.includeAuthorityInRequestLine(request,route.proxy.type)) {
                    sendBody += "GET " + url + " HTTP/1.1\r\n"
                } else {
                    sendBody += "GET " + pathname + search + " HTTP/1.1\r\n"
                }
                sendBody += "Host: " + hostName.hostname + "\r\n"
                sendBody += "Content-Type: application/json;charset=UTF-8\r\n"
                sendBody += "Cache-Control: no-cache\r\n"
                sendBody += 'Connection: keep-alive\r\n'
                if (headers.length > 0) {
                    sendBody += headers
                }
                sendBody += "\r\n"
                break
            case RequestMethod.DELETE:
                sendBody += "DELETE " + pathname + search + " HTTP/1.1\r\n"
                sendBody += "Host: " + hostName.hostname + "\r\n"
                sendBody += "Content-Type: application/json;charset=UTF-8\r\n"
                sendBody += "Cache-Control: no-cache\r\n"
                sendBody += 'Connection: keep-alive\r\n'
                sendBody += "\r\n"
                break
            case RequestMethod.PUT:
                let pa = '';
                if (search.length > 1) {
                    pa = search.substring(1, search.length);
                } else if (typeof options.extraData == 'string' && options.extraData.length > 0) {
                    pa = options.extraData;
                }

                sendBody += this.buildPostSendBody(
                    pathname,
                    hostName,
                    request.getHeader("Content-Type"),
                    request.getHeader("Connection"));

                if (headers.length > 0) {
                    sendBody += headers;
                }
                sendBody += 'Content-Length: ' + Utils.strToArrayBuffer(pa).byteLength + '\r\n\r\n';
                sendBody += pa + "\r\n";
                break;
            case RequestMethod.POST:
                let params = '';
                if (search.length > 1) {
                    params = search.substring(1, search.length);
                } else if (typeof options.extraData == 'string' && options.extraData.length > 0) {
                    params = options.extraData;
                }

                Logger.info('http request--> params = ' + params.replace(/\r\n/g, "........."))

                sendBody += this.buildPostSendBody(
                    pathname,
                    hostName,
                    request.getHeader("Content-Type"),
                    request.getHeader("Connection"));

                if (headers.length > 0) {
                    sendBody += headers;
                }
                if (params.length > 0) {
                    sendBody += 'Content-Length: ' + Utils.strToArrayBuffer(params).byteLength + '\r\n\r\n';
                }else {
                    sendBody += '\r\n\r\n';
                }
                if (params.length > 0) {
                    sendBody += params + '\r\n';
                }
                sendBody += '\r\n';
                break;
        }
        this.sendBody(sendBody)
    }

    private sendBody(body: string) {
        Logger.info("http request--> send body = " + body.toString().replace(/\r\n/g, " ........."));
        let sendBody = this.isHttps ? body.toString() : { data: body.toString(), encoding: 'UTF-8' }
        this.socketObject.send(sendBody)
            .then(() => {
                Logger.info('http request--> socket send success')
            })
            .catch((err) => {
                hilog.error(0x0001, 'http request-->socket send fail ', JSON.stringify(err))
                this.dealFailResult(err.code, 'socket send fail', err.name)
            })
    }

    includeAuthorityInRequestLine(request: Request, proxyType: Type) {
        return !this.isHttps && proxyType ==Type.HTTP
    }
}

export interface HttpRequestOptions {
    /**
     * Request method.
     */
    method?: RequestMethod; // default is GET
    /**
     * Additional data of the request.
     * extraData can be a string or an Object (API 6) or an ArrayBuffer(API 8).
     */
    extraData?: string | Object | ArrayBuffer;
    /**
     * HTTP request header.
     */
    header?: Object; // default is 'content-type': 'application/json'
    /**
     * Read timeout period. The default value is 60,000, in ms.
     */
    readTimeout?: number; // default is 60s
    /**
     * Connection timeout interval. The default value is 60,000, in ms.
     */
    connectTimeout?: number; // default is 60s.

    route?:Route
}

export enum RequestMethod {
    OPTIONS = "OPTIONS",
    GET = "GET",
    HEAD = "HEAD",
    POST = "POST",
    PUT = "PUT",
    DELETE = "DELETE",
    TRACE = "TRACE",
    CONNECT = "CONNECT"
}

export enum ResponseCode {
    OK = 200,
    CREATED,
    ACCEPTED,
    NOT_AUTHORITATIVE,
    NO_CONTENT,
    RESET,
    PARTIAL,
    MULT_CHOICE = 300,
    MOVED_PERM,
    MOVED_TEMP,
    SEE_OTHER,
    NOT_MODIFIED,
    USE_PROXY,
    BAD_REQUEST = 400,
    UNAUTHORIZED,
    PAYMENT_REQUIRED,
    FORBIDDEN,
    NOT_FOUND,
    BAD_METHOD,
    NOT_ACCEPTABLE,
    PROXY_AUTH,
    CLIENT_TIMEOUT,
    CONFLICT,
    GONE,
    LENGTH_REQUIRED,
    PRECON_FAILED,
    ENTITY_TOO_LARGE,
    REQ_TOO_LONG,
    UNSUPPORTED_TYPE,
    INTERNAL_ERROR = 500,
    NOT_IMPLEMENTED,
    BAD_GATEWAY,
    UNAVAILABLE,
    GATEWAY_TIMEOUT,
    VERSION
}

export class HttpResponse {
    /**
     * result can be a string (API 6) or an ArrayBuffer(API 8). Object is deprecated from API 8.
     */
    result: string | Object | ArrayBuffer;
    /**
     * Server status code.
     */
    responseCode: ResponseCode | number;
    /**
     * All headers in the response from the server.
     */
    header: Object;
    /**
     * @since 8
     */
    cookies: string;
}

export interface AsyncCallback<T, E = void> {
    /**
     * Defines the callback data.
     * @since 6
     */
    (err: BusinessError<E>, data: T): void;
}

export interface BusinessError<T = void> extends Error {
    /**
     * Defines the basic error code.
     * @since 6
     */
    code: number;
    /**
     * Defines the additional information for business
     * @type { ?T }
     * @since 9
     */
    data?: T;
}

export interface Callback<T> {
    /**
     * Defines the callback info.
     * @since 6
     */
    (data: T): void;
}