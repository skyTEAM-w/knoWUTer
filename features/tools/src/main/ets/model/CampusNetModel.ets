import { UserAccount } from '@feature/mine';
import { PreferencesUtil } from '@ohos/datastore';
import { CampusNetStatus, EventType } from '@ohos/utils';
import { CampusNetFunc } from '../service/CampusNetFunc';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

const NET_ACCOUNT = 'net_account'

@Observed
export class CampusNetModel {
  private static instance: CampusNetModel;
  userNetAccount: UserAccount = new UserAccount();
  private funNetwork: CampusNetFunc;
  private preference: PreferencesUtil;
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;

  constructor() {
    this.funNetwork = new CampusNetFunc();
    this.preference = PreferencesUtil.getInstance()
    this.eventHub.on(EventType.NET_ACCOUNT_CHANGE, () => {
      this.getUserAccount();
    })
  }

  public static getInstance() {
    if (!CampusNetModel.instance) {
      CampusNetModel.instance = new CampusNetModel();
    }
    return CampusNetModel.instance
  }

  public login(userAccount: UserAccount) {
    this.funNetwork.getNasId().then((nasId) => {
      this.funNetwork.login(userAccount.username, userAccount.password, nasId).then((netStatus: CampusNetStatus) => {
        switch (netStatus) {
          case CampusNetStatus.AUTH_SUCCESS: {
            promptAction.showToast({ message: $r('app.string.campus_net_login_successfully') })
            break;
          }
          case CampusNetStatus.AUTH_FAILED: {
            promptAction.showToast({ message: $r('app.string.campus_net_auth_failed') })
            break;
          }
          case CampusNetStatus.REQUIRE_CODE: {
            promptAction.showToast({ message: $r('app.string.campus_net_require_code') })
            break;
          }
          case CampusNetStatus.OTHER: {
            promptAction.showDialog({
              message: $r('app.string.campus_net_other'),
              title: $r('app.string.net_login_failed')
            })
            break;
          }
        }
      })
    })
  }

  public logout() {
    this.funNetwork.logout().then((netStatus: CampusNetStatus) => {
      if (netStatus === CampusNetStatus.LOGOUT_SUCCESS) {
        promptAction.showToast({ message: $r('app.string.campus_net_logout_successfully') })
      }
    })
  }

  public getUserAccount() {
    this.preference.hasValue(NET_ACCOUNT).then((result) => {
      if (result) {
        this.preference.getValue<UserAccount>(NET_ACCOUNT).then((account) => {
          this.userNetAccount = account as UserAccount;
        })
      } else {
        this.userNetAccount = new UserAccount();
      }
    })
  }

  public saveUserAccount() {
    this.preference.setValue<UserAccount>(NET_ACCOUNT, this.userNetAccount).then(() => {
      this.eventHub.emit(EventType.NET_ACCOUNT_CHANGE)
    })
  }
}