import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

const TAG = '[WindowUtil]'

export class WindowUtil {
  public static requestFullScreen(windowStage: window.WindowStage, context: Context): void {
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
        let naviBarArea: window.AvoidArea =
          windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)

        AppStorage.setOrCreate<number>('statusBarHeight', px2vp(area.topRect.height));
        AppStorage.setOrCreate<number>('naviIndicatorHeight', px2vp(naviBarArea.bottomRect.height));
        WindowUtil.getDeviceSize(context);
        if (area.topRect.height > 0) {
          let promise: Promise<void> = windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
          promise.then(() => {
            console.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
          }).catch((err: BusinessError) => {
            console.info(TAG, 'Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
          });
        }
      } catch {
        console.error('Failed to set the window layout to full-screen mode. ')
      }
    });
  }

  static getDeviceSize(context: Context): void {
    window.getLastWindow(context).then((data: window.Window) => {
      let properties = data.getWindowProperties();
      AppStorage.setOrCreate<number>('deviceHeight', px2vp(properties.windowRect.height));
      AppStorage.setOrCreate<number>('deviceWidth', px2vp(properties.windowRect.width));
      console.debug(px2vp(properties.windowRect.width).toString())
    });
  }

  static setMainWindowPortrait(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        console.error(`MainWindowClass is undefined`);
        return;
      }
      windowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
    });
  }

  static setMainWindowRestricted(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        console.error(`MainWindowClass is undefined`);
        return;
      }
      windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    });
  }

  public static updateStatusBarColor(context: common.BaseContext, isDark: boolean) {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      try {
        windowClass.setWindowSystemBarProperties({ statusBarContentColor: isDark ? '#FFFFFF' : '#000000' }, (err) => {
          if (err.code) {
            console.error(TAG, 'Failed to set the system bar properties. Cause: ' + JSON.stringify(err));
            return;
          }
          console.info(TAG, 'Succeeded in setting the system bar properties.');
        });
      } catch (exception) {
        console.error(TAG, 'Failed to set the system bar properties. Cause: ' + JSON.stringify(exception));
      }
    });
  }
}