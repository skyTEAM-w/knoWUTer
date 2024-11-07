import { webview } from '@kit.ArkWeb';
import { DateUtil } from '@ohos/utils';
import { ScheduleNavigation } from '../components/ScheduleNavigationTitle';
import { ScheduleNetFunc } from '../service/ScheduleNetFunc';
import { intl } from '@kit.LocalizationKit';
import { faceDetector } from '@kit.CoreVisionKit';

@Component
export struct Schedule {
  @State isShow: boolean = false;
  @State cookie: string = '';
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private scheduleNetFunc = new ScheduleNetFunc();
  private mDate = new DateUtil();
  @State selectedDate: Date = new Date(this.mDate.getToday());

  @Builder
  myBindSheet() {
    Web({
      src: 'https://jwxt.whut.edu.cn',
      controller: this.webViewController
    })
      .onPageEnd(() => {
        this.cookie =
          webview.WebCookieManager.fetchCookieSync('https://jwxt.whut.edu.cn/jwapp/sys/homeapp/home/index.html')
      })
  }

  build() {
    Navigation() {
      Column() {
        ScheduleNavigation({ selectedDate: this.selectedDate, isShow: this.isShow });
        // Text(new intl.DateTimeFormat("zh-cn").format(this.selectedDate));
      }
    }
    .bindSheet($$this.isShow, this.myBindSheet())
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)

  }
}