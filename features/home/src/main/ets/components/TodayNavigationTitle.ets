@Component
export struct TodayNavigationTitle {
  @Styles
  barButtonStyle() {
    .height($r('app.float.interactive_button_height'))
    .width($r('app.float.interactive_button_height'))
    .backgroundColor($r('app.color.interact_button_background'))
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
            .barButtonStyle()
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.End)
        }
      }
    }
    .height($r('app.float.normal_navigation_title_height'))
    .padding({
      top: AppStorage.get<number>('statusBarHeight') as number + 5,
      left: $r('app.float.md_padding_margin'),
      right: $r('app.float.md_padding_margin')
    })
  }
}