import { webview } from '@kit.ArkWeb';
import { getElectricCharge } from '../common/utils/PayElectricCharge';
import { DormitoryLocation } from '../model/DormitoryLocation';

@Component
export struct Tools {
  @StorageLink('Cookie') cookie: string = '';
  private webviewController: webview.WebviewController = new webview.WebviewController();
  private webResult: string = '';

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

      Button($r('app.string.tool_electric_charge'))
        .onClick(() => {
          getElectricCharge(this.webviewController, new DormitoryLocation('', '', '', ''))

          // router.pushUrl({
          //   url: 'pages/PayElecPage',
          //   params: ''
          // })

        })
      Web({
        src: 'https://zhlgd.whut.edu.cn/tpass/login?service=http%3A%2F%2Fcwsf.whut.edu.cn%2FcasLogin',
        controller: this.webviewController
      })
        .visibility(Visibility.Visible)
    }
  }
}
