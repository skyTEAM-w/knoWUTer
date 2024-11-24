import { PreferencesUtil } from '@ohos/datastore';
import { BreakPointTypeEnum, DarkModeSettingsConfig, DarkModeType, DarkModeUtil } from '@ohos/utils';
import { ConfigurationConstant } from '@kit.AbilityKit';

@Component
export struct SkipLoginSetting {
  @State isAlwaysSkip: boolean = false;
  private preference: PreferencesUtil = PreferencesUtil.getInstance()

  aboutToAppear(): void {
    this.preference.getValue<boolean>('isAlwaysSkip').then((result) => {
      if (result !== null) {
        this.isAlwaysSkip = result
      }
    })
  }

  build() {
    Row() {
      Text($r('app.string.always_skip_login'))
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: $$this.isAlwaysSkip })
        .onChange((isOn: boolean) => {
          this.preference.setValue<boolean>('isAlwaysSkip', this.isAlwaysSkip)
        })
        .width($r('app.float.toggle_width'))
    }
    .width('100%')
  }
}

@Component
export struct DarkModeSetting {
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageProp('currentColorMode') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  @State darkModeConfig: DarkModeSettingsConfig =
    AppStorage.get<DarkModeSettingsConfig>('darkModeConfig') || new DarkModeSettingsConfig();
  @State isOn: boolean = false;
  private darkModeUtil: DarkModeUtil = DarkModeUtil.getInstance();

  aboutToAppear(): void {

  }

  build() {
    Row() {
      Text($r('app.string.dark_mode'))
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: this.darkModeConfig.switchType === DarkModeType.ALL_DAY })
        .onChange((isOn: boolean) => {
          if (isOn) {
            this.darkModeConfig.switchType = DarkModeType.ALL_DAY
            this.darkModeUtil.saveDarkModeSettingsConfig(this.darkModeConfig)
          } else {
            this.darkModeConfig.switchType = DarkModeType.FOLLOW_UP
            this.darkModeUtil.saveDarkModeSettingsConfig(this.darkModeConfig)
          }
        })
        .width($r('app.float.toggle_width'))
    }
    .width('100%')
  }
}

@Component
export struct DarkModeSettingCard {
  @Consume('settingPathStack') settingPathStack: NavPathStack;
  @StorageProp('currentBreakPoint') currentBreakpoint: string = BreakPointTypeEnum.MD;
  @StorageProp('darkModeConfig') darkModeConfig: DarkModeSettingsConfig = new DarkModeSettingsConfig();

  build() {
    Column() {
      Row() {
        Text($r('app.string.dark_mode'))
          .layoutWeight(1)
        Blank()
        Text(this.darkModeConfig.switchType === DarkModeType.TIMED ? $r('app.string.dark_mode_timed') :
          (this.darkModeConfig.switchType === DarkModeType.ALL_DAY ? $r('app.string.dark_mode_all_day') :
          $r('app.string.dark_mode_follow_up')))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.ohos_id_color_text_tertiary')])
          .fontSize($r('app.float.nav_title_font_size'))
      }
      .width('100%')
    }
    .padding($r('app.float.ss_padding_margin'))
    .onClick(() => {
      this.settingPathStack.pushPathByName('DarkModeConfigView', undefined)
    })
  }
}