import { HttpClient, Request, RequestBody, Response, TimeUnit } from '@ohos/httpclient';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[HttpUtil]'

export enum ElectricityFeeActionType {
  AREA = 'getAreaInfo',
  BUILD = 'queryBuildList',
  FLOOR = 'queryFloorList',
  ROOM = 'getRoomInfo',
  ELECTRICITY = 'queryRoomElec',
  METER = 'queryReserve'
}

export class HttpUtil {
  private static instance: HttpUtil;
  private session: rcp.Session;

  constructor() {
    const config: rcp.SessionConfiguration = {
      requestConfiguration: {
        transfer: {
          timeout: {
            connectMs: 3000,
            transferMs: 3000
          },
          autoRedirect: false
        }
      }
    }
    this.session = rcp.createSession(config);
  }

  public static getInstance(): HttpUtil {
    if (!HttpUtil.instance) {
      HttpUtil.instance = new HttpUtil();
    }
    return HttpUtil.instance;
  }

  async HttpPost(url: string, cookies: string, body: RequestBody): Promise<Response | undefined> {
    let client = new HttpClient.Builder().setConnectTimeout(30, TimeUnit.SECONDS)
      .setReadTimeout(30, TimeUnit.SECONDS).setWriteTimeout(30, TimeUnit.SECONDS).build();
    let request = new Request.Builder().url(url)
      .post(body)
      .addHeader("Accept",
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7")
      .addHeader("Accept-Encoding", "gzip, deflate")
      .addHeader("Accept-Language", "zh-CN,zh;q=0.9,en-GB;q=0.8,en-US;q=0.7,en;q=0.6")
      .addHeader("Cache-Control", "no-cache")
      .addHeader("Connection", "keep-alive")
      .addHeader("Cookie", cookies)
      .addHeader("Pragma", "no-cache")
      .addHeader("Upgrade-Insecure-Requests", "1")
      .addHeader("User-Agent",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76")
      .addHeader("Content-Type", "application/x-www-form-urlencoded")
      .build()
    return await client.newCall(request).execute();
  }

  HttpPostSimple(url: string, cookie: string) {
    let client = new HttpClient.Builder().setConnectTimeout(30, TimeUnit.SECONDS)
      .setReadTimeout(30, TimeUnit.SECONDS).setWriteTimeout(30, TimeUnit.SECONDS).build();
    let request = new Request.Builder().url(url)
      .post()
  }

  async HttpGet(url: string, cookies: string): Promise<Response | undefined> {
    let client = new HttpClient.Builder().setConnectTimeout(30, TimeUnit.SECONDS)
      .setReadTimeout(30, TimeUnit.SECONDS).setWriteTimeout(30, TimeUnit.SECONDS).build();
    let request = new Request.Builder()
      .get(url)
      .addHeader("Accept", "*/*")
      .addHeader("Accept-Encoding", "gzip, deflate")
      .addHeader("Accept-Language", "zh-CN,zh;q=0.9,en-GB;q=0.8,en-US;q=0.7,en;q=0.6")
      .addHeader("Cache-Control", "max-age=0")
      .addHeader("Connection", "keep-alive")
      .addHeader("Cookie", cookies)
      .addHeader("Pragma", "no-cache")
      .addHeader("Upgrade-Insecure-Requests", "1")
      .addHeader("User-Agent",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76")
      .build()
    return await client.newCall(request).execute();
  }

  public httpPostByRcp(url: string, headers: rcp.RequestHeaders, content?: rcp.Form | rcp.MultipartForm | string) {
    const req = new rcp.Request(url, 'POST', headers, content);
    console.debug(this.session.configuration?.requestConfiguration?.transfer?.autoRedirect + '')
    return new Promise((resolve: (value: rcp.Response | PromiseLike<rcp.Response>) => void, reject) => {
      this.session.fetch(req).then((response) => {
        resolve(response)
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }

  public httpGetByRcp(url: string, headers: rcp.RequestHeaders) {
    const req = new rcp.Request(url, 'GET', headers);
    return new Promise((resolve: (value: rcp.Response | PromiseLike<rcp.Response>) => void, reject) => {
      this.session.fetch(req).then((response) => {
        resolve(response)
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }

  public httpGetByRcpOnlyUrl(url: string) {
    return new Promise((resolve: (value: rcp.Response | PromiseLike<rcp.Response>) => void, reject) => {
      this.session.get(url).then((response) => {
        resolve(response)
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }
}
