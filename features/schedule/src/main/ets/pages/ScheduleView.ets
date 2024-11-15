import { webview } from '@kit.ArkWeb';
import { BreakPointTypeEnum, DateUtil, LazyDataSource } from '@ohos/utils';
import { ScheduleNavigation } from '../components/ScheduleNavigationTitle';
import { ScheduleNetFunc } from '../service/ScheduleNetFunc';
import { Schedule } from '../model/Schedule';
import { Course } from '../model/Course';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { ScheduleBaseFunc } from '../service/ScheduleBaseFunc';
import { JSON } from '@kit.ArkTS';
import { ScheduleSettingFunc } from '../service/ScheduleSettingFunc';
import { ItemRestriction, SegmentButtonOptions, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import { ScheduleListView } from '../views/ScheduleListView';
import { ScheduleWeekView } from '../views/ScheduleWeekView';

const TAG = '[ScheduleTable]'

@Component
export struct ScheduleTable {
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @StorageLink('schedule_cookie') ScheduleCookie: string = AppStorage.get<string>('schedule_cookie') || '';
  @LocalStorageLink('updateCourse') @Watch('updateCourseInformation') updateCourse: boolean = false;
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('selectScheduleIndex') @Watch('onWeekNeedChange') selectedScheduleTableIndex: number =
    AppStorage.get<number>('selectScheduleIndex') || -1;
  @State isCookieShow: boolean = false;
  @State @Watch('onWeekNeedChange') isSettingShow: boolean = false;
  @State isScheduleShow: boolean = false;
  @State cookie: string = '';
  @State scheduleTableList: LazyDataSource<Schedule> = new LazyDataSource();
  @State selectedSchedule: Schedule | undefined = undefined;
  @State courseList: LazyDataSource<Course> = new LazyDataSource();
  @State loginStatus: boolean | undefined = undefined;
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '日程' }, { text: '列表' }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundColor: $r('app.color.whut_blue_background_selected')
  })
  @State tabSelectedIndexes: number[] = [0]
  @State sliderValue: number = 1;
  @State selectedWeek: number = 0;
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private scheduleNetFunc = new ScheduleNetFunc();
  private scheduleDBFunc = new ScheduleDatabaseFunc();
  private scheduleBaseFunc = new ScheduleBaseFunc();
  private scheduleSettingFunc = ScheduleSettingFunc.getInstance();
  private mDate = new DateUtil();
  @State mToday: Date = new Date(this.mDate.getToday());
  private currentWeek: number = 0;

  aboutToAppear(): void {
    ScheduleSettingFunc.getInstance().checkSelectScheduleIndex();
    this.scheduleNetFunc.checkJWXTLoginStatus().then((status: boolean) => {
      this.loginStatus = status;
      console.debug('loginStatus', this.loginStatus)
    });
    this.getAllSchedule();
  }

  aboutToDisappear(): void {
    console.debug(TAG, 'aboutToDisappear', this.selectedScheduleTableIndex)
    this.scheduleSettingFunc.saveSelectScheduleIndex(this.selectedScheduleTableIndex);
  }

  onWeekNeedChange(propName: string) {
    if (propName == 'selectedScheduleTableIndex') {
      this.selectedSchedule = this.scheduleTableList.getData(this.selectedScheduleTableIndex);
      this.currentWeek = DateUtil.getWeeksBetweenDates(this.selectedSchedule.StartDate, this.mDate.getToday());
      this.selectedWeek = this.currentWeek;
    } else {
      this.scheduleTableList.pushArrayData(this.scheduleDBFunc.queryAllScheduleTable() as Schedule[]);
    }
  }

  updateCourseInformation() {
    this.courseList = this.scheduleDBFunc.queryAllCourseInformation(this.selectedSchedule as Schedule) as LazyDataSource<Course>
  }

  getAllSchedule() {
    // TODO: 存在代码冗余，测试后删减
    this.scheduleTableList.pushArrayData(this.scheduleDBFunc.queryAllScheduleTable() as Schedule[]);
    console.debug(TAG, 'getAllSchedule', JSON.stringify(this.scheduleTableList))
    if (!this.scheduleTableList.isEmpty() && this.selectedScheduleTableIndex !== -1 && !this.isSettingShow) {
      this.selectedSchedule = this.scheduleTableList.getData(this.selectedScheduleTableIndex);
      this.currentWeek = DateUtil.getWeeksBetweenDates(this.selectedSchedule.StartDate, this.mDate.getToday());
      this.selectedWeek = this.currentWeek;
    } else if (this.isSettingShow) {
      this.selectedSchedule = this.scheduleTableList.getData(this.selectedScheduleTableIndex);
      this.currentWeek = DateUtil.getWeeksBetweenDates(this.selectedSchedule.StartDate, this.mDate.getToday());
      this.selectedWeek = this.currentWeek;
    } else {
    }
  }

  settingGetSchedule() {
    if (this.isSettingShow) {
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
        this.courseList = this.scheduleDBFunc.queryAllCourseInformation(schedule) as LazyDataSource<Course>
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

  jumpEditCoursePage(courseId: string, tableId: string) {
    if (this.currentBreakPoint === BreakPointTypeEnum.LG) {
      this.schedulePathStack.pushPathByName('EditCourseInformation', new Object(
        {
          courseId: courseId,
          tableId: tableId,
          onDestinationBack: () => {
            this.schedulePathStack.pop();
          }
        }
      ))
    } else {
      this.appPathStack.pushPathByName('EditCourseInformation', new Object(
        {
          courseId: courseId,
          tableId: tableId,
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

  build() {
    Navigation(this.schedulePathStack) {
      Column() {
        Stack({ alignContent: Alignment.Top }) {
          if (this.tabSelectedIndexes[0] === 1) {
            Column() {
              Scroll() {
                Column() {
                  Column()
                    .height(88)
                    .backgroundColor(Color.Transparent)
                  ScheduleListView({
                    selectedSchedule: this.selectedSchedule,
                    jumpEditCourseInformation: this.jumpEditCoursePage
                  })
                }
              }
              .scrollBar(BarState.Off)
              .height('100%')
            }
          } else {
            Column() {
              Column()
                .height(88)
              ScheduleWeekView({
                selectedSchedule: this.selectedSchedule,
                selectedWeek: this.selectedWeek,
                currentWeek: this.currentWeek,
                isCookieShow: this.isCookieShow,
                isSettingShow: this.isSettingShow,
                isScheduleShow: this.isScheduleShow,
                jumpEditCourseInformation: this.jumpEditCoursePage
              })
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
            currentWeek: this.currentWeek,
            scheduleTableList: this.scheduleTableList,
            selectedScheduleTableIndex: this.selectedScheduleTableIndex
          });
        }

      }

    }
    .backgroundColor($r('app.color.whut_blue_background'))

    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)

  }
}