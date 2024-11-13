import { FormEncoder, HttpClient, Request, RequestBody, Response, TimeUnit } from '@ohos/httpclient';

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
}
