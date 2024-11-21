import { TopNavigationView } from '@ohos/uicomponents';

@Component
export struct SettingView {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Consume('settingPathStack') settingPathStack: NavPathStack;

  onDestinationBack(): void {
    this.appPathStack.pop()
  }

  build() {
    NavDestination() {
      Navigation(this.settingPathStack) {
        TopNavigationView({
          title: $r('app.string.setting'),
          onBackClick: () => this.onDestinationBack()
        })

      }
      .hideTitleBar(true)
    }
    .hideTitleBar(true)
  }
}

@Builder
export function SettingViewBuilder() {
  SettingView()
}