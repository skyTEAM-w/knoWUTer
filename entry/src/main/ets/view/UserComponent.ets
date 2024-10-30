import { SettingTwoStatus, UserPreferenceType } from '../common/constants/CommonEnums';
import {PreferencesUtil} from '../common/utils/PreferencesUtil';
import { UserSettingUtil } from '../common/utils/UserSettingUtil';

@Component
export struct User {

  @State customSettingOfService: SettingTwoStatus = AppStorage.get<SettingTwoStatus>('customServiceListConfig') || SettingTwoStatus.OFF

  userSettingUtil: UserSettingUtil = UserSettingUtil.getInstance();

  aboutToAppear(): void {

  }

  build() {
    Navigation() {
      Column() {
        Text($r('app.string.text_user_setting'))
          .fontSize($r('app.float.component_title_size'))
          .fontWeight(700)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 16 })
          .fontFamily('HarmonyHeiTi-Bold')
          .lineHeight(33)

        Row() {
          Text('使用自定义的服务列表')
          Toggle({type: ToggleType.Switch, isOn: this.customSettingOfService === SettingTwoStatus.ON})
            .size({ width: 40, height: 20 })
            .selectedColor('#007DFF')
            .onChange((isOn) => {
              this.userSettingUtil.saveCustomServiceListSetting(isOn ?
              SettingTwoStatus.ON : SettingTwoStatus.OFF)
            })
        }
        .width('100%')
        .padding({left: 16, right: 16})
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }

  }
}