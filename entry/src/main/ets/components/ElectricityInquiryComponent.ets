import { DBUtil } from "../common/utils/DBUtil";
import { importElectricity } from "../common/utils/PayElectricCharge";
import { ElectricityFeeUrl } from "../model/ElectricityFeeUrl";
import { ServiceBlockClass } from "../viewmodel/ServiceBlockClass";
import { ServiceBlocks } from "../views/ServiceView";

@Component
export struct ElectricityInquiryTool {
  @Consume('appPathStack') appPathStack: NavPathStack;

  jumpWebView() {
    this.appPathStack.pushPathByName('WebViewPage', new Object({
      webUrl: new ElectricityFeeUrl(),
      isImport: true,
      onDestinationBack: () => {
        this.appPathStack.pop();
        return false;
      }
    }))
  }

  build() {
    Row(){
      Button('导入')
        .onClick(() => this.jumpWebView())
      Button('查询数据库')
        .onClick(() => {
          DBUtil.getInstance().queryTable()
        })
    }

  }
}