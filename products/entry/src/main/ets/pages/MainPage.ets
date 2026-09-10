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
import { initDatabase } from '@ohos/datastore';
import { WebViewPage } from '@ohos/uicomponents';
import { UserView } from '@feature/mine/Index';
import { display } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { HdsTabs, HdsTabsController, hdsMaterial } from '@kit.UIDesignKit';

@Preview
@Entry
@Component
struct Index {
  @StorageLink('bottomTabIndex') bottomTabIndex: number = 2;
  @Provide('serviceStack') serviceStack: NavPathStack = new NavPathStack();
  @Provide('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Provide('schedulePathStack') schedulePathStack: NavPathStack = new NavPathStack();
  @Provide('homePathStack') homePathStack: NavPathStack = new NavPathStack();
  @Provide('minePathStack') minePathStack: NavPathStack = new NavPathStack();
  @Provide('settingPathStack') settingPathStack: NavPathStack = new NavPathStack();
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  @StorageProp('currentColorMode') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  private hdsTabsController: HdsTabsController = new HdsTabsController();
  private breakPointSystem: BreakPointSystem = new BreakPointSystem();

  onPageShow(): void {
    UserSettingUtil.getInstance().checkAllSetting();
    // 原生数据层初始化（就绪 Promise）
    initDatabase(getContext(this).databaseDir).then(() => {
      console.info('[MainPage]', 'native datastore ready');
    }).catch((e: Error) => {
      console.error('[MainPage]', `native datastore init failed: ${e.message}`);
    });
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
  tabContentsBuilder() {
    TabContent() {
      Schedule()
    }.tabBar(new BottomTabBarStyle({
      normal: BottomTabsList[0].normalSymbol,
      selected: BottomTabsList[0].selectedSymbol
    }, BottomTabsList[0].label))

    TabContent() {
      Service()
    }.tabBar(new BottomTabBarStyle({
      normal: BottomTabsList[1].normalSymbol,
      selected: BottomTabsList[1].selectedSymbol
    }, BottomTabsList[1].label))

    TabContent() {
      Home()
    }.tabBar(new BottomTabBarStyle({
      normal: BottomTabsList[2].normalSymbol,
      selected: BottomTabsList[2].selectedSymbol
    }, BottomTabsList[2].label))

    TabContent() {
      Tools()
    }.tabBar(new BottomTabBarStyle({
      normal: BottomTabsList[3].normalSymbol,
      selected: BottomTabsList[3].selectedSymbol
    }, BottomTabsList[3].label))

    TabContent() {
      UserView()
    }.tabBar(new BottomTabBarStyle({
      normal: BottomTabsList[4].normalSymbol,
      selected: BottomTabsList[4].selectedSymbol
    }, BottomTabsList[4].label))
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
        if (this.currentBreakPoint === BreakPointTypeEnum.LG) {
          HdsTabs({
            controller: this.hdsTabsController,
            index: this.bottomTabIndex
          }) {
            this.tabContentsBuilder()
          }
          .width('100%')
          .scrollable(false)
          .barMode(BarMode.Scrollable, { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
          .onChange((index: number) => {
            this.bottomTabIndex = index;
          })
          .animationDuration(0)
          .height('100%')
          .vertical(true)
          .barPosition(BarPosition.Start)
          .barWidth(76)
          .barHeight('100%')
          .barBackgroundColor(Color.Transparent)
          .barBackgroundBlurStyle(BlurStyle.Regular)
        } else {
          HdsTabs({
            controller: this.hdsTabsController,
            index: this.bottomTabIndex
          }) {
            this.tabContentsBuilder()
          }
          .width('100%')
          .barOverlap(true)
          .scrollable(false)
          .barMode(BarMode.Fixed, { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
          .onChange((index: number) => {
            this.bottomTabIndex = index;
          })
          .animationDuration(0)
          .height('100%')
          .barPosition(BarPosition.End)
          .barBackgroundColor(Color.Transparent)
          .barFloatingStyle({
            barWidth: { smallWidth: 280, mediumWidth: 360, largeWidth: 420 },
            barSideMargin: 16,
            barBottomMargin: 28,
            systemMaterialEffect: {
              materialType: hdsMaterial.MaterialType.ADAPTIVE,
              materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
            }
          })
          .barHeight(56 + this.naviIndicatorHeight)
        }
      }
    }
    .navDestination(this.pageMap)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
  }
}
