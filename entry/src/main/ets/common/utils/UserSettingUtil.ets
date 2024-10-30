import { SettingTwoStatus } from "../constants/CommonEnums";
import { PreferencesUtil } from "./PreferencesUtil";
import App from "@system.app";

const CUSTOM_SERVICE_LIST_CONFIG = 'custom_service_list_config';

export class UserSettingUtil {
  private preferenceUtil: PreferencesUtil = PreferencesUtil.getInstance();
  private static instance: UserSettingUtil;

  public static getInstance() {
    if (!UserSettingUtil.instance) {
      UserSettingUtil.instance = new UserSettingUtil();
    }
    return UserSettingUtil.instance;
  }

  public saveCustomServiceListSetting(newSetting: SettingTwoStatus) {
    this.preferenceUtil.setValue<SettingTwoStatus>(CUSTOM_SERVICE_LIST_CONFIG, newSetting);
    AppStorage.setOrCreate('customServiceListConfig', newSetting);
  }

  public checkCustomServiceListSetting(): void {
    this.preferenceUtil.getValue<SettingTwoStatus>(CUSTOM_SERVICE_LIST_CONFIG).then((config: SettingTwoStatus | null) => {
      if (!config) {
        config = SettingTwoStatus.OFF
      }
      AppStorage.setOrCreate('customServiceListConfig', config);
    })
  }

  public checkAllSetting(): void {
    this.checkCustomServiceListSetting();
  }
}