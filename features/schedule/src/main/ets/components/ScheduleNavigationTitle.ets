import { BreakPointTypeEnum, CookieUtil, DateUtil } from '@ohos/utils';
import { Schedule } from '../model/Schedule';
import { webview } from '@kit.ArkWeb';
import { ScheduleNetFunc } from '../service/ScheduleNetFunc';
import { ItemRestriction, promptAction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem,
  SymbolGlyphModifier } from '@kit.ArkUI';
import { it } from '@ohos/hypium';

@Component
export struct ScheduleNavigation {
  @Link selectedDate: Date;
  @Link isCookieShow: boolean;
  @Link isSettingShow: boolean;
  @Link loginStatus: boolean | undefined;
  @ObjectLink tabOptions: SegmentButtonOptions;
  @Link tabSelectedIndexes: number[];
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('currentBreakPoint') currenBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @Prop cookie: string = '';
  @ObjectLink schedule: Schedule | undefined;

  private mDate = new DateUtil();
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private scheduleNetFunc = new ScheduleNetFunc();

  jumpCreateNewSchedule() {
    if (this.currenBreakPoint === BreakPointTypeEnum.LG) {
      this.schedulePathStack.pushPathByName('CreateNewSchedule', new Object(
        {
          onDestinationBack: () => {
            this.schedulePathStack.pop();
          }
        }
      ))
    } else {
      this.appPathStack.pushPathByName('CreateNewSchedule', new Object(
        {
          onDestinationBack: () => {
            this.appPathStack.pop();
          }
        }
      ))
    }
  }

  @Styles
  barButtonStyle() {
    .height($r('app.float.interactive_button_height'))
    .width($r('app.float.interactive_button_height'))
    .backgroundColor(Color.Transparent)
  }

  @Builder
  cookieBindSheet() {
    Web({
      src: 'https://jwxt.whut.edu.cn/',
      controller: this.webViewController
    })
      .onPageEnd(() => {
        this.cookie =
          webview.WebCookieManager.fetchCookieSync('https://jwxt.whut.edu.cn/jwapp/sys/homeapp/home/index.html');
        CookieUtil.getInstance().saveJWXTCookie(this.cookie);
        this.scheduleNetFunc.checkJWXTLoginStatus().then((status: boolean) => {
          this.loginStatus = status;
        });
      })
  }

  @Builder
  creatNewScheduleButtonMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.download')).fontSize(24),
        content: '从教务导入' })
        .onClick(() => {
          if (this.loginStatus) {
            this.jumpCreateNewSchedule();
          } else {
            promptAction.showToast({message: '教务系统未登录'})
          }
        })
    }
  }

  build() {
    Row() {
      GridRow({columns: {sm: 8, md: 10, lg: 12}}) {
        GridCol({span: {sm: 4, md: 5, lg: 6}}) {
          Column() {
            TextClock()
              .format('yyyy/MM/dd')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
            Row({space: 5}) {
              Text('第' + this.mDate.getWeeksBetweenDates(this.schedule?.StartDate, this.mDate.getToday()) + '周')
              TextClock()
                .format('EEEE')
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .alignSelf(ItemAlign.Start)

        GridCol({span: {sm: 1, md: 2, lg: 3}}) {
          if (this.currenBreakPoint !== BreakPointTypeEnum.SM) {
            SegmentButton({
              options: this.tabOptions,
              selectedIndexes: this.tabSelectedIndexes
            })
          }
        }

        GridCol({span: {sm: 3, md: 3, lg: 3}}) {
          Row() {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.plus'))
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
            }
            .barButtonStyle()
            .bindMenu(this.creatNewScheduleButtonMenu())

            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.person'))
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
            }
            .barButtonStyle()
            .onClick(() => {
              this.isCookieShow = true;
            })
            .bindPopup(!this.loginStatus && !this.isCookieShow, {
              message: '教务系统未登录'
            })
            .bindSheet($$this.isCookieShow, this.cookieBindSheet(), {
              preferType: SheetType.POPUP
            })

            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
            }
            .barButtonStyle()
            .onClick(() => {
              this.isSettingShow = true;
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .alignSelf(ItemAlign.End)
      }
      .alignItems(ItemAlign.Center)
      .width('100%')
      .height('100%')
    }
    .backgroundColor(Color.Transparent)
    .height($r('app.float.schedule_navigation_height'))
    .width('100%')
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: 0.1, color: $r('app.color.whut_blue_background_selected') })
    .padding({
      top: AppStorage.get<number>('statusBarHeight') as number + 5,
      left: $r('app.float.md_padding_margin'),
      right: $r('app.float.md_padding_margin')
    })
  }
}