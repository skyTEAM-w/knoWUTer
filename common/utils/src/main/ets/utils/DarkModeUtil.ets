import { PreferencesUtil } from '@ohos/datastore';
import { common, ConfigurationConstant } from '@kit.AbilityKit';

const DARK_MODE_CONFIG: string = 'dark_mode_config';

@Observed
export class DarkModeSettingsConfig {
  switchType: DarkModeType = DarkModeType.FOLLOW_UP;
  startTime: Date = new Date();
  endTime: Date = new Date();

  constructor() {
    let startDate = new Date();
    let endDate = new Date(startDate);
    startDate.setHours(22);
    startDate.setMinutes(0);
    this.startTime = startDate;
    endDate.setHours(7);
    endDate.setMinutes(30);
    this.endTime = endDate;
  }
}

export enum DarkModeType {
  FOLLOW_UP = -1,
  ALL_DAY = 0,
  TIMED = 1
}

export class DarkModeUtil {
  private static instance: DarkModeUtil;
  private preferences: PreferencesUtil = PreferencesUtil.getInstance();

  public static getInstance() {
    if (!DarkModeUtil.instance) {
      DarkModeUtil.instance = new DarkModeUtil();
    }
    return DarkModeUtil.instance;
  }

  public saveDarkModeSettingsConfig(darkModeConfig: DarkModeSettingsConfig) {
    this.preferences.setValue<DarkModeSettingsConfig>(DARK_MODE_CONFIG, darkModeConfig);
    this.checkDarkMode(darkModeConfig);
  }

  public checkDarkModeSetting(): void {
    this.preferences.getValue<DarkModeSettingsConfig>(DARK_MODE_CONFIG)
      .then((config: DarkModeSettingsConfig | null) => {
        let darkModeConfig = config as DarkModeSettingsConfig;
        if (!darkModeConfig) {
          darkModeConfig = new DarkModeSettingsConfig();
        }
        darkModeConfig.startTime = new Date(darkModeConfig.startTime);
        darkModeConfig.endTime = new Date(darkModeConfig.endTime);
        this.checkDarkMode(darkModeConfig);
      });
  }

  private checkDarkMode(darkModeConfig: DarkModeSettingsConfig): void {
    AppStorage.setOrCreate('darkModeConfig', darkModeConfig);
    let applicationContext = getContext(this).getApplicationContext();
    let colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    if (darkModeConfig.switchType === DarkModeType.FOLLOW_UP) {
      colorMode = (getContext(this) as common.UIAbilityContext).config.colorMode ||
      AppStorage.get('systemColorMode') || ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    } else if (darkModeConfig.switchType === DarkModeType.ALL_DAY) {
      colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    } else {
      colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      let startTime: number = darkModeConfig.startTime.getHours() * 60 + darkModeConfig.startTime.getMinutes();
      let endTime: number = darkModeConfig.endTime.getHours() * 60 + darkModeConfig.endTime.getMinutes();
      let nowTime: number = new Date().getHours() * 60 + new Date().getMinutes();
      if (startTime > endTime) {
        if (nowTime <= endTime || nowTime >= startTime) {
          colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        }
      } else {
        if (nowTime >= startTime && nowTime <= endTime) {
          colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        }
      }
    }
    AppStorage.setOrCreate('currentColorMode', colorMode);
    applicationContext.setColorMode(colorMode);
  }
}