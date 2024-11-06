import { webview } from '@kit.ArkWeb';
import { NavigationTitleBar } from '@ohos/uicomponents';

@Component
export struct Home {
  @StorageLink('Cookie') cookie: string = '';
  private webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Navigation() {
      Column() {
        Blank().height($r('app.float.navigation_title_bar_half_height'))
        Scroll() {
          Column() {
            Web({ src: "https://zhlgd.whut.edu.cn/tpass/login", controller: this.webviewController })
              .domStorageAccess(true)
              .javaScriptAccess(true)
              .onPageEnd(() => {
                this.cookie =
                  webview.WebCookieManager.fetchCookieSync("https://zhlgd.whut.edu.cn/tp_up/view?m=up#act=portal/viewhome")
                    .toString();
                console.info(this.cookie);
              })
          }

        }
        .scrollBar(BarState.Off)

      }
    }
    .mode(NavigationMode.Stack)
    .title({
      builder: NavigationTitleBar($r('app.string.text_home')),
      height: $r('app.float.navigation_title_bar_height')
    }, {
      barStyle: BarStyle.STACK
    })
    .titleMode(NavigationTitleMode.Mini)
    .hideTitleBar(false)
    .hideBackButton(true)

  }
}
