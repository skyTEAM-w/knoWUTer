import { NavigationTitleBar } from '@ohos/uicomponents';

@Component
export struct Schedule {
  build() {
    Navigation() {
      Column() {
      }
    }
    .mode(NavigationMode.Stack)
    .title({
      builder: NavigationTitleBar($r('app.string.text_schedule')),
      height: $r('app.float.navigation_title_bar_height')
    }, {
      barStyle: BarStyle.STACK
    })
    .titleMode(NavigationTitleMode.Mini)
    .hideTitleBar(false)
    .hideBackButton(true)

  }
}