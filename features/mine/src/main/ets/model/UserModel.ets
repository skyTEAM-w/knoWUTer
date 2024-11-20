import { PreferencesUtil } from '@ohos/datastore';
import { UserNetFunc } from '../service/UserNetFunc';
import { BusinessError } from '@kit.BasicServicesKit';

const ZHLGD_COOKIE = 'zhlgd_cookie';

@Observed
export class UserModel {
  private static instance: UserModel;
  private funNetwork: UserNetFunc;
  private preferences: PreferencesUtil = PreferencesUtil.getInstance();

  constructor() {
    this.funNetwork = new UserNetFunc();
  }

  public static getInstance() {
    if (!UserModel.instance) {
      UserModel.instance = new UserModel();
    }
    return UserModel.instance
  }

  checkUsername() {
    this.preferences.hasValue('username').then((result) => {
      if (result) {
        this.preferences.getValue<string>('username').then((username) => {
          AppStorage.setOrCreate<string>('username', username)
        })
      }
    })
  }

  checkIsLogged() {
    return new Promise((resolve: (value: boolean | PromiseLike<boolean>) => void, reject) => {
      this.preferences.getValue<string>(ZHLGD_COOKIE).then((cookie) => {
        this.funNetwork.checkZhlgdIsLogged(cookie as string).then((result) => {
          resolve(result)
        }).catch((error: BusinessError) => {
          reject(error)
        })
      })
    })
  }
}