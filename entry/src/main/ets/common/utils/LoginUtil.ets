import axios from '@ohos/axios';
import { common } from '@kit.AbilityKit';

export class LoginUtil {
  private static instance: LoginUtil;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  public static getInstance(): LoginUtil {
    if (!LoginUtil.instance) {
      LoginUtil.instance = new LoginUtil();
    }
    return LoginUtil.instance;
  }

  public LoginZhlgd() {

  }
}