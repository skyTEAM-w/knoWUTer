import { SettingTwoStatus } from '../constants/CommonEnums';
import { PreferencesUtil } from './PreferencesUtil';

const CUSTOM_SERVICE_LIST_CONFIG = 'custom_service_list_config';
const CWSF_COOKIE = 'cwsf_cookie';

export class UserSettingUtil {
  private static instance: UserSettingUtil;
  private preferenceUtil: PreferencesUtil = PreferencesUtil.getInstance();

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

  public saveCWSFCookie(cookie: string) {
    this.preferenceUtil.setValue<string>(CWSF_COOKIE, cookie);
    AppStorage.setOrCreate('fee_cookie', cookie);
  }

  public checkCustomServiceListSetting(): void {
    this.preferenceUtil.getValue<SettingTwoStatus>(CUSTOM_SERVICE_LIST_CONFIG).then((config: SettingTwoStatus | null) => {
      if (!config) {
        config = SettingTwoStatus.OFF
      }
      AppStorage.setOrCreate('customServiceListConfig', config);
    })
  }

  public checkCWSFCookie(): void {
    this.preferenceUtil.getValue<string>(CWSF_COOKIE).then((config: string | null) => {
      if (!config) {
        config = '';
      }
      AppStorage.setOrCreate('fee_cookie', config);
    })
  }

  public checkAllSetting(): void {
    this.checkCustomServiceListSetting();
    this.checkCWSFCookie();
  }
}