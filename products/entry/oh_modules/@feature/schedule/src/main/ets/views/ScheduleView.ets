import { NavigationTitleBar } from '@ohos/uicomponents';

@Component
export struct Schedule {
  build() {
    Navigation() {
      Column() {
      }
    }

    .hideTitleBar(true)
    .hideBackButton(true)

  }
}