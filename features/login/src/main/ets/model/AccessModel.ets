import { webview } from '@kit.ArkWeb';

export class AccessModel {
  private static instance: AccessModel;

  public static getInstance() {
    if (!AccessModel.instance) {
      AccessModel.instance = new AccessModel();
    }
    return AccessModel.instance;
  }

  public getUsername(webViewController: webview.WebviewController) {
    return new Promise((resolve: (value: string | PromiseLike<string>) => void, reject) => {
      webViewController.runJavaScript('document.getElementById("user-btn-01").outerText').then((result) => {
        if (result !== 'null') {
          console.debug(result.trim())
          resolve(result)
        }
      })
    })
  }
}