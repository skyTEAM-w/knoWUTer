import { window } from "@kit.ArkUI";
import { BusinessError } from "@kit.BasicServicesKit";

export class  WindowUtil {
  public static requestFullScreen(windowStage: window.WindowStage, context: Context):void {
    windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
      if (err.code) {
        console.error('Failed to obtain the main window. Cause: ' + JSON.stringify(err));
        return;
      }

      let windowClass: window.Window = data;
      console.info('Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));

      let isLayoutFullScreen = true;
      try {
        let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let naviBarArea: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)

        AppStorage.setOrCreate<number>('statusBarHeight', px2vp(area.topRect.height));
        AppStorage.setOrCreate<number>('naviIndicatorHeight', px2vp(naviBarArea.bottomRect.height));

        if (area.topRect.height > 0) {
          let promise: Promise<void> = windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
          promise.then(() => {
            console.info('Succeeded in setting the window layout to full-screen mode.');
          }).catch((err: BusinessError) => {
            console.info('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
          });
        }
      } catch {
        console.error('Failed to set the window layout to full-screen mode. ')
      }
    });
  }
}