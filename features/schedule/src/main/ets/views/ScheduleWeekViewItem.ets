import { CommonConstants, DateUtil, Day, EventType } from '@ohos/utils';
import { CourseSchedule, TIME_TABLE, TimeTable, WEEKS } from '../model/CourseSchedule';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { Schedule } from '../model/Schedule';
import { paddingCourseSchedule } from '../service/ScheduleBaseFunc';
import { WeekScheduleCard } from '../components/WeekSheduleCard';
import { common } from '@kit.AbilityKit';
import { curves } from '@kit.ArkUI';

@Component
export struct ScheduleWeekViewItem {
  @StorageProp('bottomTabIndex') @Watch('onBottomIndexChange') bottomTabIndex: number = 2;
  @Prop @Watch('onBottomIndexChange') tabSelectedIndexes: number[]
  @State isThisTab: boolean = false;
  @Link isCookieShow: boolean;
  @Link isSettingShow: boolean;
  @Link isScheduleShow: boolean;
  @State weekDays: Day[][] = [];
  @State weekCourse: CourseSchedule[][] = [];
  @Link selectedCourse: CourseSchedule | undefined;
  @Prop @Watch("updateWeekData") weekNum: number;
  @Prop selectedWeek: number;
  @Prop @Watch("updateWeekData") currentWeek: number;
  @Prop @Watch("updateWeekData") selectedSchedule: Schedule;
  private scheduleDBFunc: ScheduleDatabaseFunc = new ScheduleDatabaseFunc();
  private scrollController = new Scroller();
  private timeTableScale: ScaleOptions = { x: 0.3, y: 0.3 }
  private timeTableCurve: ICurve = curves.springMotion(0.35, 0.66)

  aboutToAppear(): void {
    this.getWeekViewData(this.weekNum);
    this.getWeekCourseData()
    const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
    eventHub.on(EventType.UPDATE_COURSE, (): void => {
      this.updateWeekData();
    });
    eventHub.on(EventType.DELETE_COURSE, (): void => {
      this.updateWeekData();
    });
  }

  onBottomIndexChange() {
    this.isThisTab = this.bottomTabIndex === CommonConstants.SCHEDULE_BOTTOM_INDEX && this.tabSelectedIndexes[0] === 0;
  }

  getWeekViewData(weekNum: number) {
    this.weekDays = [...DateUtil.getWeekDays(weekNum)];
  }

  updateWeekData() {
    console.debug('weekNum: ' + this.weekNum)
    this.getWeekViewData(this.weekNum);
    this.getWeekCourseData()
    this.scrollController.scrollEdge(Edge.Top)
  }

  /**
   * 拉取本周七天的课程安排。
   *
   * 七天各查一次（原来就是七次查询，只是同步的）；并发发起避免串行等待。
   * 数据到齐后一次性赋值，避免 LazyForEach 看到半填充的数组。
   */
  async getWeekCourseData(): Promise<void> {
    if (!this.selectedSchedule) {
      return;
    }
    const week: number = this.currentWeek + this.weekNum;
    const tasks: Promise<CourseSchedule[]>[] = [];
    for (let i = 0; i < 7; i++) {
      tasks.push(this.scheduleDBFunc.queryCourseScheduleByWeek(this.selectedSchedule, week, i));
    }
    const results: CourseSchedule[][] = await Promise.all(tasks);
    const next: CourseSchedule[][] = [];
    for (let i = 0; i < 7; i++) {
      next[i] = paddingCourseSchedule(results[i]);
    }
    this.weekCourse = next;
  }

  showBindSheet() {
    if (!this.isScheduleShow) {
      this.isScheduleShow = true;
      this.isCookieShow = false;
      this.isSettingShow = false;
    }

  }

  @Builder
  weekDayBuilder(day: Day) {
    GridCol({ span: 1 }) {
      Text(day.dayInfo.month + '/' + day.dayNum.toString())
    }
    .margin(5)
  }

