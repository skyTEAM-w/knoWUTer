import { NavigationTitleBar } from 'uicomponents/src/main/ets/components/NavigationTitleBar';
import { SettingTwoStatus } from 'utils/src/main/ets/common/CommonEnums';
import { UserSettingUtil } from '@ohos/utils/src/main/ets/utils/UserSettingUtil';

@Component
export struct User {
  @State customSettingOfService: SettingTwoStatus =
    AppStorage.get<SettingTwoStatus>('customServiceListConfig') || SettingTwoStatus.OFF
  userSettingUtil: UserSettingUtil = UserSettingUtil.getInstance();

  aboutToAppear(): void {

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

  build() {
    Navigation() {
      Column() {
        Blank()
          .height($r('app.float.navigation_title_bar_half_height'))
        Row() {
          Text('使用自定义的服务列表')
          Toggle({ type: ToggleType.Switch, isOn: this.customSettingOfService === SettingTwoStatus.ON })
            .size({ width: 40, height: 20 })
            .selectedColor($r('sys.color.brand'))
            .onChange((isOn) => {
              this.userSettingUtil.saveCustomServiceListSetting(isOn ?
              SettingTwoStatus.ON : SettingTwoStatus.OFF)
            })
        }
        .width('100%')

        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding({ left: 16, right: 16 })
    }
    .mode(NavigationMode.Stack)
    .title({
      builder: NavigationTitleBar($r('app.string.text_user_setting')),
      height: $r('app.float.navigation_title_bar_height')
    }, {
      barStyle: BarStyle.STACK
    })
    .titleMode(NavigationTitleMode.Mini)
    .hideTitleBar(false)
    .hideBackButton(true)
  }
}