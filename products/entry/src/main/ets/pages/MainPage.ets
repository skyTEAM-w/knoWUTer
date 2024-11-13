import { BottomTabsList } from '../viewmodel/BottomTabsModel';
import { Home } from '../views/HomeView';
import { Tools } from '@feature/tools';
import { Service } from '@feature/service';
import { Schedule, ScheduleSettingFunc } from '@feature/schedule';
import { User } from '../views/UserView';
import { BreakPointSystem, BreakPointTypeEnum, CookieUtil, UserSettingUtil } from '@ohos/utils';
import { DBUtil } from '@ohos/datastore';
import { WebViewPage } from '@ohos/uicomponents';

@Preview
@Entry
@Component
struct Index {
  @State bottomTabIndex: number = 2;
  @State bottomTabEffectIndex: number = 2;
  @Provide('serviceStack') serviceStack: NavPathStack = new NavPathStack();
  @Provide('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Provide('schedulePathStack') schedulePathStack: NavPathStack = new NavPathStack();
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  private bottomTabController: TabsController = new TabsController();
  private breakPointSystem: BreakPointSystem = new BreakPointSystem();

  onPageShow(): void {
    UserSettingUtil.getInstance().checkAllSetting();
    DBUtil.getInstance();
    ScheduleSettingFunc.getInstance().checkAllScheduleSetting()
    CookieUtil.getInstance().checkAllCookies();
  }

  aboutToAppear(): void {
    this.breakPointSystem.register();
  }

  aboutToDisappear(): void {
    this.breakPointSystem.unregister();
  }

  @Builder
  pageMap(name: string) {
    if (name === 'WebViewPage') {
      WebViewPage();
    }
  }

  @Builder
  TabBuilder(index: number) {
    Column() {
      SymbolGlyph(this.bottomTabIndex === index ? BottomTabsList[index].iconSelected : BottomTabsList[index].icon)
        .fontSize(25)
        .renderingStrategy(this.bottomTabIndex === index ? SymbolRenderingStrategy.MULTIPLE_COLOR :
        SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontColor(this.bottomTabIndex === index ? [$r('app.color.whut_blue'), $r('app.color.whut_yellow')] :
          [Color.Black])
        .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.DOWN),
          this.bottomTabEffectIndex === index)

      Text(BottomTabsList[index].text)
        .fontSize($r('app.float.bottom_font_size'))
        .opacity(0.6)
        .fontColor(this.bottomTabIndex === index ?
        $r('app.color.bottom_text_color_selected') : $r('app.color.bottom_text_color_normal'))
    }
    .width('100%')
    .height(this.currentBreakPoint === BreakPointTypeEnum.LG ? '15%' : '100%')
    .border({
      width: this.currentBreakPoint === BreakPointTypeEnum.LG ? { top: 0, right: 0 } : { top: 0.5, right: 0 },
      color: "#FF182431"
    })
    .backgroundColor(Color.Transparent)
    .padding({
      bottom: this.currentBreakPoint === BreakPointTypeEnum.LG ? 8 : AppStorage.get<number>('naviIndicatorHeight'),
      top: 8
    })
  }

  build() {
    Navigation(this.appPathStack) {
      Flex({
        direction: this.currentBreakPoint === BreakPointTypeEnum.LG ? FlexDirection.Row : FlexDirection.Column,
        alignItems: ItemAlign.End,
        justifyContent: FlexAlign.End
      }) {
        Tabs({
          barPosition: this.currentBreakPoint === BreakPointTypeEnum.LG ? BarPosition.Start : BarPosition.End,
          index: this.bottomTabIndex,
          controller: this.bottomTabController
        }) {
          TabContent() {
            Schedule()
          }.tabBar(this.TabBuilder(0))

          TabContent() {
            Service()
          }.tabBar(this.TabBuilder(1))

          TabContent() {
            Home()
          }.tabBar(this.TabBuilder(2))

          TabContent() {
            Tools()
          }.tabBar(this.TabBuilder(3))

          TabContent() {
            User()
          }.tabBar(this.TabBuilder(4))

        }
        .width('100%')
        .barHeight(this.currentBreakPoint === BreakPointTypeEnum.LG ? '100%' : '10%')
        .barWidth(this.currentBreakPoint === BreakPointTypeEnum.LG ? '5%' : '100%')
        .scrollable(false)
        .barMode(this.currentBreakPoint === BreakPointTypeEnum.LG ? BarMode.Scrollable : BarMode.Fixed,
          { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
        .onChange((index: number) => {
          this.bottomTabIndex = index;
        })
        .onTabBarClick((index: number) => {
          this.bottomTabEffectIndex = index;
        })
        .animationDuration(0)
        .height('100%')
        .barOverlap(this.currentBreakPoint !== BreakPointTypeEnum.LG)
        .barBackgroundColor(Color.Transparent)
        .barBackgroundBlurStyle(BlurStyle.Regular)
        .vertical(this.currentBreakPoint === BreakPointTypeEnum.LG)
      }
      .width('100%')
    }
    .navDestination(this.pageMap)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
  }
}
