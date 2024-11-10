@Builder
function DefaultBuilder() {
}

@Component
export struct TopNavigationView {
  title?: ResourceStr;
  @BuilderParam menuView?: CustomBuilder = DefaultBuilder;
  onBackClick?: Function;

  build() {
    Row() {
      if (this.onBackClick) {
        Image($r('app.media.ic_back'))
          .width($r('app.float.interactive_button_height'))
          .height($r('app.float.interactive_button_height'))
          .margin({ right: $r('app.float.lg_padding_margin') })
          .onClick(() => this.onBackClick?.())
      }

      Text(this.title)
        .fontSize($r('app.float.title_text_size'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .layoutWeight(1)

      Row() {
        if (this.menuView) {
          this.menuView()
        }
      }
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.navigation_height'))
    .padding({
      left: $r('app.float.xxl_padding_margin'),
      right: $r('app.float.xxl_padding_margin'),
      top: AppStorage.get<number>('statusBarHeight') as number + 5
    })
  }
}