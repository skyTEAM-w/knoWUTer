import { webview } from '@kit.ArkWeb';
import { BreakPointTypeEnum, CookieUtil, DateUtil, LazyDataSource } from '@ohos/utils';
import { ScheduleNavigation } from '../components/ScheduleNavigationTitle';
import { ScheduleNetFunc } from '../service/ScheduleNetFunc';
import { Schedule } from '../model/Schedule';
import { Course } from '../model/Course';
import { ScheduleCard } from '../components/ScheduleCard';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { ScheduleBaseFunc } from '../service/ScheduleBaseFunc';
import { JSON } from '@kit.ArkTS';
import { ScheduleSettingFunc } from '../service/ScheduleSettingFunc';
import {
    ItemRestriction,
    SegmentButton,
    SegmentButtonOptions,
    SegmentButtonTextItem
} from '@ohos.arkui.advanced.SegmentButton';
import { ScheduleDayView } from '../views/ScheduleDayView';
import { ScheduleWeekView } from '../views/ScheduleWeekView';

const TAG = '[ScheduleTable]'

@Component
export struct ScheduleTable {
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @StorageLink('schedule_cookie') ScheduleCookie: string = AppStorage.get<string>('schedule_cookie') || '';
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('selectScheduleIndex') @Watch('onWeekNeedChange') selectedScheduleTableIndex: number =
    AppStorage.get<number>('selectScheduleIndex') || -1;
  @State isCookieShow: boolean = false;
  @State @Watch('onWeekNeedChange') isSettingShow: boolean = false;
  @State cookie: string = '';
  @State scheduleTableList: LazyDataSource<Schedule> = new LazyDataSource();
  @State selectedSchedule: Schedule | undefined = undefined;
  @State courseList: LazyDataSource<Course> | undefined = undefined;
  @State loginStatus: boolean | undefined = undefined;
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '日程' }, { text: '列表' }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundColor: $r('app.color.whut_blue_background_selected')
  })
  @State tabSelectedIndexes: number[] = [0]
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private scheduleNetFunc = new ScheduleNetFunc();
  private scheduleDBFunc = new ScheduleDatabaseFunc();
  private scheduleBaseFunc = new ScheduleBaseFunc();
  private scheduleSettingFunc = ScheduleSettingFunc.getInstance();
  private mDate = new DateUtil();
  private currentWeek: number = 0;
  @State sliderValue: number = 1;
  @State mToday: Date = new Date(this.mDate.getToday());
  @State selectedWeek: number = 0;

  aboutToAppear(): void {
    ScheduleSettingFunc.getInstance().checkSelectScheduleIndex();
    this.scheduleNetFunc.checkJWXTLoginStatus().then((status: boolean) => {
      this.loginStatus = status;
      console.debug('loginStatus', this.loginStatus)
    });
    this.getAllSchedule();
    this.getCourseList();
  }

  aboutToDisappear(): void {
    console.debug(TAG, 'aboutToDisappear', this.selectedScheduleTableIndex)
    this.scheduleSettingFunc.saveSelectScheduleIndex(this.selectedScheduleTableIndex);
  }

  onWeekNeedChange(propName: string){
    if (propName == 'selectedScheduleTableIndex') {
      this.selectedSchedule = this.scheduleTableList.getData(this.selectedScheduleTableIndex);
      this.currentWeek = DateUtil.getWeeksBetweenDates(this.selectedSchedule.StartDate, this.mDate.getToday());
      this.selectedWeek = this.currentWeek;
      this.getCourseList();
    } else {
      this.scheduleTableList.pushArrayData(this.scheduleDBFunc.queryAllScheduleTable() as Schedule[]);
    }
  }

  getAllSchedule() {
    // TODO: 存在代码冗余，测试后删减
    this.scheduleTableList.pushArrayData(this.scheduleDBFunc.queryAllScheduleTable() as Schedule[]);
    console.debug(TAG, 'getAllSchedule', JSON.stringify(this.scheduleTableList))
    if (!this.scheduleTableList.isEmpty() && this.selectedScheduleTableIndex !== -1 && !this.isSettingShow) {
      this.selectedSchedule = this.scheduleTableList.getData(this.selectedScheduleTableIndex);
      this.currentWeek = DateUtil.getWeeksBetweenDates(this.selectedSchedule.StartDate, this.mDate.getToday());
      this.selectedWeek = this.currentWeek;
      this.getCourseList();
    } else if (this.isSettingShow) {
      this.selectedSchedule = this.scheduleTableList.getData(this.selectedScheduleTableIndex);
      this.currentWeek = DateUtil.getWeeksBetweenDates(this.selectedSchedule.StartDate, this.mDate.getToday());
      this.selectedWeek = this.currentWeek;
      this.getCourseList();
    }
  }

  settingGetSchedule() {
    if (this.isSettingShow){
      this.scheduleTableList.pushArrayData(this.scheduleDBFunc.queryAllScheduleTable() as Schedule[]);
      this.selectedSchedule = this.scheduleTableList.getData(this.selectedScheduleTableIndex);
      this.selectedWeek = DateUtil.getWeeksBetweenDates(this.selectedSchedule.StartDate, this.mDate.getToday());
      this.currentWeek = this.selectedWeek;
      this.sliderValue = this.currentWeek;
      this.getCourseList();
    }
  }

  getCourseList() {
    console.debug(TAG, 'getCourseList', this.selectedScheduleTableIndex)
    if (this.selectedScheduleTableIndex !== -1) {
      const schedule = this.scheduleTableList?.getData(this.selectedScheduleTableIndex);
      this.scheduleSettingFunc.saveSelectScheduleIndex(this.selectedScheduleTableIndex);
      console.debug(TAG, 'getCourseList', JSON.stringify(schedule))
      if (schedule) {
        this.courseList = this.scheduleDBFunc.queryAllCourseInformation(schedule)
      }
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

  @Styles
  marginStyle() {
    .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ?
      { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin') } :
      { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })
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
            .margin({ right: $r('app.float.xxl_padding_margin') })
            .onClick(() => {
              this.jumpManageSchedule();
              this.isSettingShow = false;
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .marginStyle()
        .width('100%')

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
          value: $$this.selectedWeek,
          min: 1,
          max: 21,
          step: 1,
          style: SliderStyle.InSet
        })
          .showTips(true, this.selectedWeek.toString())
          .showSteps(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.selectedWeek = value;
            console.info('value:' + value + 'mode:' + mode.toString())
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

  build() {
    Navigation(this.schedulePathStack) {
      Column() {
        Stack({ alignContent: Alignment.Top }) {
          if (this.courseList) {
            if (this.tabSelectedIndexes[0] === 1) {
              Scroll() {
                Column() {
                  Column()
                    .height(88)
                    .backgroundColor(Color.Transparent)
                  ScheduleDayView({ courseList: this.courseList })
                }
              }
              .scrollBar(BarState.Off)
              .height('100%')
            } else {
              Column() {
                Column()
                  .height(88)
                ScheduleWeekView({
                  selectedSchedule: this.selectedSchedule,
                  selectedWeek: this.selectedWeek,
                  currentWeek: this.currentWeek
                })
              }
            }
          }
              ScheduleNavigation({
                selectedDate: this.mToday,
                isCookieShow: this.isCookieShow,
                isSettingShow: this.isSettingShow,
                schedule: this.selectedSchedule,
                loginStatus: this.loginStatus,
                tabOptions: this.tabOptions,
                tabSelectedIndexes: this.tabSelectedIndexes,
                selectWeek: this.selectedWeek,
                currentWeek: this.currentWeek
              });



        }

      }
    }
    .backgroundColor($r('app.color.whut_blue_background'))
    .bindSheet($$this.isSettingShow, this.settingBindSheet(), {
      preferType: this.currentBreakPoint === BreakPointTypeEnum.LG ? SheetType.CENTER : SheetType.BOTTOM,
      detents: [400],
      showClose: false,
      blurStyle: BlurStyle.Thin,
      backgroundColor: Color.Transparent,
      maskColor: Color.Transparent
    })
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)

  }
}