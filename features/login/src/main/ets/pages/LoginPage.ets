import { webview } from '@kit.ArkWeb';
import { UrlConstants } from '../constants/UrlConstants';
import { UserModel } from '@feature/mine';
import { CookieUtil } from '@ohos/util';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { AccessModel } from '../model/AccessModel';
import { PreferencesUtil } from '@ohos/datastore';

@Entry({ routeName: 'LoginPage' })
@Component
struct LoginPage {
  @StorageLink('bottomTabIndex') bottomTabIndex: number = 2;
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private userModel: UserModel = UserModel.getInstance();
  private accessModel: AccessModel = AccessModel.getInstance();
  private preference: PreferencesUtil = PreferencesUtil.getInstance();

  build() {
    Column() {
      Web({
        src: UrlConstants.ZHLGD_URL,
        controller: this.webViewController
      })
        .onPageEnd(() => {
          this.accessModel.getUsername(this.webViewController).then((username) => {
            this.preference.setValue<string>('username', username);
            let cookie =
              webview.WebCookieManager.fetchCookieSync('https://zhlgd.whut.edu.cn/tp_up/view?m=up#act=portal/viewhome');
            CookieUtil.getInstance().saveZHLGDCookie(cookie)
            this.userModel.checkIsLogged().then((result) => {
              if (result) {
                this.bottomTabIndex = 2;
                const bundleName = (getContext(this) as common.UIAbilityContext).applicationInfo.name;
                router.replaceUrl({
                  url: `@bundle:${bundleName}/entry/ets/pages/MainPage`
                })
              }
            })
          });
        })
    }
  }
}