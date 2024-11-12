import { BreakPointTypeEnum, CookieUtil, DateUtil } from '@ohos/utils';
import { Schedule } from '../model/Schedule';
import { webview } from '@kit.ArkWeb';
import { ScheduleNetFunc } from '../service/ScheduleNetFunc';
import {
    promptAction,
    SegmentButton,
    SegmentButtonOptions, SymbolGlyphModifier
} from '@kit.ArkUI';

@Component
export struct ScheduleNavigation {
  @Link selectedDate: Date;
  @Link isCookieShow: boolean;
  @Link isSettingShow: boolean;
  @Link loginStatus: boolean | undefined;
  @Link selectWeek: number;
  @ObjectLink tabOptions: SegmentButtonOptions;
  @Link tabSelectedIndexes: number[];
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('currentBreakPoint') currenBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @Prop cookie: string = '';
  @ObjectLink schedule: Schedule | undefined;
  @Prop currentWeek: number = 1;
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
  titleBindMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_counterclockwise')).fontSize(24),
        content: '回到当前周'
      })
        .onClick(() => {
          this.selectWeek = this.currentWeek;
        })
    }
  }

  @Builder
  creatNewScheduleButtonMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.download')).fontSize(24),
        content: '从教务导入'
      })
        .onClick(() => {
          if (this.loginStatus) {
            this.jumpCreateNewSchedule();
          } else {
            promptAction.showToast({ message: '教务系统未登录' })
          }
        })
    }
  }

  build() {
    Row() {
      GridRow({ columns: { sm: 6, md: 10, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 3, lg: 3 } }) {
          Column() {
            TextClock()
              .format('yyyy/MM/dd')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
            Row({ space: 5 }) {
              Text('第' + this.selectWeek + '周')
              if (this.currentWeek === this.selectWeek) {
                TextClock()
                  .format('EEEE')
              } else {
                Text('非本周')
              }

            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween)
          .bindMenu([{
            value: '回到本周',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_counterclockwise')).fontSize(24),
            action: () => {
              this.selectWeek = this.currentWeek;
            }
          }], {placement: Placement.BottomLeft, offset:{x: 12, y: 0}})
        }
        .alignSelf(ItemAlign.Start)


        GridCol({span: {sm: 0, md: 0, lg: 1}})

        GridCol({ span: { sm: 1, md: 4, lg: 4 } }) {
          if (this.currenBreakPoint !== BreakPointTypeEnum.SM) {
            SegmentButton({
              options: this.tabOptions,
              selectedIndexes: this.tabSelectedIndexes
            })
          }
        }

        GridCol({span: {sm: 0, md: 0, lg: 1}})

        GridCol({ span: { sm: 2, md: 3, lg: 3 } }) {
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
    .backgroundBlurStyle(this.tabSelectedIndexes[0] === 1 ? BlurStyle.Thin : BlurStyle.NONE)
    // .border({ width: 0.1, color: $r('app.color.whut_blue_background_selected') })
    .padding({
      top: AppStorage.get<number>('statusBarHeight') as number + 5,
      left: $r('app.float.md_padding_margin'),
      right: $r('app.float.md_padding_margin')
    })
  }
}