import { webview } from '@kit.ArkWeb';
import { CookieUtil, EventType } from '@ohos/utils';
import { NewsNetFunc } from '../service/NewsNetFunc';
import { common } from '@kit.AbilityKit';

@Component
export struct TodayNavigationTitle {
  @StorageLink('zhlgd_cookie') cookie: string = AppStorage.get<string>('zhlgd_cookie') || '';
  @State isLoginShow: boolean = false;
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
  @Styles
  barButtonStyle() {
    .height($r('app.float.interactive_button_height'))
    .width($r('app.float.interactive_button_height'))
    .backgroundColor($r('app.color.interact_button_background'))
  }

  @Builder
  loginBindSheet() {
    Web({
      src: 'https://zhlgd.whut.edu.cn/tp_up/view?m=up#act=portal/viewhome',
      controller: this.webViewController
    })
      .onPageEnd(() => {
        this.cookie =
          webview.WebCookieManager.fetchCookieSync('https://zhlgd.whut.edu.cn/tp_up/view?m=up#act=portal/viewhome');
        CookieUtil.getInstance().saveZHLGDCookie(this.cookie);
        new NewsNetFunc().checkLoginStatus(this.cookie).then((status: boolean) => {
          if (status) {
            this.eventHub.emit(EventType.REFRESH_NEWS)
          }
        })
      })
  }

  build() {
    Row() {
      GridRow({ columns: { sm: 6, md: 8, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 4, lg: 6 } }) {
          Row() {
            Text($r('app.string.today'))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
          }
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .height('100%')
        }

        GridCol({ span: { sm: 3, md: 4, lg: 6 } }) {
          Row() {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
            }
            .onClick(() => {
              this.isLoginShow = true;
            })
            .barButtonStyle()
            .bindSheet($$this.isLoginShow, this.loginBindSheet())
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.End)
        }
      }
    }
    .height($r('app.float.normal_navigation_title_height'))
    .backgroundBlurStyle(BlurStyle.Thin)
    .padding({
      top: AppStorage.get<number>('statusBarHeight') as number + 5,
      left: $r('app.float.md_padding_margin'),
      right: $r('app.float.md_padding_margin')
    })
  }
}