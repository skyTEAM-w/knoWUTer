import { ConfigurationConstant } from '@kit.AbilityKit';
import { TopNavigationView } from '@ohos/uicomponents';
import {
  BreakPointType,
  BreakPointTypeEnum,
  CommonConstants,
  DarkModeSettingsConfig,
  DarkModeType,
  DarkModeUtil,
  WindowUtil
} from '@ohos/utils';
import { TimeSelectDialog } from '../component/TimeSelectDialog';

@Styles
function itemStyle() {
  .padding({
    top: $r('app.float.ss_padding_margin'),
    right: $r('app.float.md_padding_margin'),
    bottom: $r('app.float.ss_padding_margin'),
    left: $r('app.float.md_padding_margin')
  })
  .borderRadius($r('app.float.large_border_radius'))
  .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
}

@Component
struct DarkModeConfigView {
  @Consume('settingPathStack') settingPathStack: NavPathStack;
  settingsUtil: DarkModeUtil = DarkModeUtil.getInstance();
  @StorageProp('currentBreakPoint') currentBreakpoint: string = BreakPointTypeEnum.MD;
  @StorageProp('currentColorMode') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  @State darkModeConfig: DarkModeSettingsConfig =
    AppStorage.get<DarkModeSettingsConfig>('darkModeConfig') || new DarkModeSettingsConfig();
  @State isFollowUp: boolean = (this.darkModeConfig.switchType === DarkModeType.FOLLOW_UP);
  @State dialogType: number = 0;
  @State private dialogSelectTime: Date = new Date();
  timeDialog: CustomDialogController = new CustomDialogController({
    builder: TimeSelectDialog({
      currentBreakpoint: this.currentBreakpoint,
      confirm: () => {
        if (this.dialogType === 0) {
          this.darkModeConfig.startTime = this.dialogSelectTime;
        } else {
          this.darkModeConfig.endTime = this.dialogSelectTime;
        }
        this.saveTimeFunc();
      },
      compareTime: this.dialogType === 0 ? this.darkModeConfig.endTime : this.darkModeConfig.startTime,
      selectedTime: this.dialogSelectTime,
      type: this.dialogType
    }),
    customStyle: true,
    alignment: DialogAlignment.Center,
  })

