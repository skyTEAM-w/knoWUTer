import { http } from '@kit.NetworkKit';
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

export class HttpUtilResponse {
  result: string;
  responseCode: number;

  constructor(result: string, responseCode: number) {
    this.result = result;
    this.responseCode = responseCode;
  }

  getBody(): string {
    return this.result;
  }
}

export function buildFormBody(params: Record<string, string>): string {
  return Object.keys(params)
    .map(key => encodeURIComponent(key) + '=' + encodeURIComponent(params[key]))
    .join('&');
}

export class HttpUtil {
  private static instance: HttpUtil;
  private session: rcp.Session = rcp.createSession();

  public static getInstance(): HttpUtil {
    if (!HttpUtil.instance) {
      HttpUtil.instance = new HttpUtil();
    }
    return HttpUtil.instance;
  }

  public httpPostByRcp(url: string, headers: rcp.RequestHeaders, content: string) {
    const req: rcp.Request = new rcp.Request(url, 'POST', headers, content);
    return new Promise((resolve: (value: rcp.Response | PromiseLike<rcp.Response>) => void, reject) => {
      this.session.fetch(req).then((response: rcp.Response) => {
        resolve(response)
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }

  public httpGetByRcp(url: string, headers: rcp.RequestHeaders) {
    const req: rcp.Request = new rcp.Request(url, 'GET', headers);
    return new Promise((resolve: (value: rcp.Response | PromiseLike<rcp.Response>) => void, reject) => {
      this.session.fetch(req).then((response: rcp.Response) => {
        resolve(response)
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }

  public httpGetByRcpOnlyUrl(url: string) {
    return new Promise((resolve: (value: rcp.Response | PromiseLike<rcp.Response>) => void, reject) => {
      this.session.get(url).then((response: rcp.Response) => {
        resolve(response)
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }

  async HttpPost(url: string, cookies: string, body: string): Promise<HttpUtilResponse | undefined> {
    const httpRequest: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          'Accept-Encoding': 'gzip, deflate',
          'Accept-Language': 'zh-CN,zh;q=0.9,en-GB;q=0.8,en-US;q=0.7,en;q=0.6',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
          'Cookie': cookies,
          'Pragma': 'no-cache',
          'Upgrade-Insecure-Requests': '1',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: body,
        connectTimeout: 30000,
        readTimeout: 30000
      });
      return new HttpUtilResponse(response.result as string, response.responseCode);
    } finally {
      httpRequest.destroy();
    }
  }

  async HttpGet(url: string, cookies: string): Promise<HttpUtilResponse | undefined> {
    const httpRequest: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Accept': '*/*',
          'Accept-Encoding': 'gzip, deflate',
          'Accept-Language': 'zh-CN,zh;q=0.9,en-GB;q=0.8,en-US;q=0.7,en;q=0.6',
          'Cache-Control': 'max-age=0',
          'Connection': 'keep-alive',
          'Cookie': cookies,
          'Pragma': 'no-cache',
          'Upgrade-Insecure-Requests': '1',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76'
        },
        connectTimeout: 30000,
        readTimeout: 30000
      });
      return new HttpUtilResponse(response.result as string, response.responseCode);
    } finally {
      httpRequest.destroy();
    }
  }
}
