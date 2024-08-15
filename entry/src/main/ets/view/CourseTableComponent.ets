@Component
export struct CourseTable {
  build() {
    Navigation() {
      Column() {
        Text($r('app.string.text_course_table'))
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