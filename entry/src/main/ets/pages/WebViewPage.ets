import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { ServiceUrl } from '../model/ServiceUrl';

@Entry
@Component
struct WebViewPage {
  @State serviceUrl: ServiceUrl = router.getParams() as ServiceUrl;
  private webViewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({
        src: this.serviceUrl.url,
        controller: this.webViewController
      })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onPageBegin(() => {
          console.log("view: " + this.serviceUrl.url)
        }
        )
    }

  }
}