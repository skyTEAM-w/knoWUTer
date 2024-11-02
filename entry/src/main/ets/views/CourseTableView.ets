import { NavigationTitleBar } from "../common/components/NavigationTitleBar"

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
    .mode(NavigationMode.Stack)
    .title({builder: NavigationTitleBar($r('app.string.text_course_table')),
      height: $r('app.float.navigation_title_bar_height')}, {
      barStyle: BarStyle.STACK
    })
    .titleMode(NavigationTitleMode.Mini)
    .hideTitleBar(false)
    .hideBackButton(true)


  }
}