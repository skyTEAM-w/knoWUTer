import { BreakPointTypeEnum, CommonConstants, CookieUtil, DateUtil, LazyDataSource, VibrateUtil } from '@ohos/utils';
import { Schedule } from '../model/Schedule';
import { webview } from '@kit.ArkWeb';
import { ScheduleNetFunc } from '../service/ScheduleNetFunc';
import { curves, promptAction, SegmentButton, SegmentButtonOptions, SymbolGlyphModifier } from '@kit.ArkUI';
import { ScheduleCard } from './ScheduleCard';

@Component
export struct ScheduleNavigation {
  @StorageProp('bottomTabIndex') @Watch('onBottomIndexChange') bottomTabIndex: number = 2;
  @State isThisTab: boolean = false;
  @Link selectedScheduleTableIndex: number | undefined;
  @Link selectedDate: Date;
  @Link isCookieShow: boolean;
  @Link isSettingShow: boolean;
  @Link loginStatus: boolean | undefined;
  @Link selectWeek: number;
  @Link scheduleTableList: LazyDataSource<Schedule>;
  @ObjectLink tabOptions: SegmentButtonOptions;
  @Link tabSelectedIndexes: number[];
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @Prop cookie: string = '';
  @ObjectLink schedule: Schedule | undefined;
  @Link currentWeek: number;
  private mDate = new DateUtil();
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private scheduleNetFunc = new ScheduleNetFunc();
  private navigationSpringCurve: ICurve = curves.springMotion(0.38, 0.7)

  onBottomIndexChange() {
    this.isThisTab = this.bottomTabIndex === CommonConstants.SCHEDULE_BOTTOM_INDEX;
  }

