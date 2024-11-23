import { UserAccount } from '../model/UserAccount';
import { HttpUtil } from '@ohos/network';
import { UrlConstants } from '../constants/UrlConstants';
import { LoginHeaderConstants } from '../constants/LoginHeaderConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, JSON, util } from '@kit.ArkTS';
import { CryptoUtil } from '@ohos/util';
import { rcp } from '@kit.RemoteCommunicationKit';
import { CookieJar, FormEncoder, HttpClient, Request, TimeUnit } from '@ohos/httpclient';
import { LoginParams } from '../model/LoginParam';

const TAG = '[LoginNetFunc]'

export class LoginNetFunc {
  private client: HttpClient;

  constructor() {
    this.client = new HttpClient.Builder().setConnectTimeout(30, TimeUnit.SECONDS)
      .setReadTimeout(30, TimeUnit.SECONDS).setWriteTimeout(30, TimeUnit.SECONDS).build();
  }

  cookieJar: () => void = (): void => CookieJar();

  public loginZhlgd(userAccount: UserAccount) {
    this.zhlgdLoginData(userAccount).then((result) => {
      console.debug(JSON.stringify(result))
      let formEncoder = new FormEncoder.Builder().add('rsa', '')
        .add('ul', result.ul)
        .add('pl', result.pl)
        .add('lt', result.lt)
        .add('execution', result.execution)
        .add('_eventId', result._eventId)
        .build();
      let formBody = formEncoder.createRequestBody();
      let request = new Request.Builder()
        // .params('service', 'https://zhlgd.whut.edu.cn/tp_up/')
        .post(formBody)
        .url('https://zhlgd.whut.edu.cn/tpass/login?service=https%3A%2F%2Fzhlgd.whut.edu.cn%2Ftp_up%2F')
        .addHeader("Accept",
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7")
        .addHeader("Accept-Encoding", "gzip, deflate, br")
        .addHeader("Accept-Language", "zh-CN,zh;q=0.9")
        .addHeader("Cache-Control", "max-age=0")
        .addHeader("Connection", "keep-alive")
        .addHeader("Content-Type", "application/x-www-form-urlencoded")
        .addHeader("Host", "zhlgd.whut.edu.cn")
        .addHeader("Origin", "https://zhlgd.whut.edu.cn")
        .addHeader(
          "Referer",
          "https://zhlgd.whut.edu.cn/tpass/login?service=https%3A%2F%2Fzhlgd.whut.edu.cn%2Ftp_up%2F"
        )
        .addHeader("Sec-Ch-Ua", "\"Not=A?Brand\";v=\"99\", \"Chromium\";v=\"118\"")
        .addHeader("Sec-Ch-Ua-Mobile", "?0")
        .addHeader("Sec-Ch-Ua-Platform", "\"Windows\"")
        .addHeader("Sec-Fetch-Dest", "document")
        .addHeader("Sec-Fetch-Mode", "navigate")
        .addHeader("Sec-Fetch-Site", "same-origin")
        .addHeader("Sec-Fetch-User", "?1")
        .addHeader("Upgrade-Insecure-Requests", "1")
        .addHeader(
          "User-Agent",
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
        )
        .followRedirects(false)
        .followSslRedirects(false)
        .build()


      this.client.newCall(request)
        .execute()
        .then((response) => {
          while (response.isRedirect()) {

          }
          console.debug(TAG, JSON.stringify(request))
          console.debug(TAG, response.getHeader(), response.isRedirect())
          console.debug(TAG, response.getBody().toString())
          let location: object = JSON.parse(response.getHeader()) as object
          if (location) {
            let locationUrl: string = location?.['location']
            let getRequest = new Request.Builder()
              .url(locationUrl)
              .get()
              .addHeader("Accept",
                "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7")
              .addHeader("Accept-Encoding", "gzip, deflate, br")
              .addHeader("Accept-Language", "zh-CN,zh;q=0.9")
              .addHeader("Cache-Control", "max-age=0")
              .addHeader("Connection", "keep-alive")
              .addHeader("Content-Type", "application/x-www-form-urlencoded")
              .addHeader("Host", "zhlgd.whut.edu.cn")
              .addHeader("Origin", "https://zhlgd.whut.edu.cn")
              .addHeader(
                "Referer",
                "https://zhlgd.whut.edu.cn/tpass/login?service=https%3A%2F%2Fzhlgd.whut.edu.cn%2Ftp_up%2F"
              )
              .addHeader("Sec-Ch-Ua", "\"Not=A?Brand\";v=\"99\", \"Chromium\";v=\"118\"")
              .addHeader("Sec-Ch-Ua-Mobile", "?0")
              .addHeader("Sec-Ch-Ua-Platform", "\"Windows\"")
              .addHeader("Sec-Fetch-Dest", "document")
              .addHeader("Sec-Fetch-Mode", "navigate")
              .addHeader("Sec-Fetch-Site", "same-origin")
              .addHeader("Sec-Fetch-User", "?1")
              .addHeader("Upgrade-Insecure-Requests", "1")
              .addHeader(
                "User-Agent",
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
              )
              .followRedirects(false)
              .followSslRedirects(false)
              .build()
            this.client.newCall(getRequest).execute().then((response) => {
              console.debug(TAG, response.header.toString())
            })
          }
        })
        .catch((error: Error) => {
          console.error(TAG, JSON.stringify(error))
        })
    })

  }

  zhlgdLoginData(userAccount: UserAccount) {
    const username = userAccount.username;
    const password = userAccount.password;
    return new Promise((resolve: (value: LoginParams | PromiseLike<LoginParams>) => void, reject) => {
      HttpUtil.getInstance()
        .httpGetByRcp(UrlConstants.ZHLGD_LOGIN, LoginHeaderConstants.ZHLGD_LOGIN_HEADER)
        .then(async (response) => {
          const responseStr = response.toString();
          const regexLt: RegExp = /value=\"(LT.*?)\"/;
          const regexExecution: RegExp = /name=\"execution\" value=\"(.*?)\"/;
          let matchLt = (responseStr as string).match(regexLt);
          let matchEx = (responseStr as string).match(regexExecution)
          let lt: string | null = matchLt ? matchLt[1] : null;
          let execution: string | null = matchEx ? matchEx[1] : null;
          console.debug(TAG, '', lt, execution)
          this.getZhlgdKey().then(async (publicKey) => {
            console.debug(TAG, 'pubKey', publicKey)
            let cipherParam = 'RSA|PKCS1';
            let base64Helper = new util.Base64Helper();
            let pubKey = '-----BEGIN RSA PUBLIC KEY-----\n' + publicKey + '\n-----END RSA PUBLIC KEY-----\n'
            const keyPair = CryptoUtil.genKeyPairByPubKey('RSA1024', pubKey);
            let uPlainText: cryptoFramework.DataBlob = {
              data: new Uint8Array(buffer.from(username, 'utf-8').buffer)
            };
            let pPlainText: cryptoFramework.DataBlob = {
              data: new Uint8Array(buffer.from(password, 'utf-8').buffer)
            }
            let uEncryptText = await CryptoUtil.encryptPublicKeyMessagePromise(cipherParam, keyPair.pubKey,
              uPlainText);
            let pEncryptText = await CryptoUtil.encryptPublicKeyMessagePromise(cipherParam, keyPair.pubKey,
              pPlainText);
            console.debug(TAG, 'u', uEncryptText.data);
            console.debug(TAG, 'p', pEncryptText.data);
            let ul = base64Helper.encodeToStringSync(uEncryptText.data);
            let pl = base64Helper.encodeToStringSync(pEncryptText.data);
            console.debug(TAG, 'ul', ul);
            console.debug(TAG, 'pl', pl);
            const multipleForm: LoginParams = {
              rsa: '',
              ul: ul,
              pl: pl,
              lt: lt as string,
              execution: execution as string,
              _eventId: 'submit'
            }
            console.debug(JSON.stringify(multipleForm))
            resolve(multipleForm)
          })

        })
        .catch((error: BusinessError) => {
          reject(error)
        })
    })
  }

  getZhlgdKey() {
    return new Promise((resolve: (value: string | PromiseLike<string>) => void, reject) => {
      HttpUtil.getInstance()
        .httpPostByRcp(UrlConstants.ZHLGD_RSA_KEY, LoginHeaderConstants.ZHLGD_LOGIN_HEADER,
          new rcp.Form({ 'skipWechat': true }))
        .then((response) => {
          resolve((response.toJSON() as object)?.["publicKey"])
        })
        .catch((error: BusinessError) => {
          reject(error)
        })
    })
  }

  strToBt(input: string): Array<number> {
    const length = input.length;
    const bt: Array<number> = new Array(64).fill(0);

    for (let i = 0; i < Math.min(length, 4); i++) {
      const charCode = input.charCodeAt(i);
      for (let j = 0; j < 16; j++) {
        const pow = 1 << (15 - j);
        bt[16 * i + j] = Math.floor(charCode / pow) % 2;
      }
    }

    for (let i = length; i < 4; i++) {
      for (let j = 0; j < 16; j++) {
        bt[16 * i + j] = 0;
      }
    }
    return bt;
  }

  getKeyBytes(key: string): Array<Array<number>> {
    const keyBytes: Array<Array<number>> = [];
    const length = key.length;
    const iterator = Math.floor(length / 4);
    const remainder = length % 4;

    for (let i = 0; i < iterator; i++) {
      const chunk = key.substring(i * 4, i * 4 + 4);
      keyBytes.push(this.strToBt(chunk));
    }

    if (remainder > 0) {
      const chunk = key.substring(iterator * 4, length);
      keyBytes.push(this.strToBt(chunk));
    }

    return keyBytes;
  }

  generate3DESKey(part1: string, part2: string, part3: string): Array<number> {
    const key1 = this.getKeyBytes(part1)[0];
    const key2 = this.getKeyBytes(part2)[0];
    const key3 = this.getKeyBytes(part3)[0];

    return [...key1, ...key2, ...key3];
  }

  binaryToUint8Array(binaryArray: Array<number>): Uint8Array {
    const byteArray = new Uint8Array(binaryArray.length / 8);

    for (let i = 0; i < binaryArray.length; i += 8) {
      let byte = 0;
      for (let j = 0; j < 8; j++) {
        byte = (byte << 1) | binaryArray[i + j]; // 左移并添加每一位
      }
      byteArray[i / 8] = byte;
    }

    return byteArray;
  }
}
