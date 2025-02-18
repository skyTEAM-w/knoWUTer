import { WebViewPage } from '@ohos/uicomponents';
import { BreakPointTypeEnum, CommonConstants, EventType, SettingTwoStatus, UserSettingUtil } from '@ohos/utils';
import { WorkHallUrl } from '../model/HallUrl';
import { UserModel } from '../model/UserModel';
import { Hall } from '../views/HallView';
import { curves, router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { SettingView } from '../views/SettingView';

@Component
export struct User {
  @StorageProp('bottomTabIndex') @Watch('onBottomIndexChange') bottomTabIndex: number = 2;
  @StorageLink('isShowInHeader') isShowInHeader: boolean = false;
  @Consume('minePathStack') minePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Provide('hallPathStack') hallPathStack: NavPathStack = new NavPathStack();
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @State isThisTab: boolean = false;
  @StorageProp('isLogged') isLogged: boolean = false;
  @StorageProp('username') username: string | null = null;
  @State offsetY: number = 0;
  @State customSettingOfService: SettingTwoStatus =
    AppStorage.get<SettingTwoStatus>('customServiceListConfig') || SettingTwoStatus.OFF
  userSettingUtil: UserSettingUtil = UserSettingUtil.getInstance();
  @State isRefresh: boolean = false;
  @State userModel: UserModel = UserModel.getInstance()
  private outScroller: Scroller = new Scroller();
  private innerScroller: Scroller = new Scroller();
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;

  aboutToAppear(): void {
    this.userModel.checkUsername()
    this.userModel.getWorkHallResourse()
    this.eventHub.on(EventType.REFRESH_HALL_END, () => {
      setTimeout(() => {
        this.isRefresh = false
      }, 1500)
    })
  }

  calImageHeight(): number {
    return (this.offsetY + 150) * 2.5;
  }

  onBottomIndexChange() {
    this.isThisTab = this.bottomTabIndex === CommonConstants.USER_BOTTOM_INDEX;
  }

  jumpWorkHallWebView(url: string) {
    if (this.currentBreakPoint === BreakPointTypeEnum.LG) {
      this.hallPathStack.replacePathByName('WebViewPage', new Object({
        webUrl: new WorkHallUrl(url),
        onDestinationBack: () => {
          this.hallPathStack.pop();
        }
      }))
    } else {
      this.appPathStack.pushPathByName('WebViewPage', new Object({
        webUrl: new WorkHallUrl(url),
        onDestinationBack: () => {
          this.appPathStack.pop();
        }
      }))
    }
  }

  jumpInformationWebView(url: string) {
    if (this.currentBreakPoint === BreakPointTypeEnum.LG) {
      this.hallPathStack.replacePathByName('WebViewPage', new Object({
        webUrl: new WorkHallUrl(url),
        onDestinationBack: () => {
          this.hallPathStack.pop();
        }
      }))
    } else {
      this.appPathStack.pushPathByName('WebViewPage', new Object({
        webUrl: new WorkHallUrl(url),
        onDestinationBack: () => {
          this.appPathStack.pop();
        }
      }))
    }
  }

  jumpSetting() {
    this.appPathStack.pushPathByName('SettingView', new Object)
  }

  @Builder
  pageMap(name: string) {
    if (name === 'WebViewPage') {
      WebViewPage();
    }
  }

  @Builder
  mineBackgroundImage() {
    Column() {
      Image($r("app.media.user_background"))
        .width('100%')
        .height(this.calImageHeight())
        .objectFit(ImageFit.Cover)
        .foregroundBlurStyle(BlurStyle.Thin)
    }
  }

  build() {
    Navigation(this.minePathStack) {
      Stack({ alignContent: Alignment.Top }) {
        if (this.currentBreakPoint !== BreakPointTypeEnum.LG) {
          this.mineBackgroundImage()
        }
        Column() {
          if (this.isThisTab) {
            MineNavigationHeader()
          } else {
            Column()
              .height($r('app.float.mine_navigation_header_height'))
              .margin({ top: AppStorage.get<number>('statusBarHeight') })
          }
          Refresh({ refreshing: $$this.isRefresh }) {
            List({ scroller: this.outScroller }) {
              ListItem() {
                if (this.isThisTab) {
                  UserInfo()
                }
              }
              .height(this.currentBreakPoint === BreakPointTypeEnum.LG ? $r('app.float.user_background_height_md') :
              $r('app.float.user_background_height_lg'))
              .onVisibleAreaChange([0, 1], (isVisible: boolean, currentRatio: number) => {
                if (currentRatio == 0 && !isVisible && this.outScroller.currentOffset().yOffset !== 0 &&
                  this.bottomTabIndex === 4) {
                  this.isShowInHeader = true;
                } else if (currentRatio == 1 && isVisible) {
                  this.isShowInHeader = false;
                }
              })

              ListItem() {
                Hall({
                  innerScroller: this.innerScroller,
                  handelClickWork: this.jumpWorkHallWebView,
                  handelClickInfo: this.jumpInformationWebView,
                  isThisTab: this.isThisTab
                })

              }
              .clip(false)
              .height('100%')
              .borderRadius($r('app.float.large_border_radius'))
              .backgroundColor($r('sys.color.background_primary'))
            }
            .clip(false)
            .layoutWeight(1)
            .width('100%')
            .edgeEffect(EdgeEffect.None)
            .scrollBar(BarState.Off)
            .height('100%')
          }
          .onRefreshing(() => {
            this.eventHub.emit(EventType.REFRESH_HALL)
          })
          .onOffsetChange((value: number) => {
            this.offsetY = value;
          })
        }
        .height('100%')
      }
      .height('100%')
    }
    .backgroundBlurStyle(this.currentBreakPoint === BreakPointTypeEnum.LG && !this.isLogged ? BlurStyle.Thin :
    BlurStyle.NONE)
    .navDestination(this.pageMap)
    .height('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}

@Component
struct MineNavigationHeader {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageProp('isShowInHeader') isShowInHeader: boolean = false;
  @StorageProp('isLogged') isLogged: boolean = false;
  @StorageProp('username') username: string | null = null;
  @StorageProp('currentBreakPoint') @Watch('foldExpandChange') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @StorageProp('foldExpanded') @Watch('foldExpandChange') foldExpanded: boolean = false;
  @State isShowSetting: boolean = false;

  foldExpandChange() {
    console.debug('index: ', this.appPathStack.getIndexByName('SettingView').length)
    if (this.foldExpanded && this.currentBreakPoint === BreakPointTypeEnum.MD &&
      this.appPathStack.getIndexByName('SettingView').length > 0) {
      console.debug('expended')
      this.isShowSetting = true;
      this.appPathStack.pop();
    } else if (!this.foldExpanded && this.currentBreakPoint === BreakPointTypeEnum.SM && this.isShowSetting) {
      this.appPathStack.pushPathByName('SettingView', undefined);
      this.isShowSetting = false;
      console.debug('unexpended')
    }
  }

  @Builder
  settingSheet() {
    Column() {
      SettingView()
    }
  }

  build() {
    Row() {
      Text(this.isLogged ? this.username : $r('app.string.please_login'))
        .padding({ left: $r('app.float.xxl_padding_margin') })
        .fontWeight(FontWeight.Bold)
        .position({ y: this.isShowInHeader ? 16 : $r('app.float.mine_navigation_header_height') })
        .opacity(this.isShowInHeader ? 1 : 0)
        .scale(this.isShowInHeader ? { x: 1, y: 1 } : { x: 0.8, y: 0.8 })
        .animation({ duration: CommonConstants.VERY_SHORT_ANIMATION_DURATION, curve: Curve.Friction })
      Blank()
      Button({ type: ButtonType.Circle }) {
        Row() {
          SymbolGlyph($r('sys.symbol.gearshape'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon')])
        }
      }
      .bindSheet($$this.isShowSetting, this.settingSheet(), {
        preferType: SheetType.CENTER,
        dragBar: false,
        maskColor: $r('sys.color.ohos_id_color_fourth'),
        backgroundColor: $r('sys.color.ohos_id_color_panel_bg')
      })
      .onClick(() => {
        if (this.currentBreakPoint === BreakPointTypeEnum.SM) {
          this.appPathStack.pushPathByName('SettingView', undefined)
        } else {
          this.isShowSetting = true;
        }
      })
      .margin({ right: $r('app.float.xxl_padding_margin_large') })
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
      .backgroundColor(Color.Transparent)
      .width($r('app.float.interactive_button_height'))
      .height($r('app.float.interactive_button_height'))

    }
    .transition(TransitionEffect.move(TransitionEdge.TOP).animation({ curve: curves.springMotion(0.4, 0.6) }))
    .height($r('app.float.mine_navigation_header_height'))
    .margin({ top: AppStorage.get<number>('statusBarHeight') })
    .width('100%')
  }
}

@Component
struct UserInfo {
  @StorageProp('username') username: string | null = null;
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageProp('isLogged') isLogged: boolean = false;

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
          .fontSize($r('app.float.user_image_height'))
          .fontColor([$r('app.color.whut_blue')])
        Text(this.isLogged ? this.username : $r('app.string.please_login'))
          .fontSize($r('app.float.user_name_size'))
      }
      .transition(this.isLogged ? TransitionEffect.asymmetric(
        TransitionEffect.SLIDE.animation({ curve: curves.springMotion(0.4, 0.66) }),
        TransitionEffect.OPACITY.animation({ duration: 0 })
      ) : TransitionEffect.asymmetric(
        TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.5, y: 0.5 }))
          .animation({ curve: curves.springMotion(0.4, 0.66) }),
        TransitionEffect.OPACITY.animation({ duration: 0 })
      ))
      .width('100%')
      .justifyContent(this.isLogged ? FlexAlign.Start : FlexAlign.Center)
      .onClick(() => {
        if (!this.isLogged) {
          router.replaceNamedRoute({ name: 'LoginPage' })
        }
      })

      Text($r('app.string.user_default_description'))
        .fontSize($r('app.float.user_description_font_size'))
        .fontColor($r('sys.color.font_secondary'))
        .transition(this.isLogged ? TransitionEffect.asymmetric(
          TransitionEffect.SLIDE.animation({ curve: curves.springMotion(0.4, 0.66) }),
          TransitionEffect.OPACITY.animation({ duration: 0 })
        ) : TransitionEffect.asymmetric(
          TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.5, y: 0.5 }))
            .animation({ curve: curves.springMotion(0.4, 0.66) }),
          TransitionEffect.OPACITY.animation({ duration: 0 })
        ))
    }
    .alignItems(this.isLogged ? HorizontalAlign.Start : HorizontalAlign.Center)
    .padding({ left: $r('app.float.xxl_padding_margin') })
    .width('100%')
    .height(this.currentBreakPoint === BreakPointTypeEnum.LG ? $r('app.float.user_background_height_md') :
    $r('app.float.user_background_height_lg'))
  }
}