export class AccessModel {
  private static instance: AccessModel;

  public static getInstance() {
    if (!AccessModel.instance) {
      AccessModel.instance = new AccessModel();
    }
    return AccessModel.instance;
  }
}