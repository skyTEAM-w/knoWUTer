import { webview } from '@kit.ArkWeb';
import { NavigationTitleBar } from '@ohos/uicomponents';
import { BreakPointType, BreakPointTypeEnum } from '@ohos/utils';
import { AcademicCalender } from '../components/AcademicCalendarComponent';
import { ElectricityInquiryTool } from '../components/ElectricityInquiryComponent';

@Component
export struct Tools {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('Cookie') cookie: string = '';
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
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
    .padding({ top: AppStorage.get<number>('statusBarHeight') })
  }

  build() {
    Navigation() {
      Column()
        .height($r('app.float.navigation_title_bar_height'))
        .padding({ top: AppStorage.get<number>('statusBarHeight') })
      WaterFlow() {
        FlowItem() {
          ElectricityInquiryTool({ webViewController: this.webviewController })
        }
        .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ? { right: 5, top: 5, bottom: 5 } : 0)

        FlowItem() {
          AcademicCalender()
        }
        .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ? { right: 5, top: 5, bottom: 5 } : 0)

      }
      .columnsTemplate(new BreakPointType({
        sm: '1fr',
        md: '1fr 1fr',
        lg: '1fr 1fr 1fr'
      }).getValue(this.currentBreakPoint))
      .columnsGap(10)
      .rowsGap(10)
      .padding({ left: 16, right: 16 })

    }
    .mode(NavigationMode.Stack)
    .title({
      builder: NavigationTitleBar($r('app.string.text_tools')),
      height: $r('app.float.navigation_title_bar_height')
    }, {
      barStyle: BarStyle.STACK
    })
    .hideTitleBar(false)
    .hideBackButton(true)

  }
}
