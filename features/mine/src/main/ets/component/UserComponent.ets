import { UserModel } from '../model/UserModel';

@Component
export struct UserHead {
  @StorageProp('isLogged') isLogged: boolean = false;
  @StorageProp('username') username: string | null = null;

  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
        .fontSize($r('app.float.user_item_image_height'))
        .fontColor([$r('app.color.whut_blue')])
        .margin($r('app.float.md_padding_margin'))
      Column() {
        Text(this.isLogged ? this.username : $r('app.string.default_user_name'))
          .fontSize($r('app.float.user_item_name_size'))
          .lineHeight($r('app.float.normal_text_line_height'))
        Text($r('app.string.user_default_description'))
          .fontSize($r('app.float.user_item_description_size'))
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight($r('app.float.light_text_line_height'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
  }
}

@Component
export struct CampusNetAccount {
  @State userModel: UserModel = UserModel.getInstance();
  @State showPassword: boolean = false;

  build() {
    Column({ space: 5 }) {
      Row() {
        Text('校园网')
          .fontSize(18)
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Start)
          .margin({ left: $r('app.float.md_padding_margin') })
        Blank()
        Button($r('app.string.save'))
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.userModel.saveCampusNetAccount()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column({ space: 5 }) {
        Row() {
          TextInput({ placeholder: $r('app.string.user_name'), text: this.userModel.campusNetAccount.username })
            .type(InputType.USER_NAME)
            .enableAutoFill(false)
            .onChange((value: string) => {
              this.userModel.campusNetAccount.username = value
            })
        }

        Row() {
          TextInput({ placeholder: $r('app.string.password'), text: this.userModel.campusNetAccount.password })
            .type(InputType.Password)
            .enableAutoFill(false)
            .showPasswordIcon(true)
            .showPassword(this.showPassword)
            .onSecurityStateChange((isShowPassword: boolean) => {
              this.showPassword = isShowPassword;
            })
            .onChange((value: string) => {
              this.userModel.campusNetAccount.password = value
            })

        }
      }

    }
    .layoutWeight(1)
  }
}