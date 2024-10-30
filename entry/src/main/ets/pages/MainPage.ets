import { BottomTabsList } from '../model/BottomTabsModel';
import { Home } from '../view/HomeComponent';
import { Tools } from '../view/ToolComponent';
import { Service } from '../view/ServiceComponent';
import { CourseTable } from '../view/CourseTableComponent';
import { User } from '../view/UserComponent';
import { UserSettingUtil } from '../common/utils/UserSettingUtil';


@Entry
@Component
struct Index {
  @State bottomTabIndex: number = 2;
  @Provide('serviceStack') serviceStack: NavPathStack = new NavPathStack();
  @Provide('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private bottomTabController: TabsController = new TabsController();

  onPageShow(): void {
    UserSettingUtil.getInstance().checkAllSetting();
  }

  @Builder
  TabBuilder(index: number, name: string) {
    Column() {
      Image(this.bottomTabIndex === index ? BottomTabsList[index].iconSelected : BottomTabsList[index].icon)
        .width('40%')
        .height('40%')
        .objectFit(ImageFit.Contain)

      Text(BottomTabsList[index].text)
        .fontSize($r('app.float.bottom_font_size'))
        .opacity(0.6)
        .fontColor(this.bottomTabIndex === index ?
        $r('app.color.bottom_text_color_selected') : $r('app.color.bottom_text_color_normal'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .border({ width: { top: 0.5 }, color: "#FF182431" })
    .backgroundColor(Color.Transparent)
    .blur(BlurStyle.Thick)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  build() {
    Navigation(this.appPathStack) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
        Tabs({ barPosition: BarPosition.End, index: this.bottomTabIndex, controller: this.bottomTabController }) {
          TabContent() {
            CourseTable()
          }.tabBar(this.TabBuilder(0, 'Map'))

          TabContent() {
            Service()
          }.tabBar(this.TabBuilder(1, 'Zone'))

          TabContent() {
            Home()
          }.tabBar(this.TabBuilder(2, 'Train'))

          TabContent() {
            Tools()
          }.tabBar(this.TabBuilder(3, 'Train'))

          TabContent() {
            User()
          }.tabBar(this.TabBuilder(4, 'Train'))

        }
        .width('100%')
        .vertical(false)
        .barHeight('8%')
        .scrollable(false)
        .onChange((index: number) => {
          this.bottomTabIndex = index;
        })
        .height('100%')
        .barOverlap(true)
        .barBackgroundColor(Color.Transparent)
        .barBackgroundBlurStyle(BlurStyle.Thick)
      }
      .width('100%')
    }
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
  }
}
