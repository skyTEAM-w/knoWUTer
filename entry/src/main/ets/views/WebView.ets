import { promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { ServiceUrl } from '../viewmodel/ServiceUrl';
import { ServiceBlockClass } from '../viewmodel/ServiceBlockClass';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { common, Want } from '@kit.AbilityKit';
import { importElectricity } from '../common/utils/PayElectricCharge';
import { WebUrl } from '../model/WebUrl';

@Component
struct WebViewPage {
  @State webUrl: WebUrl = new ServiceBlockClass('', '');
  @State webTitle: string = '';
  private webViewController: webview.WebviewController = new webview.WebviewController();
  isImport: Boolean = false;
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
          startBrowsableAbility(context, this.webUrl.url)
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

          if (!this.isImport) {
            Row() {
              SymbolGlyph($r("sys.symbol.arrow_right_up_and_square"))
                .fontSize(25)
                .height('80%')
            }
            .bindMenu(this.WebViewMenu())
          } else  {
            Row() {
              SymbolGlyph($r("sys.symbol.arrowshape_down_to_line_fill"))
                .fontSize(25)
                .height('80%')
            }
            .onClick(() => {
              importElectricity(this.webViewController).then((flag) => {
                if (flag) {
                  promptAction.showToast({message: '导入成功'})
                  this.onDestinationBack?.();
                } else {
                  promptAction.showToast({message: '导入失败，请确认是否选择完全'})
                }
              })
            })
          }


        }
        .padding({bottom: 5})
        .height(44)
        .width('95%')

        Web({
          src: this.webUrl.url,
          controller: this.webViewController
        })
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .zoomAccess(true)
          .onPageBegin(() => {
            this.webTitle = this.webViewController.getUrl()
          })
          .onPageEnd(() => {
            console.log("view: " + this.webUrl.url)
            this.webTitle = this.webViewController.getTitle()
          })
      }
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