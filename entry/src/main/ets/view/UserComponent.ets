@Component
export struct User {
  build() {
    Navigation() {
      Column() {
        Text($r('app.string.text_user_setting'))
          .fontSize($r('app.float.component_title_size'))
          .fontWeight(700)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 16 })
          .fontFamily('HarmonyHeiTi-Bold')
          .lineHeight(33)
      }
    }

  }

}