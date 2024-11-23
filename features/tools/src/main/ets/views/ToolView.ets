import { webview } from '@kit.ArkWeb';
import { NavigationTitleBar } from '@ohos/uicomponents';
import { BreakPointType, BreakPointTypeEnum, CommonConstants } from '@ohos/utils';
import { AcademicCalender } from '../components/AcademicCalendarComponent';
import { CampusNetwork } from '../components/CampusNetwork';
import { ElectricityInquiryTool } from '../components/ElectricityInquiryComponent';
import { curves } from '@kit.ArkUI';

@Component
export struct Tools {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageProp('bottomTabIndex') @Watch('triggerAnimation') bottomTabIndex: number = 2;
  @StorageLink('Cookie') cookie: string = '';
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @State isThisTab: boolean = false;
  private webviewController: webview.WebviewController = new webview.WebviewController();
  private webResult: string = '';

  triggerAnimation() {
    this.isThisTab = this.bottomTabIndex === CommonConstants.TOOL_BOTTOM_INDEX
  }

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
          ElectricityInquiryTool()
        }
        .opacity(this.isThisTab ? 1 : 0)
        .scale(this.isThisTab ? { x: 1, y: 1 } : { x: 0.5, y: 0.5 })
        .animation({
          delay: CommonConstants.NORMAL_ANIMATION_DELAY,
          curve: curves.springMotion(CommonConstants.MEDIUM_ANIMATION_DURATION / 1000, 0.6)
        })
        .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ? { right: 5, top: 5, bottom: 5 } : 0)

        FlowItem() {
          AcademicCalender()
        }
        .opacity(this.isThisTab ? 1 : 0)
        .scale(this.isThisTab ? { x: 1, y: 1 } : { x: 0.5, y: 0.5 })
        .animation({
          delay: CommonConstants.NORMAL_ANIMATION_DELAY * 2,
          curve: curves.springMotion(CommonConstants.MEDIUM_ANIMATION_DURATION / 1000, 0.6)
        })
        .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ? { right: 5, top: 5, bottom: 5 } : 0)

        FlowItem() {
          CampusNetwork()
        }
        .opacity(this.isThisTab ? 1 : 0)
        .scale(this.isThisTab ? { x: 1, y: 1 } : { x: 0.5, y: 0.5 })
        .animation({
          delay: CommonConstants.NORMAL_ANIMATION_DELAY * 3,
          curve: curves.springMotion(CommonConstants.MEDIUM_ANIMATION_DURATION / 1000, 0.6)
        })
        .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ? { right: 5, top: 5, bottom: 5 } : 0)

        FlowItem() {

        }
        .height('50%')
      }
      .columnsTemplate(new BreakPointType({
        sm: '1fr',
        md: '1fr 1fr',
        lg: '1fr 1fr 1fr'
      }).getValue(this.currentBreakPoint))
      .columnsGap(10)
      .rowsGap(10)
      .padding({ left: 16, right: 16 })
      .clip(false)

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
