import { TopNavigationView } from '@ohos/uicomponents';
import { BreakPointTypeEnum } from '@ohos/utils';
import { DarkModeSettingCard, SkipLoginSetting } from '../component/SettingComponent';
import { UserHead } from '../component/UserComponent';

@Component
export struct SettingView {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Consume('settingPathStack') settingPathStack: NavPathStack;
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;

  onDestinationBack(): void {
    this.appPathStack.pop()
  }

  build() {
    NavDestination() {
      Navigation(this.settingPathStack) {
        TopNavigationView({
          title: $r('app.string.setting'),
          onBackClick: this.currentBreakPoint === BreakPointTypeEnum.SM ? () => this.onDestinationBack() : undefined
        })

        Column({ space: 20 }) {
          UserAccountSetting()
          ApplicationSetting()
        }
        .padding(
          {
            left: $r('app.float.lg_padding_margin'),
            right: $r('app.float.lg_padding_margin'),
            top: $r('app.float.ss_padding_margin')
          })
        .layoutWeight(1)

      }
      .hideTitleBar(true)
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
  }
}

@Component
struct UserAccountSetting {
  @Consume('settingPathStack') settingPathStack: NavPathStack;

  build() {
    Row() {
      UserHead()
        .layoutWeight(1)
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontColor([$r('sys.color.ohos_id_color_text_tertiary')])
        .fontSize($r('app.float.nav_title_font_size'))
    }
    .onClick(() => {
      this.settingPathStack.pushPathByName('AccountView', undefined);
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .width('100%')
    .borderRadius($r('app.float.light_border_radius'))
    .padding({
      left: $r('app.float.sm_padding_margin'),
      top: $r('app.float.lg_padding_margin'),
      right: $r('app.float.sm_padding_margin'),
      bottom: $r('app.float.lg_padding_margin')
    })
  }
}

@Component
struct ApplicationSetting {
  build() {
    Column({ space: 5 }) {
      Text($r('app.string.application_setting'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
      Column({ space: 5 }) {
        Row() {
          SkipLoginSetting()
        }
        .height($r('app.float.app_setting_item_height'))
        .width('100%')

        Divider()
        Row() {
          DarkModeSettingCard()
        }
        .height($r('app.float.app_setting_item_height'))
        .width('100%')
      }
      .backgroundColor($r('sys.color.comp_background_primary'))
      .width('100%')
      .borderRadius($r('app.float.light_border_radius'))
      .padding({
        left: $r('app.float.sm_padding_margin'),
        top: $r('app.float.lg_padding_margin'),
        right: $r('app.float.sm_padding_margin'),
        bottom: $r('app.float.lg_padding_margin')
      })
    }
  }
}

@Builder
export function SettingViewBuilder() {
  SettingView()
}