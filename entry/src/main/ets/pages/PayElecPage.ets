import { webview } from '@kit.ArkWeb'
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
export struct  PayElcWeb{
  private webviewController: webview.WebviewController = new webview.WebviewController();
  private webResult: string = '';

  aboutToAppear(): void {
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  aboutToDisappear(): void {
    this.webviewController.loadUrl('http://cwsf.whut.edu.cn/nyyPayElecPages51274E035');
  }

  build() {
    Column(){
      Stack({alignContent: Alignment.BottomEnd}){
        Web({
          src: 'http://cwsf.whut.edu.cn/nyyPayElecPages51274E035',
          controller: this.webviewController
        })
          .javaScriptAccess(true)
        Button()
          .onClick(() => {
            this.webviewController.runJavaScript('var selectElement = document.getElementById("areaid");\n' +
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
                this.webResult = result;
                console.info(`The test() return value is: ${this.webResult}`);
                AlertDialog.show({
                  message: this.webResult + this.webviewController.getUrl()
                })
              }

            })
          })

      }

    }

  }
}