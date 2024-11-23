import { PreferencesUtil } from '@ohos/datastore';
import { UserNetFunc } from '../service/UserNetFunc';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { EventType } from '@ohos/utils';
import { UserAccount } from './UserAccount';

const ZHLGD_COOKIE = 'zhlgd_cookie';
const NET_ACCOUNT = 'net_account';

const TAG = '[UserModel]'

@Observed
export class UserModel {
  private static instance: UserModel;
  numberOfItemReview: number = 0;
  numberOfItemInProgress: number = 0;
  numberOfItemScore: number = 0;
  numberOfItemClosing: number = 0;
  numberOfBook: number = 0;
  cardMoney: number = 0;
  campusNetAccount: UserAccount = new UserAccount();
  private funNetwork: UserNetFunc;
  private preferences: PreferencesUtil = PreferencesUtil.getInstance();
  private eventHub: common.EventHub;

  constructor() {
    this.funNetwork = new UserNetFunc();
    this.getWorkHallResourse();
    this.getUnbackBook();
    this.getCardMoney();
    this.getCampusNetAccount();
    this.eventHub = (getContext(this) as common.UIAbilityContext).eventHub;
    this.eventHub.on(EventType.REFRESH_HALL, () => {
      this.getWorkHallResourse();
      this.getUnbackBook();
      this.getCardMoney();
      this.getCampusNetAccount();
      this.eventHub.emit(EventType.REFRESH_HALL_END)
    })
    this.eventHub.on(EventType.NET_ACCOUNT_CHANGE, () => {
      this.getCampusNetAccount()
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
      }).catch(() => {
        // this.numberOfItemReview = 0;
      })
      this.funNetwork.getProgressItemNum(cookie as string).then((num) => {
        this.numberOfItemInProgress = num;
      }).catch(() => {
        // this.numberOfItemInProgress = 0;
      })
      this.funNetwork.getScoreItemNum((cookie as string)).then((num) => {
        this.numberOfItemScore = num;
      }).catch(() => {
        this.numberOfItemScore = 0;
      })
      this.funNetwork.getClosedItemNum(cookie as string).then((num) => {
        this.numberOfItemClosing = num;
        console.debug(TAG, 'closed', num)
      }).catch(() => {
        this.numberOfItemClosing = 0;
        console.debug(TAG, 'logout closed', this.numberOfItemClosing)
      })
    })
  }

  getUnbackBook() {
    this.preferences.getValue<string>(ZHLGD_COOKIE).then((cookie) => {
      this.funNetwork.getBookNum(cookie as string).then((num) => {
        this.numberOfBook = num;
      })
    })
  }

  getCardMoney() {
    this.preferences.getValue<string>(ZHLGD_COOKIE).then((cookie) => {
      this.funNetwork.getCardMoney(cookie as string).then((num) => {
        this.cardMoney = num / 100.0;
      })
    })
  }

  getCampusNetAccount() {
    this.preferences.hasValue(NET_ACCOUNT).then((result) => {
      if (result) {
        this.preferences.getValue<UserAccount>(NET_ACCOUNT).then((account) => {
          this.campusNetAccount = account as UserAccount;
        })
      } else {
        this.campusNetAccount = new UserAccount();
      }
    })
  }

  logoutCurrentUser() {
    return new Promise((resolve: (value: void) => void, reject) => {
      this.preferences.deleteValue(ZHLGD_COOKIE).then(() => {
        AppStorage.setOrCreate<boolean>('isLogged', false);
        AppStorage.setOrCreate<string>(ZHLGD_COOKIE, '');
        resolve()
      }).catch((error: BusinessError) => {
        reject()
      })
    })
  }

  saveCampusNetAccount() {
    this.preferences.setValue<UserAccount>(NET_ACCOUNT, this.campusNetAccount).then(() => {
      this.eventHub.emit(EventType.NET_ACCOUNT_CHANGE)
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