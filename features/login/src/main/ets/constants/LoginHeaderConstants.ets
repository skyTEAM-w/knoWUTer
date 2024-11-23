import { rcp } from '@kit.RemoteCommunicationKit';

export class LoginHeaderConstants {
  static readonly ZHLGD_LOGIN_HEADER: rcp.RequestHeaders = {
    "accept": 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    "accept-encoding": "gzip, deflate, br, zstd",
    "accept-language": 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
    "cache-control": 'max-age=0',
    'Connection': 'keep-alive',
    "content-type": 'application/x-www-form-urlencoded',
    'host': 'zhlgd.whut.edu.cn',
    "Origin": "https://zhlgd.whut.edu.cn",
    'Upgrade-Insecure-Requests': '1',
    'Referer': "https://zhlgd.whut.edu.cn/tpass/login?service=https%3A%2F%2Fzhlgd.whut.edu.cn%2Ftp_up%2F",
    "Sec-Ch-Ua": "\"Not=A?Brand\";v=\"99\", \"Chromium\";v=\"118\"",
    "Sec-Ch-Ua-Mobile": "?0",
    "Sec-Ch-Ua-Platform": "\"Windows\"",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "same-origin",
    "Sec-Fetch-User": "?1",
    "user-agent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0'
  }
}