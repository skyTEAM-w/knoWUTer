import { TopNavigationView } from '@ohos/uicomponents';
import { BreakPointTypeEnum } from '@ohos/utils';
import { CampusNetAccount, UserHead } from '../component/UserComponent';
import { UserModel } from '../model/UserModel';
import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

@Component
struct AccountView {
  @Consume('settingPathStack') settingPathStack: NavPathStack;
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageProp('isLogged') isLogged: boolean = false;
  @State userModel: UserModel = UserModel.getInstance();
  private webViewController = new webview.WebviewController()

  goBack(): void {
    this.settingPathStack.pop()
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          title: $r('app.string.account'),
          onBackClick: this.currentBreakPoint === BreakPointTypeEnum.SM ? () => this.goBack() : undefined
        })
        Column() {
          Column({ space: 12 }) {
            Row() {
              UserHead()
            }
            .backgroundColor($r('sys.color.comp_background_primary'))
            .width('100%')
            .borderRadius($r('app.float.light_border_radius'))
            .padding({
              left: $r('app.float.sm_padding_margin'),
              top: $r('app.float.lg_padding_margin'),
              right: $r('app.float.sm_padding_margin'),
              bottom: $r('app.float.lg_padding_margin')
            })

            Row() {
              CampusNetAccount()
            }
            .backgroundColor($r('sys.color.comp_background_primary'))
            .width('100%')
            .borderRadius($r('app.float.light_border_radius'))
            .padding({
              left: $r('app.float.sm_padding_margin'),
              top: $r('app.float.sm_padding_margin'),
              right: $r('app.float.sm_padding_margin'),
              bottom: $r('app.float.sm_padding_margin')
            })

          }
          .padding({ top: $r('app.float.ss_padding_margin') })

          Blank()
          Button(!this.isLogged ? $r('app.string.please_login') : $r('app.string.logout'))
            .onClick(() => {
              if (this.isLogged) {
                this.userModel.logoutCurrentUser().then(() => {
                  this.settingPathStack.pop()
                })
              } else {
                router.replaceNamedRoute({ name: 'LoginPage' })
              }

            })
            .fontColor(!this.isLogged ? $r('sys.color.brand_font') : $r('sys.color.ohos_id_color_badge_red'))
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .width('100%')
            .height(40)
            .margin({ bottom: $r('app.float.sm_padding_margin') })
        }
        .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ?
          { left: $r('app.float.xxl_padding_margin_large'), right: $r('app.float.xxl_padding_margin_large') } :
          { left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin') })
        .layoutWeight(1)
      }
      .padding({
        bottom: AppStorage.get<number>('naviIndicatorHeight')
      })

    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
  }
}

@Builder
export function AccountViewBuilder() {
  AccountView()
}