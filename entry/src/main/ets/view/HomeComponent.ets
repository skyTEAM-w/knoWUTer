import { webview } from '@kit.ArkWeb';

@Component
export struct Home {
  @StorageLink('Cookie') cookie: string = '';
  private webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({ src: "https://zhlgd.whut.edu.cn/tpass/login", controller: this.webviewController })
        .domStorageAccess(true)
        .javaScriptAccess(true)
        .onTitleReceive(() => {
          this.cookie = webview.WebCookieManager.fetchCookieSync("https://zhlgd.whut.edu.cn/tp_up/view?m=up#act=portal/viewhome").toString();
        })
    }
  }
}
