import { BottomTabsList } from '../viewmodel/BottomTabsModel';
import { Home } from '@feature/home';
import { Tools } from '@feature/tools';
import { Service } from '@feature/service';
import { Schedule, ScheduleSettingFunc } from '@feature/schedule';
import {
  BreakPointSystem,
  BreakPointTypeEnum,
  CookieUtil,
  UserSettingUtil,
  WindowUtil
} from '@ohos/utils';
import { DBUtil } from '@ohos/datastore';
import { WebViewPage } from '@ohos/uicomponents';
import { UserView } from '@feature/mine/Index';
import { display } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';

@Preview
@Entry
@Component
struct Index {
  @StorageLink('bottomTabIndex') bottomTabIndex: number = 2;
  @State bottomTabEffectIndex: number = 2;
  @Provide('serviceStack') serviceStack: NavPathStack = new NavPathStack();
  @Provide('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Provide('schedulePathStack') schedulePathStack: NavPathStack = new NavPathStack();
  @Provide('homePathStack') homePathStack: NavPathStack = new NavPathStack();
  @Provide('minePathStack') minePathStack: NavPathStack = new NavPathStack();
  @Provide('settingPathStack') settingPathStack: NavPathStack = new NavPathStack();
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  @StorageProp('currentColorMode') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
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
    try {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        if (display.isFoldable()) {
          this.changeOrientation(display.getFoldStatus());
          display.on('foldStatusChange', (status: display.FoldStatus) => {
            this.changeOrientation(status);
          });
        }
      }
    } catch (exception) {
      console.error('Is not fold able device error: ' + JSON.stringify(exception));
    }

  }

  aboutToDisappear(): void {
    this.breakPointSystem.unregister();
    try {
      display.off('foldStatusChange');
      display.off('change');
    } catch (exception) {
      console.error('Failed to unregister callback. Code: ' + JSON.stringify(exception));
    }
  }

  changeOrientation(status: display.FoldStatus) {
    if (status !== display.FoldStatus.FOLD_STATUS_EXPANDED) {
      AppStorage.setOrCreate('foldExpanded', false);
      WindowUtil.setMainWindowRestricted(getContext(this));
    } else {
      AppStorage.setOrCreate('foldExpanded', true);
      WindowUtil.setMainWindowPortrait(getContext(this));
    }
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
          [$r('sys.color.icon'), $r('sys.color.icon_secondary')])
        .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.DOWN),
          this.bottomTabEffectIndex === index)

      Text(BottomTabsList[index].text)
        .fontSize($r('app.float.bottom_font_size'))
        .opacity(0.6)
        .fontColor(this.bottomTabIndex === index ?
        $r('sys.color.ohos_id_color_bottom_tab_text_on') : $r('sys.color.ohos_id_color_bottom_tab_text_off'))
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
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Navigation(this.appPathStack) {
      Stack() {
        if (this.currentBreakPoint === BreakPointTypeEnum.LG && this.bottomTabIndex === 4) {
          Image($r('app.media.user_background_lg'))
            .width('100%')
            .height('100%')
            .foregroundBlurStyle(this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ?
            BlurStyle.NONE : BlurStyle.Thin)
        }
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
              UserView()
            }.tabBar(this.TabBuilder(4))

          }
          .width('100%')
          .barHeight(this.currentBreakPoint === BreakPointTypeEnum.LG ? '100%' : (56 + this.naviIndicatorHeight))
          .barWidth(this.currentBreakPoint === BreakPointTypeEnum.LG ? 76 : '100%')
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

    }
    .navDestination(this.pageMap)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
  }
}
