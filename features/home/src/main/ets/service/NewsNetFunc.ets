import { rcp } from '@kit.RemoteCommunicationKit';
import { GrabNews, News, NewsTypeRecord } from '../model/News';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[NewsNetFunc]'

export class NewsNetFunc {
  private session: rcp.Session;

  constructor() {
    this.session = rcp.createSession()
  }

  public async getGrabNews(cookie: string) {
    let headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}'
    let req = new rcp.Request('https://zhlgd.whut.edu.cn/tp_up/up/grabnews/getGrabNewsList', 'POST', headers, content);
    return new Promise((resolve: (value: GrabNews[] | PromiseLike<GrabNews[]>) => void,
      reject: (reason?: Object) => void) => {
      this.session.fetch(req).then((response) => {
        const jsonObject = response.toJSON();
        const keys = Object.keys(NewsTypeRecord);
        let result: GrabNews[] = [];
        for (let i = 0; i < keys.length; i++) {
          const newsObject = (jsonObject as object)?.[keys[i]] as object[];
          const newsList = newsObject.map((item) => item as News)
          result.push(Object({ type: NewsTypeRecord[keys[i]], news: newsList }) as GrabNews)
        }
        resolve(result as GrabNews[])
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }

  public checkLoginStatus(cookie: string) {
    let headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}'
    let req = new rcp.Request('https://zhlgd.whut.edu.cn/tp_up/up/grabnews/getGrabNewsList', 'POST', headers, content);
    return new Promise((resolve: (value: boolean | PromiseLike<boolean>) => void,
      reject: (value: object) => void) => {
      this.session.fetch(req).then((response) => {
        const responseString = response.toString()
        resolve(!(responseString as string).includes('登录'))
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }
}