import { promptAction, router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { ServiceUrl } from '../model/ServiceUrl';
import { pasteboard } from '@kit.BasicServicesKit';

@Entry
@Component
struct WebViewPage {
  @State serviceUrl: ServiceUrl = router.getParams() as ServiceUrl;
  @State webUrl: string = '';
  private webViewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column({space: 5}) {
      Flex({justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Auto}) {
        Image($r("app.media.ic_arrow_left"))
          .height('80%')
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.back()
          })
        Text(this.webUrl)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .ellipsisMode(EllipsisMode.END)
          .width('80%')
          .height('100%')
          .textAlign(TextAlign.Center)
          .backgroundColor($r('app.color.normal_background_grey'))
          .borderRadius(10)
        Image($r("app.media.ic_arrow_right_up_and_square"))
          .height('80%')
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            copyText(this.webUrl)
          })
      }
      .height(33)
      .width('95%')
      Web({
        src: this.serviceUrl.url,
        controller: this.webViewController
      })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onPageBegin(() => {
          console.log("view: " + this.serviceUrl.url)
          this.webUrl = this.webViewController.getUrl()
        }
        )
    }

  }
}

function copyText(text: string) {
  const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
  const systemPasteboard = pasteboard.getSystemPasteboard();
  systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
  systemPasteboard.getData().then((data) => {
    if (data) {
      promptAction.showToast({ message: '已将网址复制到剪贴板' });
    } else {
      promptAction.showToast({ message: '复制失败' });
    }
  })
}