  saveTimeFunc(): void {
    this.settingsUtil.saveDarkModeSettingsConfig(this.darkModeConfig);
    if (this.currentBreakpoint === BreakPointTypeEnum.SM) {
      WindowUtil.updateStatusBarColor(getContext(this),
        this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    }
  }

  onBackPress(): boolean | void {
    this.settingPathStack.pop();
  }

  handleTimeDialog(type: number) {
    this.dialogType = type;
    this.dialogSelectTime = (type === 0 ? this.darkModeConfig.startTime : this.darkModeConfig.endTime);
    this.timeDialog.open();
  }

  build() {
    NavDestination() {
      TopNavigationView({
        title: $r('app.string.dark_mode'),
        onBackClick: this.currentBreakpoint === BreakPointTypeEnum.SM ? () => this.onBackPress() : undefined
      })
      Column() {
        Text($r('app.string.dark_mode_settings_timed_card_remark'))
          .fontSize($r('app.float.title_font_size'))
          .padding({ right: $r('app.float.text_right_margin') })
          .width(CommonConstants.FULL_PERCENT)
          .visibility(this.isFollowUp ? Visibility.None : Visibility.Visible)
          .height($r('app.float.button_height'))
          .margin({
            top: new BreakPointType({
              sm: $r('app.float.pad_image_top'),
              md: $r('app.float.lg_padding_margin'),
              lg: $r('app.float.view_count_icon_width')
            }).getValue(this.currentBreakpoint),
            bottom: this.currentBreakpoint === BreakPointTypeEnum.SM ? $r('app.float.xl_padding_margin') :
            $r('app.float.lg_padding_margin')
          })
        List({ space: 12 }) {
          ListItem() {
            DarkModeSettingItem({
              isOn: this.darkModeConfig.switchType === DarkModeType.FOLLOW_UP,
              title: $r('app.string.dark_mode_follow_up'),
              onChangeAction: (isOn: boolean) => {
                this.isFollowUp = isOn;
                if (isOn) {
                  this.darkModeConfig.switchType = DarkModeType.FOLLOW_UP;
                  this.saveTimeFunc();
                }
              }
            })
          }
          .itemStyle()

          if (!this.isFollowUp) {
            ListItem() {
              Column() {
                DarkModeSettingItem({
                  isOn: this.darkModeConfig.switchType === DarkModeType.TIMED,
                  title: $r('app.string.dark_mode_timed'),
                  onChangeAction: (isOn: boolean) => {
                    if (isOn) {
                      this.darkModeConfig.switchType = DarkModeType.TIMED;
                      this.saveTimeFunc();
                    } else if (this.darkModeConfig.switchType == DarkModeType.TIMED) {
                      this.darkModeConfig.switchType = DarkModeType.FOLLOW_UP;
                    }
                  }
                })
                if (this.darkModeConfig.switchType === DarkModeType.TIMED) {
                  Divider()
                  TimeSettingItem({
                    type: 0,
                    isNextDay: false,
                    selectedTime: this.darkModeConfig.startTime
                  })
                    .onClick(() => this.handleTimeDialog(0))
                  TimeSettingItem({
                    type: 1,
                    isNextDay: this.darkModeConfig.endTime < this.darkModeConfig.startTime,
                    selectedTime: this.darkModeConfig.endTime
                  })
                    .onClick(() => this.handleTimeDialog(1))
                }
              }
            }
            .itemStyle()

            ListItem() {
              DarkModeSettingItem({
                isOn: this.darkModeConfig.switchType === DarkModeType.ALL_DAY,
                title: $r('app.string.dark_mode_all_day'),
                onChangeAction: (isOn: boolean) => {
                  if (isOn) {
                    this.darkModeConfig.switchType = DarkModeType.ALL_DAY;
                    this.saveTimeFunc();
                  } else if (this.darkModeConfig.switchType == DarkModeType.ALL_DAY) {
                    this.darkModeConfig.switchType = DarkModeType.FOLLOW_UP;
                  }
                }
              })
            }
            .itemStyle()
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
      }
      .layoutWeight(1)
      .padding(this.currentBreakpoint === BreakPointTypeEnum.LG ?
        { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 4 } :
        { left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin'), top: 4 })
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .hideTitleBar(true)
  }
}

function getTimeDesc(selectedTime: Date): Resource {
  let selectedHour: number = selectedTime.getHours();
  let selectedMinute: string = String(selectedTime.getMinutes()).padStart(2, '0');
  let timeStr: string = (String(selectedHour > 12 ? selectedHour - 12 : selectedHour)) + ':' + selectedMinute;
  if (selectedHour <= 4) {
    return $r('app.string.early_morning', timeStr);
  }
  if (selectedHour <= 8) {
    return $r('app.string.in_morning', timeStr);
  }
  if (selectedHour < 11) {
    return $r('app.string.mornings', timeStr);
  }
  if (selectedHour < 13) {
    return $r('app.string.noons', timeStr);
  }
  if (selectedHour < 18) {
    return $r('app.string.afternoons', timeStr);
  }
  if (selectedHour <= 22) {
    return $r('app.string.nighttime', timeStr);
  }
  return $r('app.string.midnight', timeStr);
}

@Component
struct TimeSettingItem {
  @Prop isNextDay: boolean = false;
  @Prop type: number = 0;
  @Prop selectedTime: Date = new Date();

  build() {
    Row() {
      Text(this.type === 0 ? $r('app.string.start_time_des') : $r('app.string.end_time_des'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .height(22)
      Blank()
      if (this.isNextDay === true) {
        Text($r('app.string.next_day'))
          .fontSize($r('app.float.title_font_size'))
          .height(18)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      }
      Text(getTimeDesc(this.selectedTime))
        .fontSize($r('app.float.title_font_size'))
        .height(18)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontColor([$r('sys.color.ohos_id_color_text_tertiary')])
        .fontSize($r('app.float.nav_title_font_size'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(44)
  }
}

@Component
struct DarkModeSettingItem {
  title: ResourceStr = '';
  onChangeAction?: (isOn: boolean) => void;
  @Prop isOn: boolean = false;

  build() {
    Row() {
      Text(this.title)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))

      Toggle({ type: ToggleType.Switch, isOn: this.isOn })
        .onChange((isOn: boolean) => {
          this.onChangeAction?.(isOn);
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.mine_navigation_header_height'))
  }
}

@Builder
export function DarkModeConfigViewBuilder(): void {
  DarkModeConfigView();
}