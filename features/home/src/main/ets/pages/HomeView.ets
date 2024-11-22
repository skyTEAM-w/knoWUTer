import { webview } from '@kit.ArkWeb';
import { TodayNavigationTitle } from '../components/TodayNavigationTitle';
import { TodayCourse } from '../components/TodayCourse';
import { CampusNews } from '../components/CampusNews';
import { BreakPointType, BreakPointTypeEnum, EventType } from '@ohos/utils';
import { NewsUrl } from '../model/News';
import { WebViewPage } from '@ohos/uicomponents';
import { common } from '@kit.AbilityKit';

@Component
export struct Home {
  @Consume('homePathStack') homePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageLink('isShowWeekAndDay') isShowWeekAndDay: boolean = false;
  @State isRefresh: boolean = false;
  private webviewController: webview.WebviewController = new webview.WebviewController();
  private outScroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
    eventHub.on(EventType.REFRESH_NEWS_END, () => {
      setTimeout(() => {
        this.isRefresh = false
      }, 1500)
    })
  }

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
            Scroll(this.outScroller) {
              Column() {
                Column()
                  .height($r('app.float.navigation_height'))
                  .onVisibleAreaChange([0, 1], (isExpanding: boolean, currentRatio: number) => {
                    if (currentRatio == 0 && !isExpanding && this.outScroller.currentOffset().yOffset !== 0) {
                      this.isShowWeekAndDay = true;
                    } else if (currentRatio == 1 && isExpanding) {
                      this.isShowWeekAndDay = false;
                    }
                  })
                Refresh({ refreshing: $$this.isRefresh }) {
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
                .onRefreshing(() => {
                  const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
                  eventHub.emit(EventType.REFRESH_NEWS)
                  eventHub.emit(EventType.REFRESH_TODAY_COURSE)
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
