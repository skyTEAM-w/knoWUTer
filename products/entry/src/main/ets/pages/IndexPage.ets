import { UserModel } from '@feature/mine/Index';
import { DBUtil, PreferencesUtil } from '@ohos/datastore';
import {
  BreakPointSystem,
  BreakPointType,
  BreakPointTypeEnum,
  CookieUtil,
  DarkModeUtil,
  UserSettingUtil
} from '@ohos/utils';
import { router } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { ScheduleSettingFunc } from '@feature/schedule';

const TAG = '[IndexPage]'

@Preview
@Entry
@Component
struct IndexPage {
  @State isShow: boolean = false;
  @State isSkip: boolean = true;
  @State isLogged: boolean = false;
  @StorageProp('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @StorageLink('bottomTabIndex') bottomTabIndex: number = 2;
  private userModel = UserModel.getInstance();
  private preference = PreferencesUtil.getInstance();
  private breakPointSystem: BreakPointSystem = new BreakPointSystem();

  aboutToAppear(): void {
    this.checkIsSkip()
    this.checkIsLogged()
    this.dynamicImport()
    this.breakPointSystem.register()
  }

  aboutToDisappear(): void {
    this.breakPointSystem.unregister()
  }

  onPageShow(): void {
    DarkModeUtil.getInstance().checkDarkModeSetting()
    UserSettingUtil.getInstance().checkAllSetting();
    DBUtil.getInstance();
    ScheduleSettingFunc.getInstance().checkAllScheduleSetting()
    CookieUtil.getInstance().checkAllCookies();
  }

  dynamicImport() {
    try {
      import('@feature/login/src/main/ets/pages/LoginPage');
    } catch (error) {
      console.error(TAG, 'dynamicLoading Failed: ', JSON.stringify(error))
    }
  }

  checkIsSkip() {
    this.preference.hasValue('isAlwaysSkip').then((result: boolean) => {
      if (result) {
        this.preference.getValue<boolean>('isAlwaysSkip').then((skip) => {
          if (skip) {
            router.replaceUrl({
              url: 'pages/MainPage'
            })
          } else {
            this.isSkip = false;
          }
        }).catch((error: Error) => {
          console.error(JSON.stringify(error))
        })
      } else {
        this.preference.setValue<boolean>('isAlwaysSkip', false);
        this.isSkip = false;
      }

    })
  }

  checkIsLogged() {
    this.userModel.checkIsLogged().then((isLogged) => {
      if (isLogged) {
        router.replaceUrl({
          url: 'pages/MainPage'
        })
      } else {
        this.isLogged = false
        this.isShow = true
      }
    })
  }

  build() {
    Column() {
      if (this.isShow) {
        Image($r('app.media.startIcon_whut'))
          .width(new BreakPointType({ sm: '100%', md: '77%', lg: '66%' }).getValue(this.currentBreakPoint))
          .objectFit(ImageFit.Contain)
        Column({ space: 10 }) {
          GridRow({ columns: { sm: 6, md: 6, lg: 8 }, gutter: { x: 10, y: 10 } }) {
            GridCol({ span: { sm: 6, md: 3, lg: 4 }, order: 1 }) {
              Button($r('app.string.login'))
                .width('100%')
                .onClick(() => {
                  router.replaceNamedRoute({
                    name: 'LoginPage'
                  })
                })
            }

            GridCol({ span: { sm: 6, md: 3, lg: 4 }, order: 2 }) {
              Button($r('app.string.skip_login'))
                .backgroundColor($r('sys.color.ohos_id_button_bg_focus_color'))
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                .width('100%')
                .onClick(() => {
                  AppStorage.setOrCreate<boolean>('isLogged', false)
                  this.preference.setValue<boolean>('isAlwaysSkip', this.isSkip);
                  router.replaceUrl({
                    url: 'pages/MainPage'
                  })
                })
            }
          }

          Row() {
            Checkbox()
              .onChange((value) => {
                this.isSkip = value;
              })
            Text($r('app.string.always_skip_login'))
              .fontSize($r('sys.float.ohos_id_text_size_button2'))
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }
        .transition(TransitionEffect.OPACITY)
        .width('66%')
      }

    }
    .width('100%')
    .padding({ left: $r('app.float.xxl_padding_margin_large'), right: $r('app.float.xxl_padding_margin_large') })
    .height('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}