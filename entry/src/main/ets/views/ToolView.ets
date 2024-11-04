import { webview } from '@kit.ArkWeb';
import { NavigationTitleBar } from '../common/components/NavigationTitleBar';
import { getElectricCharge } from '../common/utils/PayElectricCharge';
import { AcademicCalender } from '../components/AcademicCalendarComponent';
import { ElectricityInquiryTool } from '../components/ElectricityInquiryComponent';
import { DormitoryLocation } from '../common/model/DormitoryLocation';

@Component
export struct Tools {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('Cookie') cookie: string = '';
  private webviewController: webview.WebviewController = new webview.WebviewController();
  private webResult: string = '';

  @Builder
  NavigationTitle(title: ResourceStr) {
    Column() {
      Text(title)
        .fontSize($r('app.float.component_title_size'))
        .fontWeight(700)
        .width('100%')
        .fontFamily('HarmonyHeiTi-Bold')
        .lineHeight(33)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .renderFit(RenderFit.CENTER)
    .backgroundBlurStyle(BlurStyle.Thick)
    .padding({top: AppStorage.get<number>('statusBarHeight')})
  }

  build() {
    Navigation() {
      List({space: 10}) {
        ListItem() {
          Column()
            .height($r('app.float.navigation_title_bar_half_height'))
        }
        ListItem() {
          ElectricityInquiryTool({webViewController: this.webviewController})
        }
        ListItem() {
          AcademicCalender()
        }
      }
      .padding({ left: 16, right: 16 })

    }
    .mode(NavigationMode.Stack)
    .title({builder: NavigationTitleBar($r('app.string.text_tools')),
      height: $r('app.float.navigation_title_bar_height')}, {
      barStyle: BarStyle.STACK
    })
    .titleMode(NavigationTitleMode.Mini)
    .hideTitleBar(false)
    .hideBackButton(true)

  }
}
