import { BreakPointTypeEnum, SettingTwoStatus, UserSettingUtil } from '@ohos/utils';
import { UserModel } from '../model/UserModel';

@Component
export struct User {
  @Consume('minePathStack') minePathStack: NavPathStack;
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageProp('isLogged') isLogged: boolean = false;
  @State offsetY: number = 0;
  @State customSettingOfService: SettingTwoStatus =
    AppStorage.get<SettingTwoStatus>('customServiceListConfig') || SettingTwoStatus.OFF
  userSettingUtil: UserSettingUtil = UserSettingUtil.getInstance();
  @State isRefresh: boolean = false;
  private userModel: UserModel = UserModel.getInstance()

  aboutToAppear(): void {
    this.userModel.checkUsername()
  }

  calImageHeight(): number {
    return (this.offsetY + 150) * 2.5;
  }

  @Builder
  NavigationTitle(title: ResourceStr) {
    Column() {
      Text(title)
        .fontSize($r('app.float.component_title_size'))
        .fontWeight(700)
        .width('100%')
        .padding({ left: 16 })
        .fontFamily('HarmonyHeiTi-Bold')
        .lineHeight(33)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .renderFit(RenderFit.CENTER)
    .backgroundBlurStyle(BlurStyle.Thick)
    .padding({ top: AppStorage.get<number>('statusBarHeight') })
  }

  @Builder
  mineBackgroundImage() {
    Column() {
      Image($r('app.media.user_bacground'))
        .width('100%')
        .height(this.calImageHeight())
        .objectFit(ImageFit.Cover)
    }
  }

  build() {
    Navigation(this.minePathStack) {
      Stack({ alignContent: Alignment.Top }) {
        if (this.currentBreakPoint !== BreakPointTypeEnum.LG) {
          this.mineBackgroundImage()
        }
        Column() {
          MineNavigationHeader()
          Refresh({ refreshing: $$this.isRefresh }) {
            List() {
              ListItem() {
                Text(this.isLogged ? AppStorage.get<string>('username') : 'wwwwww')
              }
            }
            .height('100%')
          }
          .onOffsetChange((value: number) => {
            this.offsetY = value;
          })
        }
      }
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(false)
    .hideBackButton(true)
  }
}

@Component
struct MineNavigationHeader {
  build() {
    Row() {
      Blank()
      SymbolGlyph($r('sys.symbol.gearshape'))
        .fontSize(24)
        .margin({ right: $r('app.float.xxl_padding_margin_large') })
    }
    .height($r('app.float.mine_navigation_header_height'))
    .margin({ top: AppStorage.get<number>('statusBarHeight') })
    .width('100%')
  }
}