@Builder
export function NavigationTitleBar(title: ResourceStr) {
  Column() {
    Text(title)
      .fontSize($r('app.float.component_title_size'))
      .fontWeight(700)
      .width('100%')
      .padding({ left: 16 })
      .fontFamily('HarmonyHeiTi-Bold')
      .lineHeight(33)
      .textAlign(TextAlign.Start)
  }
  .width('100%')
  .height('100%')
  .backgroundBlurStyle(BlurStyle.Regular)
  .padding({ top: AppStorage.get<number>('statusBarHeight') })
}