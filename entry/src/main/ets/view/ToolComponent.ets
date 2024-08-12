import { hilog } from '@kit.PerformanceAnalysisKit'
import { http } from '@kit.NetworkKit';
import { url } from '@kit.ArkTS';

@Component
export struct Tools {
  @StorageLink('Cookie') cookie: string = '';

  build() {
    Navigation() {
      Column() {
        Text($r('app.string.text_tools'))
          .fontSize($r('app.float.component_title_size'))
          .fontWeight(700)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 16 })
          .fontFamily('HarmonyHeiTi-Bold')
          .lineHeight(33)
      }
    }
    // Button('HTTP Test')
    //   .onClick(async () => {
    //     hilog.info(0x0000, 'HTTP TEST', 'HTTP TEST');
    //     let httpReq = http.createHttp();
    //     let response = httpReq.request(
    //       'https://zhlgd.whut.edu.cn/tp_up/view?m=up#act=portal/viewhome',
    //       {
    //         method: http.RequestMethod.GET,
    //         header: {
    //           'content-type:': 'text/html',
    //           'cookie': this.cookie.toString(),
    //           'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0'
    //         }
    //       }
    //     )
    //     await response.then((data) => {
    //       hilog.info(0x0000, 'HTTP TEST', data.responseCode.toString());
    //     })
    //   })
  }
}