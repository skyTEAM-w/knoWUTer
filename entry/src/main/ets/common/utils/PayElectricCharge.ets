import { webview } from '@kit.ArkWeb'
import { DormitoryLocation } from '../../model/DormitoryLocation'
import { BusinessError } from '@kit.BasicServicesKit';

export function getElectricCharge(webviewController: webview.WebviewController, dormitoryLocation: DormitoryLocation) {
  webviewController.loadUrl('http://cwsf.whut.edu.cn/nyyPayElecPages51274E035');
  webviewController.runJavaScript('var selectElement = document.getElementById("areaid");\n' +
    '            selectElement.value = "0001"; // 修改选项\n' +
    '\n' +
    '            // 创建一个新的事件\n' +
    '            var event = new Event(\'change\');\n' +
    '            // 手动触发 onchange 事件\n' +
    '            selectElement.dispatchEvent(event);', (error, result) => {
    if (error) {
      console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
      return;
    }
    if (result) {
      let webResult = result;
      console.info(`The test() return value is: ${webResult}`);
      AlertDialog.show({
        message: webResult + webviewController.getUrl()
      })
    }
  })

}