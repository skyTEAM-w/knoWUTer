import { NavigationTitleBar } from "../common/components/NavigationTitleBar"

@Component
export struct CourseTable {
  build() {
    Navigation() {
      Column() {
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