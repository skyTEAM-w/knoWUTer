import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class UserNetFunc {
  private session: rcp.Session;

  constructor() {
    this.session = rcp.createSession()
  }

  public checkZhlgdIsLogged(cookie: string) {
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