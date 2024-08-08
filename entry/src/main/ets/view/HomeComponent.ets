import { webview } from '@kit.ArkWeb';

@Component
export struct Home {
  private webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({ src: "https://zhlgd.whut.edu.cn/tpass/login", controller: this.webviewController })
        .domStorageAccess(true)
    }
  }
}