  jumpCreateNewSchedule() {
    if (this.currentBreakPoint === BreakPointTypeEnum.LG) {
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

  jumpManageSchedule() {
    if (this.currentBreakPoint === BreakPointTypeEnum.LG) {
      this.schedulePathStack.pushPathByName('ManageSchedule', new Object(
        {
          onDestinationBack: () => {
            this.schedulePathStack.pop();
          }
        }
      ))
    } else {
      this.appPathStack.pushPathByName('ManageSchedule', new Object(
        {
          onDestinationBack: () => {
            this.appPathStack.pop();
          }
        }
      ))
    }
  }

  jumpAddNewCourse() {
    if (this.currentBreakPoint === BreakPointTypeEnum.LG) {
      this.schedulePathStack.pushPathByName('AddNewCourse', new Object(
        {
          onDestinationBack: () => {
            this.schedulePathStack.pop();
          }
        }
      ))
    } else {
      this.appPathStack.pushPathByName('AddNewCourse', new Object(
        {
          onDestinationBack: () => {
            this.appPathStack.pop();
          }
        }
      ))
    }
  }

  @Styles
  marginStyle() {
    .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ?
      { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin') } :
      { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })
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
  settingBindSheet() {
    Column({ space: 10 }) {

      if (this.currentBreakPoint === BreakPointTypeEnum.SM) {
        Column() {
          SegmentButton({
            options: this.tabOptions,
            selectedIndexes: $tabSelectedIndexes
          })
            .margin(this.currentBreakPoint !== BreakPointTypeEnum.SM ?
              { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 5 } :
              { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 5 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      Column() {
        Row() {
          Text('课程表')
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .width("50%")
          Text('管理')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.End)
            .fontColor(Color.Blue)
            .width("20%")
            .onClick(() => {
              this.jumpManageSchedule();
              this.isSettingShow = false;
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .marginStyle()
        .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ? { top: 20 } : 0)
        .width('90%')

        Scroll() {
          Row({ space: 5 }) {
            LazyForEach(this.scheduleTableList, (item: Schedule, index: number) => {
              ScheduleCard({ schedule: item, selectedScheduleIndex: this.selectedScheduleTableIndex, index: index })
            })
            Row()
              .width('90%')
          }
          .marginStyle()
        }
        .width('100%')
        .margin({ top: 5 })
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)

      Column() {
        Text('周数')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .marginStyle()
          .width('100%')
        Slider({
          value: $$this.selectWeek,
          min: 1,
          max: 21,
          step: 1,
          style: SliderStyle.InSet
        })
          .selectedColor($r('app.color.whut_blue'))
          .showTips(true, this.selectWeek.toString())
          .showSteps(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.selectWeek = value;
            VibrateUtil.getInstance().sliderVibrate()
          })
          .marginStyle()
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Row() {
        Column() {

        }
      }
      .width("100%")
    }
    .width("100%")
    .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ? { top: AppStorage.get<number>('statusBarHeight') } :
      { top: 20 })
  }

  @Builder
  titleBindMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r(`sys.symbol.calendar_${new Date().getDate()
          .toString()
          .padStart(2, '0')}`)).fontSize(24),
        content: '回到当前周'
      })
        .onClick(() => {
          this.selectWeek = this.currentWeek;
        })
    }
  }

  @Builder
  plusButtonMenu() {
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
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.plus')).fontSize(24),
        content: '添加新课程'
      })
        .onClick(() => {
          this.jumpAddNewCourse();
        })
    }
  }

  build() {
    Row() {
      GridRow({ columns: { sm: 6, md: 10, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 3, lg: 3 } }) {
          if (this.isThisTab) {
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
            .height('100%')
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.SpaceBetween)
            .bindMenu([{
              value: '回到本周',
              symbolIcon: new SymbolGlyphModifier($r(`sys.symbol.calendar_${new Date().getDate()
                .toString()
                .padStart(2, '0')}`)).fontSize(24),
              action: () => {
                this.selectWeek = this.currentWeek;
              }
            }], { placement: Placement.BottomLeft, offset: { x: 15, y: 0 } })
            .transition(TransitionEffect.move(TransitionEdge.START).animation({ curve: this.navigationSpringCurve }))
          }
        }
        .alignSelf(ItemAlign.Start)


        GridCol({ span: { sm: 0, md: 0, lg: 1 } })

        GridCol({ span: { sm: 1, md: 4, lg: 4 } }) {
          if (this.currentBreakPoint !== BreakPointTypeEnum.SM) {
            Row() {
              SegmentButton({
                options: this.tabOptions,
                selectedIndexes: this.tabSelectedIndexes
              })
            }
            .height('100%')
            .width('100%')
          }
        }

        GridCol({ span: { sm: 0, md: 0, lg: 1 } })

        GridCol({ span: { sm: 2, md: 3, lg: 3 } }) {
          if (this.isThisTab) {
            Row() {
              Button({ type: ButtonType.Circle }) {
                SymbolGlyph($r('sys.symbol.plus'))
                  .fontSize(22)
                  .fontWeight(FontWeight.Medium)
              }
              .barButtonStyle()
              .bindMenu(this.plusButtonMenu())

              Button({ type: ButtonType.Circle }) {
                SymbolGlyph($r('sys.symbol.person'))
                  .fontSize(22)
                  .fontWeight(FontWeight.Medium)
              }
              .barButtonStyle()
              .onClick(() => {
                this.isCookieShow = !this.isCookieShow;
              })
              .bindPopup(!this.loginStatus && !this.isCookieShow, {
                message: '教务系统未登录'
              })
              .bindSheet($$this.isCookieShow, this.cookieBindSheet(), {
                preferType: SheetType.POPUP,
                showClose: this.currentBreakPoint === BreakPointTypeEnum.LG,
                onWillAppear: () => {
                  this.isSettingShow = false
                }
              })

              Button({ type: ButtonType.Circle }) {
                SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
                  .fontSize(22)
                  .fontWeight(FontWeight.Medium)
              }
              .bindSheet($$this.isSettingShow, this.settingBindSheet, {
                preferType: this.currentBreakPoint === BreakPointTypeEnum.LG ? SheetType.CENTER : SheetType.BOTTOM,
                detents: [300],
                showClose: this.currentBreakPoint === BreakPointTypeEnum.LG,
                blurStyle: BlurStyle.Thin,
                backgroundColor: Color.Transparent,
                maskColor: Color.Transparent,
                onWillAppear: () => {
                  this.isCookieShow = false;
                }
              })
              .barButtonStyle()
              .onClick(() => {
                this.isSettingShow = !this.isSettingShow;
              })
            }
            .transition(TransitionEffect.move(TransitionEdge.END).animation({ curve: this.navigationSpringCurve }))
            .height('100%')
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
          }

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