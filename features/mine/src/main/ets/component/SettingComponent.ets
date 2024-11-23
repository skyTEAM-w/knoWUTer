import { PreferencesUtil } from '@ohos/datastore';

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
export struct UsePasswordAuto {
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