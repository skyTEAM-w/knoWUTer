import { PreferencesUtil } from '@ohos/datastore';
import { UserNetFunc } from '../service/UserNetFunc';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { EventType } from '@ohos/utils';

const ZHLGD_COOKIE = 'zhlgd_cookie';

const TAG = '[UserModel]'

@Observed
export class UserModel {
  private static instance: UserModel;
  private funNetwork: UserNetFunc;
  private preferences: PreferencesUtil = PreferencesUtil.getInstance();
  numberOfItemReview: number = 0;
  numberOfItemInProgress: number = 0;
  numberOfItemScore: number = 0;
  numberOfItemClosing: number = 0;
  private eventHub: common.EventHub;

  constructor() {
    this.funNetwork = new UserNetFunc();
    this.eventHub = (getContext(this) as common.UIAbilityContext).eventHub;
    this.eventHub.on(EventType.REFRESH_HALL, () => {
      this.getWorkHallResourse()
    })
  }

  public static getInstance() {
    if (!UserModel.instance) {
      UserModel.instance = new UserModel();
    }
    return UserModel.instance
  }

  getWorkHallResourse() {
    this.preferences.getValue<string>(ZHLGD_COOKIE).then((cookie) => {
      this.funNetwork.getReviewItemNum(cookie as string).then((num) => {
        this.numberOfItemReview = num;
      })
      this.funNetwork.getProgressItemNum(cookie as string).then((num) => {
        this.numberOfItemInProgress = num;
      })
      this.funNetwork.getScoreItemNum((cookie as string)).then((num) => {
        this.numberOfItemScore = num;
      })
      this.funNetwork.getClosedItemNum(cookie as string).then((num) => {
        this.numberOfItemClosing = num;
      })
      this.eventHub.emit(EventType.REFRESH_HALL_END)
    })
  }

  checkUsername() {
    this.preferences.hasValue('username').then((result) => {
      if (result) {
        this.preferences.getValue<string>('username').then((username) => {
          console.debug(TAG, username)
          AppStorage.setOrCreate<string>('username', username?.replaceAll(' ', '').replaceAll('\"', ''))
        })
      }
    })
  }

  checkIsLogged() {
    return new Promise((resolve: (value: boolean | PromiseLike<boolean>) => void, reject) => {
      this.preferences.getValue<string>(ZHLGD_COOKIE).then((cookie) => {
        this.funNetwork.checkZhlgdIsLogged(cookie as string).then((result) => {
          this.preferences.setValue<boolean>('isLogged', result)
          AppStorage.setOrCreate<boolean>('isLogged', result)
          console.debug(TAG, result)
          resolve(result)
        }).catch((error: BusinessError) => {
          reject(error)
        })
      })
    })
  }
}