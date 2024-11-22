import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { HttpUtil } from '@ohos/network/src/main/ets/network/HttpUtil';

const TAG = '[UserNetFunc]'

export class UserNetFunc {
  private httpUtil: HttpUtil = HttpUtil.getInstance()

  constructor() {
  }

  public getReviewItemNum(cookie: string) {
    const headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}';
    return new Promise((resolve: (value: number | PromiseLike<number>) => void,
      reject: (value: object) => void) => {
      this.httpUtil.httpPostByRcp('https://zhlgd.whut.edu.cn/tp_up/up/workhall/getDWSHNum', headers, content)
        .then((response) => {
          const responseJson = response.toJSON()
          if (responseJson) {
            resolve((responseJson as object)?.['NUM'])
          }
          reject(new Object)
        })
        .catch((error: BusinessError) => {
          reject(error)
        })
    })
  }

  public getProgressItemNum(cookie: string) {
    const headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}';
    return new Promise((resolve: (value: number | PromiseLike<number>) => void,
      reject: (value: object) => void) => {
      this.httpUtil.httpPostByRcp('https://zhlgd.whut.edu.cn/tp_up/up/workhall/getZBSXNum', headers, content)
        .then((response) => {
          const responseJson = response.toJSON()
          if (responseJson) {
            resolve((responseJson as object)?.['NUM'])
          }
          reject(new Object)
        })
        .catch((error: BusinessError) => {
          reject(error)
        })
    })
  }

  public getScoreItemNum(cookie: string) {
    const headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}';
    return new Promise((resolve: (value: number | PromiseLike<number>) => void,
      reject: (value: object) => void) => {
      this.httpUtil.httpPostByRcp('https://zhlgd.whut.edu.cn/tp_up/up/workhall/getDWPJNum', headers, content)
        .then((response) => {
          const responseJson = response.toJSON()
          if (responseJson) {
            resolve((responseJson as object)?.['NUM'])
          }
          reject(new Object)
        })
        .catch((error: BusinessError) => {
          reject(error)
        })
    })
  }

  public getClosedItemNum(cookie: string) {
    const headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}';
    return new Promise((resolve: (value: number | PromiseLike<number>) => void,
      reject: (value: object) => void) => {
      this.httpUtil.httpPostByRcp('https://zhlgd.whut.edu.cn/tp_up/up/workhall/getBJSXNum', headers, content)
        .then((response) => {
          const responseJson = response.toJSON()
          if (responseJson) {
            resolve((responseJson as object)?.['NUM'])
          }
          reject(new Object)
        })
        .catch((error: BusinessError) => {
          reject(error)
        })
    })
  }

  public getBookNum(cookie: string) {
    const headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}';
    return new Promise((resolve: (value: number | PromiseLike<number>) => void,
      reject: (value: object) => void) => {
      this.httpUtil.httpPostByRcp('https://zhlgd.whut.edu.cn/tp_up/up/sysintegration/getlibraryRecordCount', headers,
        content)
        .then((response) => {
          const responseJson = response.toJSON()
          if (responseJson) {
            resolve((responseJson as object)?.['UNBACKLIBRARYCOUNT'])
          }
          reject(new Object)
        })
        .catch((error: BusinessError) => {
          reject(error)
        })
    })
  }

  public getCardMoney(cookie: string) {
    const headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}';
    return new Promise((resolve: (value: number | PromiseLike<number>) => void,
      reject: (value: object) => void) => {
      this.httpUtil.httpPostByRcp('https://zhlgd.whut.edu.cn/tp_up/up/sysintegration/getCardMoney', headers, content)
        .then((response) => {
          const responseJson = response.toJSON()
          if (responseJson) {
            resolve((responseJson as object)?.['KHYE'])
          }
          reject(new Object)
        })
        .catch((error: BusinessError) => {
          reject(error)
        })
    })
  }



  public checkZhlgdIsLogged(cookie: string) {
    let headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}'
    return new Promise((resolve: (value: boolean | PromiseLike<boolean>) => void,
      reject: (value: object) => void) => {
      this.httpUtil.httpPostByRcp('https://zhlgd.whut.edu.cn/tp_up/up/grabnews/getGrabNewsList', headers, content)
        .then((response) => {
          console.debug(TAG, response.statusCode)
          resolve(response.statusCode === 200)
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }
}