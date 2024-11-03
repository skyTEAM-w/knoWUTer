export class LoginUtil {
  private static instance: LoginUtil;

  public static getInstance(): LoginUtil {
    if (!LoginUtil.instance){
      LoginUtil.instance = new LoginUtil();
    }
    return LoginUtil.instance;
  }


}