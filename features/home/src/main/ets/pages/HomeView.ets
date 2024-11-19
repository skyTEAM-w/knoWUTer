import { webview } from '@kit.ArkWeb';
import { TodayNavigationTitle } from '../components/TodayNavigationTitle';
import { TodayCourse } from '../components/TodayCourse';
import { CampusNews } from '../components/CampusNews';
import { BreakPointType, BreakPointTypeEnum } from '@ohos/utils';
import { NewsUrl } from '../model/News';
import { WebViewPage } from '@ohos/uicomponents';

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

  @Builder
  pageMap(name: string) {
    if (name === 'WebViewPage') {
      WebViewPage();
    }
  }

  build() {
    Navigation(this.homePathStack) {
      Column() {
        Stack() {
          Column() {
            Scroll() {
              Column() {
                Column()
                  .height($r('app.float.navigation_height'))
                WaterFlow() {
                  FlowItem() {
                    TodayCourse()
                  }

                  FlowItem() {
                    CampusNews({ handleClick: this.jumpWebView })
                  }
                }
                .columnsTemplate(new BreakPointType({
                  sm: '1fr',
                  md: '1fr',
                  lg: '1fr 1fr'
                }).getValue(this.currentBreakPoint))
                .height("100%")
                .columnsGap($r('app.float.home_column_gap'))
                .rowsGap($r('app.float.home_row_gap'))
                .edgeEffect(EdgeEffect.Spring)
                .scrollBar(BarState.Off)
                .nestedScroll({
                  scrollForward: NestedScrollMode.PARENT_FIRST,
                  scrollBackward: NestedScrollMode.SELF_FIRST
                })
              }
            }
            .scrollBar(BarState.Off)
            .height('100%')
          }


          TodayNavigationTitle()
        }
        .alignContent(Alignment.Top)
      }

    }
    .backgroundColor($r('sys.color.background_primary'))
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
    .navDestination(this.pageMap)
  }
}