  build() {
    Column() {
      GridRow({ columns: { sm: 8, md: 8, lg: 15 } }) {
        GridCol({ span: 1 }) {
          Column() {
            Text(this.weekDays[0][0].dayInfo.year + '')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
            Text(this.weekDays[0][0].dayInfo.month + '月')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
          }
          .opacity(this.isThisTab ? 1 : 0.5)
          .scale(this.isThisTab ? CommonConstants.FULL_SCALE : this.timeTableScale)
          .animation({ curve: this.timeTableCurve })
        }

        ForEach(this.weekDays, (items: Day[]) => {
          ForEach(items, (item: Day, index: number) => {
            WeekDayColumnHeader({
              day: item,
              weekDay: index,
              isThisTab: this.isThisTab,
              timeTableScale: this.timeTableScale,
              timeTableCurve: this.timeTableCurve
            })
          }, (item: Day, index: number) => {
            return item.dayNum + '' + index;
          })
        }, (item: Day[], index: number) => {
          return item.reduce((item1, item2) => {
            return item1 + item2.dayInfo.year + item2.dayInfo.month + item2.dayInfo.date
          }, '') + index
        })
      }

      Scroll(this.scrollController) {
        GridRow({ columns: { sm: 8, md: 8, lg: 15 } }) {
          TimeTableColumn({
            isThisTab: this.isThisTab,
            timeTableScale: this.timeTableScale,
            timeTableCurve: this.timeTableCurve
          })
          ForEach(this.weekCourse, (item: CourseSchedule[], index: number) => {
            WeekDayColumn({
              dayCourse: item,
              currentWeek: this.currentWeek,
              isCookieShow: this.isCookieShow,
              isSettingShow: this.isSettingShow,
              isScheduleShow: this.isScheduleShow,
              weekCourse: this.weekCourse,
              selectedCourse: this.selectedCourse,
              indexX: index,
              tabSelectedIndexes: this.tabSelectedIndexes
            })
          })
        }
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .height('100%')
      .nestedScroll({ scrollForward: NestedScrollMode.SELF_ONLY, scrollBackward: NestedScrollMode.SELF_ONLY })
    }

    .width("100%")
  }
}

@Component
struct WeekDayColumnHeader {
  @Prop day: Day;
  @Prop weekDay: number
  @Prop isThisTab: boolean;
  timeTableScale?: ScaleOptions
  timeTableCurve?: ICurve;

  build() {
    GridCol({ span: { sm: 1, md: 1, lg: 2 } }) {
      Column() {
        if (new DateUtil().getToday() ===
        [this.day.dayInfo.year, this.day.dayInfo.month, this.day.dayInfo.date].join('/')) {
          Text(this.day.dayInfo.month + '/' + this.day.dayNum.toString())
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
          Text(WEEKS[this.weekDay])
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
        } else {
          Text(this.day.dayInfo.month + '/' + this.day.dayNum.toString())
            .fontSize(12)
            .fontColor(Color.Gray)
            .opacity(0.8)
          Text(WEEKS[this.weekDay])
            .fontSize(12)
            .fontColor(Color.Gray)
            .opacity(0.8)
        }
      }
      .opacity(this.isThisTab ? 1 : 0)
      .scale(this.isThisTab ? CommonConstants.FULL_SCALE : this.timeTableScale)
      .animation(this.isThisTab ?
        { curve: this.timeTableCurve, delay: CommonConstants.NORMAL_ANIMATION_DELAY * (this.weekDay + 1) } :
        { curve: Curve.Linear, duration: 0 })
    }
  }
}

@Component
struct TimeTableColumn {
  @Prop isThisTab: boolean;
  timeTableScale?: ScaleOptions
  timeTableCurve?: ICurve;

  build() {
    GridCol({ span: 1 }) {
      Column() {
        ForEach(TIME_TABLE, (item: TimeTable, index: number) => {
          Column() {
            Text(item.session.toString())
              .fontSize(12)
            Text(item.StartTime)
              .fontSize(12)
            Text(item.EndTime)
              .fontSize(12)
          }
          .scale(this.isThisTab ? CommonConstants.FULL_SCALE : this.timeTableScale)
          .opacity(this.isThisTab ? 1 : 0)
          .animation(this.isThisTab ?
            { curve: this.timeTableCurve, delay: CommonConstants.NORMAL_ANIMATION_DELAY * (index + 1) } :
            { curve: Curve.Linear, duration: 0 })
          .justifyContent(FlexAlign.Center)
          .height($r('app.float.course_schedule_height'))
        })
        Column()
          .height('50%')
      }
    }
  }
}

@Component
struct WeekDayColumn {
  @Prop tabSelectedIndexes: number[]
  @Link isCookieShow: boolean;
  @Link isSettingShow: boolean;
  @Link isScheduleShow: boolean;
  @Link weekCourse: CourseSchedule[][];
  @Link selectedCourse: CourseSchedule
  @Prop dayCourse: CourseSchedule[];
  @Prop currentWeek: number;
  @Prop indexX: number;

  build() {
    GridCol({ span: { sm: 1, md: 1, lg: 2 } }) {
      Column() {
        ForEach(this.dayCourse, (item: CourseSchedule, index: number) => {
          if (item.StartSession === -1) {
            Column()
              .height($r('app.float.course_schedule_height'))
          } else {
            WeekScheduleCard({
              courseSchedule: item,
              indexX: this.indexX,
              indexY: index,
              currentWeek: this.currentWeek,
              isCookieShow: this.isCookieShow,
              isSettingShow: this.isSettingShow,
              isScheduleShow: this.isScheduleShow,
              weekCourse: this.weekCourse,
              selectedCourse: this.selectedCourse,
              tabSelectedIndexes: this.tabSelectedIndexes
            })
          }
        }, (item: CourseSchedule, index: number) => index.toString())
      }

    }
  }
}
