import { webview } from '@kit.ArkWeb';

@Component
export struct Home {
  @StorageLink('Cookie') cookie: string = '';
  private webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Text($r('app.string.text_home'))
        .fontSize($r('app.float.component_title_size'))
        .fontWeight(700)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 16 })
        .fontFamily('HarmonyHeiTi-Bold')
        .lineHeight(33)
        .onClick(() => {
          this.webviewController.backward()
        })
      Scroll(){
        Column(){
          Web({ src: "https://zhlgd.whut.edu.cn/tpass/login", controller: this.webviewController })
            .domStorageAccess(true)
            .javaScriptAccess(true)
            .onTitleReceive(() => {
              this.cookie =
                webview.WebCookieManager.fetchCookieSync("https://zhlgd.whut.edu.cn/tp_up/view?m=up#act=portal/viewhome")
                  .toString();
            })
        }

      }
      .scrollBar(BarState.Off)

    }
  }
}
