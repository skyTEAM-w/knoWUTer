import { HttpUtil } from '@ohos/network';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CampusNetStatus, CommonUrls } from '@ohos/utils';

const TAG = '[CampusNetFunc]'

export class CampusNetFunc {
  private httpUtil: HttpUtil = HttpUtil.getInstance()

  public getNasId() {
    return new Promise((resolve: (value: number | PromiseLike<number>) => void, reject) => {
      this.httpUtil.httpGetByRcpOnlyUrl('http://www.msftconnecttest.com/redirect?cmd=redirect').then((response) => {
        console.debug(TAG, 'nasId', response.headers.location)
        const redirectUrl = response.headers.location as string;
        if (redirectUrl?.search('1.1.1.1') as number > 0) {
          reject()
        } else {
          console.debug(TAG, redirectUrl)
          let tempStart = redirectUrl.search('api') + 6
          let tempEnd = redirectUrl.search('userip') - 1
          console.debug(TAG, tempStart, tempEnd)
          if (tempStart && tempEnd) {
            console.debug(TAG, 'nasId', redirectUrl.substring(tempStart, tempEnd))
            resolve(parseInt(redirectUrl.substring(tempStart, tempEnd)))
          }
        }
      })
    })
  }

  public login(username: string, password: string, nasId: number) {
    const headers: rcp.RequestHeaders = {
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'zh-CN,zh;q=0.9,en-GB;q=0.8,en-US;q=0.7,en;q=0.6',
      'Cache-Control': 'no-cache',
      'connection': 'Keep-Alive',
      'Host': '172.30.21.100',
      'Pragma': 'no-cache',
      'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      'X-Requested-With': 'XMLHttpRequest'
    }
    let url = `${CommonUrls.CAMPUS_NET_BASE}/api/account/login?username=${username}&password=${password}&nasId=${nasId}`
    return new Promise((resolve: (value: CampusNetStatus | PromiseLike<CampusNetStatus>) => void, reject) => {
      this.httpUtil.httpPostByRcp(url, headers, '{}').then((response) => {
        const json = response.toJSON() as object
        if (json['msg'] === CampusNetStatus.AUTH_SUCCESS) {
          resolve(CampusNetStatus.AUTH_SUCCESS)
        } else if (json['msg'] === CampusNetStatus.AUTH_FAILED) {
          resolve(CampusNetStatus.AUTH_FAILED)
        } else if (json['msg'] === CampusNetStatus.REQUIRE_CODE) {
          resolve(CampusNetStatus.REQUIRE_CODE)
        } else {
          resolve(CampusNetStatus.OTHER)
        }
      }).catch((error: BusinessError) => {
        reject(error)
      })
    })
  }

  public logout() {
    const headers: rcp.RequestHeaders = {
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'zh-CN,zh;q=0.9,en-GB;q=0.8,en-US;q=0.7,en;q=0.6',
      'Cache-Control': 'no-cache',
      'connection': 'Keep-Alive',
      'Host': '172.30.21.100',
      'Pragma': 'no-cache',
      'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      'X-Requested-With': 'XMLHttpRequest'
    }
    const token = undefined
    let url = `${CommonUrls.CAMPUS_NET_BASE}/api/account/logout?token=undefined'`;
    return new Promise((resolve: (value: CampusNetStatus | PromiseLike<CampusNetStatus>) => void, reject) => {
      this.httpUtil.httpGetByRcp(url, headers).then((response) => {
        console.debug(TAG, response.toString())
        const json = response.toJSON() as object;
        if (json['code'] === 0 && json['msg'] === CampusNetStatus.LOGOUT_SUCCESS) {
          resolve(CampusNetStatus.LOGOUT_SUCCESS)
        }
      })
    })

  }
}