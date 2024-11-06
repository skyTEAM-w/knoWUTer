import { DownloadFileButton, DownloadIconStyle, promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { common, Want } from '@kit.AbilityKit';
import { WebUrl, ServiceUrl } from '@ohos/utils';
import { DormitoryLocation } from '@ohos/datastore';

@Component
export struct WebViewPage {
  @State webUrl: WebUrl | undefined = undefined;
  @State webTitle: string = '';
  @State webProgress: number = 0;
  dormitoryLocation: DormitoryLocation = new DormitoryLocation();
  isImport: Boolean = false;
  isRefresh: Boolean = false;
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
          if(this.webUrl) {
            let context = getContext(this) as common.UIAbilityContext;
            startBrowsableAbility(context, this.webUrl.url)
          }
        })
    }
  }

  @Builder
  WebViewToolBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.card_badge_yuansign_arrow_counterclockwise'))
    }
    .height('15%')
  }

  build() {
    NavDestination() {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Stretch }) {
          Row() {
            SymbolGlyph($r("sys.symbol.chevron_left"))
              .fontSize(30)
              .height('100%')
              .onClick(() => {
                this.onDestinationBack?.();
              })
          }

          Row() {
            Stack() {
              Progress({ value: this.webProgress, total: 100, type: ProgressType.Capsule })
                .width('100%').height('100%').color($r('app.color.whut_blue_background_selected'))

              Text(this.webTitle)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .ellipsisMode(EllipsisMode.END)
                .width('95%')
                .height('100%')
                .textAlign(TextAlign.Center)
            }
          }
          .justifyContent(FlexAlign.Center)
          .width('80%')
          .borderRadius(8)

          if (!this.isImport && !this.isRefresh) {
            Row() {
              SymbolGlyph($r("sys.symbol.arrow_right_up_and_square"))
                .fontSize(25)
                .height('80%')
            }
            .bindMenu(this.WebViewMenu())
          } else {
            Row() {
              DownloadFileButton({
                contentOptions: {
                  icon: DownloadIconStyle.FULL_FILLED
                },
                styleOptions: {
                  iconColor: Color.Black,
                  iconSize: 24,
                }
              })
            }
            .onClick(() => {


            })
          }


        }
        .padding({ bottom: 5 })
        .height(44)
        .width('95%')

        Web({
          src: this.webUrl?.url,
          controller: this.webViewController
        })
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .zoomAccess(true)
          .onPageBegin(() => {
            this.webTitle = this.webViewController.getUrl()
          })
          .onPageEnd(() => {
            console.log("view: " + this.webUrl?.url)
            this.webTitle = this.webViewController.getTitle()
          })
          .onProgressChange((event) => {
            if (event) {
              this.webProgress = event.newProgress;
              console.log('newProgress:' + event.newProgress);
            }
          })
      }
      .padding({ top: AppStorage.get<number>('statusBarHeight') })
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((webViewStackContext: NavDestinationContext) => {
      let param = webViewStackContext.pathInfo.param as Record<string, object>;
      this.webUrl = param.webUrl as ServiceUrl;
      this.onDestinationBack = param.onDestinationBack as () => boolean;
      if (param.isImport !== null) {
        this.isImport = param.isImport as Boolean;
      }
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