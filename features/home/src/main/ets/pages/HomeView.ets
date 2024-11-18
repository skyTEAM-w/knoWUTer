import { webview } from '@kit.ArkWeb';
import { TodayNavigationTitle } from '../components/TodayNavigationTitle';
import { TodayCourse } from '../components/TodayCourse';
import { CampusNews } from '../components/CampusNews';
import { BreakPointTypeEnum } from '@ohos/utils';
import { NewsUrl } from '../model/News';

@Component
export struct Home {
  @Consume('homePathStack') homePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  private webviewController: webview.WebviewController = new webview.WebviewController();

  jumpWebView(url: string) {
    if (this.currentBreakPoint === BreakPointTypeEnum.LG) {
      this.homePathStack.pushPathByName('WebViewPage', new Object({
        webUrl: new NewsUrl(url),
        onDestinationBack: () => {
          this.homePathStack.pop();
          return false;
        }
      }))
    } else {
      this.appPathStack.pushPathByName('WebViewPage', new Object({
        webUrl: new NewsUrl(url),
        onDestinationBack: () => {
          this.appPathStack.pop();
          return false;
        }
      }))
    }
  }

  build() {
    Navigation(this.homePathStack) {
      Column() {
        Stack() {
          List() {
            ListItem() {
              Column().height($r('app.float.navigation_height'))
            }

            ListItem() {
              TodayCourse()
            }

            ListItem() {
              CampusNews({ handleClick: this.jumpWebView })
            }
          }
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)

          TodayNavigationTitle()
        }
        .alignContent(Alignment.Top)
      }

    }
    .backgroundColor($r('sys.color.background_primary'))
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
