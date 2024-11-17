import { rcp } from "@kit.RemoteCommunicationKit"
import { util } from "@kit.ArkTS";
import { News } from "../model/News";
import { it } from "@ohos/hypium";

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
      console.info("response: ", JSON.stringify(response.toJSON()));
      const jsonObject = response.toJSON();
      let keyArray: string[] = Object.keys(jsonObject as object)
      let value: object[] = Object.values(jsonObject as object)
      let newsKeyArray: string[] = Object.keys(value[0])
      let newsValueArray: object[] = Object.values(value[0])
      let news: string[] = Object.keys(newsValueArray[0])
      let detail: string[] = Object.values(newsValueArray[0])
      console.debug(keyArray[0].toString(), (value[0] as News[]))
      console.debug(newsKeyArray.toString(), newsValueArray as News[])
      console.debug(news.toString(), detail)
    })

  }
}