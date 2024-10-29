import { promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { ServiceUrl } from '../model/ServiceUrl';
import { ServiceBlockClass } from '../model/ServiceBlockClass';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { common, Want } from '@kit.AbilityKit';

@Component
struct WebViewPage {
  @State serviceUrl: ServiceUrl = new ServiceBlockClass('', '');
  @State webTitle: string = '';
  private webViewController: webview.WebviewController = new webview.WebviewController();
  onDestinationBack?: () => boolean = () => false;

  @Builder
  WebViewMenu() {
    Menu() {
      MenuItem({ content: "复制链接" })
        .onClick(() => {
          copyText(this.webViewController.getUrl())
        })
      MenuItem({ content: "在浏览器打开" })
        .onClick(() => {
          let context = getContext(this) as common.UIAbilityContext;
          startBrowsableAbility(context, this.serviceUrl.url)
        })
    }
  }

  build() {
    NavDestination() {
      Column({ space: 5 }) {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Stretch }) {
          Row() {
            Image($r("app.media.ic_arrow_back"))
              .height('100%')
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                this.onDestinationBack?.();
              })
              .borderRadius($r('app.float.border_radius'))
          }

          Row() {
            Text(this.webTitle)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .ellipsisMode(EllipsisMode.END)
              .width('95%')
              .height('100%')
              .textAlign(TextAlign.Center)

          }
          .justifyContent(FlexAlign.Center)
          .width('80%')
          .backgroundColor($r('app.color.normal_background_grey'))
          .borderRadius(8)

          Row() {
            Image($r("app.media.ic_arrow_right_up_and_square"))
              .height('80%')
              .objectFit(ImageFit.Contain)
          }
          .bindMenu(this.WebViewMenu())

        }
        .height(33)
        .width('95%')

        Web({
          src: this.serviceUrl.url,
          controller: this.webViewController
        })
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .zoomAccess(true)
          .onPageBegin(() => {
            this.webTitle = this.webViewController.getUrl()
          })
          .onPageEnd(() => {
            console.log("view: " + this.serviceUrl.url)
            this.webTitle = this.webViewController.getTitle()
          }
          )
      }
    }
    .hideTitleBar(true)
    .onReady((webViewStackContext: NavDestinationContext) => {
      let param = webViewStackContext.pathInfo.param as Record<string, object>;
      this.serviceUrl = param.webUrl as ServiceUrl;
      this.onDestinationBack = param.onDestinationBack as () => boolean;
    })
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

function startBrowsableAbility(context: common.UIAbilityContext, url: string): void {
  let want: Want = {
    action: 'ohos.want.action.viewData',
    entities: ['entity.system.browsable'],
    uri: url,
  };
  context.startAbility(want)
    .then(() => {
      console.error('Start browsableAbility successfully.');
    })
    .catch((err: BusinessError) => {
      console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
    });
}

@Builder
export function WebViewPageBuilder() {
  WebViewPage()
}