import { BottomTabsList } from '../viewmodel/BottomTabsModel';
import { Home } from '../views/HomeView';
import { Tools } from '@feature/tools';
import { Service } from '@feature/service';
import { Schedule } from '@feature/schedule';
import { User } from '../views/UserView';
import { BreakPointSystem, BreakPointTypeEnum, UserSettingUtil } from '@ohos/utils';
import { DBUtil } from '@ohos/utils';
import { WebViewPage } from '@ohos/uicomponents'

@Preview
@Entry
@Component
struct Index {
  @State bottomTabIndex: number = 2;
  @State bottomTabEffectIndex: number = 2;
  @Provide('serviceStack') serviceStack: NavPathStack = new NavPathStack();
  @Provide('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  private bottomTabController: TabsController = new TabsController();
  private breakPointSystem: BreakPointSystem = new BreakPointSystem();

  onPageShow(): void {
    UserSettingUtil.getInstance().checkAllSetting();
    DBUtil.getInstance();

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
        .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.DOWN),
          this.bottomTabEffectIndex === index)

      Text(BottomTabsList[index].text)
        .fontSize($r('app.float.bottom_font_size'))
        .opacity(0.6)
        .fontColor(this.bottomTabIndex === index ?
        $r('app.color.bottom_text_color_selected') : $r('app.color.bottom_text_color_normal'))
    }
    .width('100%')
    .height('100%')
    .border({ width: this.currentBreakPoint === BreakPointTypeEnum.LG ? {top: 0, right: 0.5} : {top : 0.5, right: 0}, color: "#FF182431" })
    .backgroundColor(Color.Transparent)
    .blur(BlurStyle.Regular)
    .padding({
      bottom: this.currentBreakPoint === BreakPointTypeEnum.LG ? 8 : AppStorage.get<number>('naviIndicatorHeight'),
      top: this.currentBreakPoint === BreakPointTypeEnum.LG ? AppStorage.get<number>('statusBarHeight') : 8
    })
  }

  build() {
    Navigation(this.appPathStack) {
      Flex({ direction: this.currentBreakPoint === BreakPointTypeEnum.LG ? FlexDirection.Row : FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
        Tabs({ barPosition: this.currentBreakPoint === BreakPointTypeEnum.LG ? BarPosition.Start : BarPosition.End, index: this.bottomTabIndex, controller: this.bottomTabController }) {
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
        .onChange((index: number) => {
          this.bottomTabIndex = index;
        })
        .onTabBarClick((index: number) => {
          this.bottomTabEffectIndex = index;
        })
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
