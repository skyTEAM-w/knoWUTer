import { rcp } from "@kit.RemoteCommunicationKit"
import { util } from "@kit.ArkTS";

export class NewsNetFunc {
  public async getGrabNews(cookie: string) {
    let headers: rcp.RequestHeaders = {
      "content-type": 'application/json;charset=utf-8',
      "cookie": cookie
    }
    let content = '{}'
    const session = rcp.createSession();
    let req = new rcp.Request('https://zhlgd.whut.edu.cn/tp_up/up/grabnews/getGrabNewsList', 'POST', headers, content);
    session.fetch(req).then((response) => {
      console.info("response: ", response.body);
      const decoder = util.TextDecoder.create('utf-8');
      console.debug(decoder.decodeToString(new Uint8Array(response.body)))
    })

  }
}