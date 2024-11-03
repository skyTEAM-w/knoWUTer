import { BottomTabsList } from '../viewmodel/BottomTabsModel';
import { Home } from '../views/HomeView';
import { Tools } from '../views/ToolView';
import { Service } from '../views/ServiceView';
import { CourseTable } from '../views/CourseTableView';
import { User } from '../views/UserView';
import { UserSettingUtil } from '../common/utils/UserSettingUtil';
import { DBUtil } from '../common/utils/DBUtil';


@Entry
@Component
struct Index {
  @State bottomTabIndex: number = 2;
  @State bottomTabEffectIndex: number = 2;
  @Provide('serviceStack') serviceStack: NavPathStack = new NavPathStack();
  @Provide('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private bottomTabController: TabsController = new TabsController();

  onPageShow(): void {
    UserSettingUtil.getInstance().checkAllSetting();
    DBUtil.getInstance();
  }

  @Builder
  TabBuilder(index: number) {
    Column() {
      SymbolGlyph(this.bottomTabIndex === index ? BottomTabsList[index].iconSelected : BottomTabsList[index].icon)
        .fontSize(25)
        .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.DOWN), this.bottomTabEffectIndex === index)

      Text(BottomTabsList[index].text)
        .fontSize($r('app.float.bottom_font_size'))
        .opacity(0.6)
        .fontColor(this.bottomTabIndex === index ?
        $r('app.color.bottom_text_color_selected') : $r('app.color.bottom_text_color_normal'))
    }
    .width('100%')
    .height('100%')
    .border({ width: { top: 0.5 }, color: "#FF182431" })
    .backgroundColor(Color.Transparent)
    .blur(BlurStyle.Regular)
    .padding({bottom: AppStorage.get<number>('naviIndicatorHeight'),
      top: 8})
  }

  build() {
    Navigation(this.appPathStack) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
        Tabs({ barPosition: BarPosition.End, index: this.bottomTabIndex, controller: this.bottomTabController }) {
          TabContent() {
            CourseTable()
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
        .vertical(false)
        .barHeight('10%')
        .scrollable(false)
        .onChange((index: number) => {
          this.bottomTabIndex = index;
        })
        .onTabBarClick((index: number) => {
          this.bottomTabEffectIndex = index;
        })
        .height('100%')
        .barMode(BarMode.Fixed)
        .barOverlap(true)
        .barBackgroundColor(Color.Transparent)
        .barBackgroundBlurStyle(BlurStyle.Regular)
      }
      .width('100%')
    }
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
  }
}
