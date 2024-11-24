import { CampusNetModel } from '../model/CampusNetModel';

const TAG = 'CampusNetwork'

@Component
export struct CampusNetwork {
  @State campusNetModel: CampusNetModel = CampusNetModel.getInstance()
  @State showPassword: boolean = false;
  @StorageProp('bottomTabIndex') bottomTabIndex: number = 2;

  aboutToAppear(): void {
    this.campusNetModel.getUserAccount();
  }

  build() {
    Column({ space: 5 }) {
      Row() {
        Text('校园网')
          .fontSize(18)
          .fontWeight(700)
          .fontFamily('HarmonyHeiTi-medium')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column({ space: 5 }) {
        Row() {
          TextInput({ placeholder: $r('app.string.user_name'), text: $$this.campusNetModel.userNetAccount.username })
            .type(InputType.USER_NAME)
            .enableAutoFill(this.bottomTabIndex === 3)
        }

        Row() {
          TextInput({ placeholder: $r('app.string.password'), text: $$this.campusNetModel.userNetAccount.password })
            .type(InputType.Password)
            .showPasswordIcon(true)
            .showPassword(this.showPassword)
            .onSecurityStateChange((isShowPassword: boolean) => {
              this.showPassword = isShowPassword;
            })
            .enableAutoFill(this.bottomTabIndex === 3)
        }
      }

      Row() {
        Button($r('app.string.login_net'))
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            console.debug(TAG, JSON.stringify(this.campusNetModel.userNetAccount))
            this.campusNetModel.login(this.campusNetModel.userNetAccount)
          })
        Divider()
          .vertical(true)
          .height(22)
        Button($r('app.string.logout_net'))
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.campusNetModel.logout()
          })
        Divider()
          .vertical(true)
          .height(22)
        Button($r('app.string.text_save'))
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.campusNetModel.saveUserAccount()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .renderFit(RenderFit.RESIZE_CONTAIN)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.thin_yellow_background'))
    .borderRadius($r('app.float.border_radius'))
    .borderStyle(BorderStyle.Solid)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.99 })
    .width('100%')
    .padding({
      left: $r('app.float.lg_padding_margin'),
      right: $r('app.float.lg_padding_margin'),
      top: 10,
      bottom: 10
    })
  }
}