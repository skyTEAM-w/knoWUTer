import axios from "@ohos/axios";
import { common } from "@kit.AbilityKit";

export class LoginUtil {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private static instance: LoginUtil;

  public static getInstance(): LoginUtil {
    if (!LoginUtil.instance){
      LoginUtil.instance = new LoginUtil();
    }
    return LoginUtil.instance;
  }

  public LoginZhlgd(){

  }

}