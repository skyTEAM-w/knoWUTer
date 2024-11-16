import { webview } from '@kit.ArkWeb';
import { TodayNavigationTitle } from '../components/TodayNavigationTitle';
import { TodayCourse } from '../components/TodayCourse';

@Component
export struct Home {
  private webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Navigation() {
      Column() {
        TodayNavigationTitle()
        TodayCourse()
      }
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(false)
    .hideBackButton(true)
  }
}
