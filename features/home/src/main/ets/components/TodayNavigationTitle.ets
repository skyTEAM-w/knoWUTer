import { webview } from '@kit.ArkWeb';
import { CommonConstants, CookieUtil, EventType } from '@ohos/utils';
import { common } from '@kit.AbilityKit';
import { NewsModel } from '../model/NewsModel';
import { curves } from '@kit.ArkUI';

@Component
export struct TodayNavigationTitle {
  @StorageLink('zhlgd_cookie') cookie: string = AppStorage.get<string>('zhlgd_cookie') || '';
  @StorageLink('isShowWeekAndDay') isShowWeekAndDay: boolean = false;
  @StorageProp('currentWeekAndDay') currentWeekAndDay: string = '';
  @Prop isThisTab: boolean;
  @State isLoginShow: boolean = false;
  @State newsModel: NewsModel = NewsModel.getInstance();
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
  private navigationSpringCurve: ICurve = curves.springMotion(0.38, 0.7)

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
        this.newsModel.checkZhlgdLogged().then((status: boolean) => {
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
          if (this.isThisTab) {
            Row({ space: 10 }) {
              Text($r('app.string.today'))
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
              if (this.isShowWeekAndDay) {
                Text(this.currentWeekAndDay)
                  .fontSize(14)
                  .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.8, y: 0.8 })).animation({
                    duration: CommonConstants.VERY_SHORT_ANIMATION_DURATION,
                    curve: Curve.Friction
                  }))
              }
            }
            .justifyContent(FlexAlign.Start)
            .width('100%')
            .height('100%')
            .transition(TransitionEffect.move(TransitionEdge.START).animation({ curve: this.navigationSpringCurve }))
          }

        }

        GridCol({ span: { sm: 3, md: 4, lg: 6 } }) {
          if (this.isThisTab) {
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
            .transition(TransitionEffect.move(TransitionEdge.END).animation({ curve: this.navigationSpringCurve }))
          }

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