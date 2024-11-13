import { PreferencesUtil } from '@ohos/datastore';

const CWSF_COOKIE = 'cwsf_cookie';

const JWXT_COOKIE = 'jwxt_cookie';

export class CookieUtil {
  private static instance: CookieUtil;
  private preferenceUtil: PreferencesUtil = PreferencesUtil.getInstance();

  public static getInstance() {
    if (!CookieUtil.instance) {
      CookieUtil.instance = new CookieUtil();
    }
    return CookieUtil.instance;
  }

  public saveCWSFCookie(cookie: string) {
    this.preferenceUtil.setValue<string>(CWSF_COOKIE, cookie);
    AppStorage.setOrCreate('fee_cookie', cookie);
  }

  public saveJWXTCookie(cookie: string) {
    this.preferenceUtil.setValue<string>(JWXT_COOKIE, cookie);
    AppStorage.setOrCreate('schedule_cookie', cookie);
  }

  public checkCWSFCookie(): void {
    this.preferenceUtil.getValue<string>(CWSF_COOKIE).then((config: string | null) => {
      if (!config) {
        config = '';
      }
      AppStorage.setOrCreate('fee_cookie', config);
    })
  }

  public checkJWXTCookie(): void {
    this.preferenceUtil.getValue<string>(JWXT_COOKIE).then((config: string | null) => {
      if (!config) {
        config = '';
      }
      AppStorage.setOrCreate('schedule_cookie', config);
    })
  }

  public checkAllCookies(): void {
    this.checkCWSFCookie();
    this.checkJWXTCookie();
  }
}