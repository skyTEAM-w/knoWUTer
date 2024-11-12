import { DateUtil, Day } from '@ohos/utils';
import { JSON } from '@kit.ArkTS';
import { CourseSchedule, COURSE_SCHEDULE_HEIGHT, TimeTable, TIME_TABLE, WEEKS } from '../model/CourseSchedule';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { Schedule } from '../model/Schedule';
import { paddingCourseSchedule } from '../service/ScheduleBaseFunc';
import { it } from '@ohos/hypium';
import { WeekScheduleCard } from '../components/WeekSheduleCard';

@Component
export struct ScheduleWeekViewItem {
  // @Prop selectedSchedule: Schedule;
  // @Prop currentSelectedWeek: number;

  @State weekDays: Day[][] = [];
  @State weekCourse: CourseSchedule[][] = [];
  @Prop @Watch("updateWeekData") weekNum: number;
  @Prop  selectedWeek: number;
  @Prop @Watch("updateWeekData") currentWeek: number;
  @Prop selectedSchedule: Schedule;

  private scheduleDBFunc: ScheduleDatabaseFunc = new ScheduleDatabaseFunc();

  aboutToAppear(): void {
    this.getWeekViewData(this.weekNum);
    this.getWeekCourseData()
    console.debug(JSON.stringify(this.weekDays))
  }

  getWeekViewData(weekNum: number) {
    this.weekDays = [...DateUtil.getWeekDays(weekNum)];
  }

  updateWeekData() {
    console.debug('weekNum: ' + this.weekNum)
    this.getWeekViewData(this.weekNum);
    this.getWeekCourseData()
    console.debug(JSON.stringify(this.weekDays))
  }

  getWeekCourseData() {
    for (let i = 0; i < 7; i++) {
      const weekDayCourse = this.scheduleDBFunc.queryCourseScheduleByWeek(this.selectedSchedule, this.currentWeek + this.weekNum, i)
      if (weekDayCourse) {
        const CourseDataAfterPadding = paddingCourseSchedule(weekDayCourse)
        this.weekCourse[i] = CourseDataAfterPadding;
      }
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
      GridRow({ columns: {sm: 8, md: 8, lg:15 } }) {
        GridCol({ span: 1 }) {
          Column() {
            Text(this.weekDays[0][0].dayInfo.year + '')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
            Text(this.weekDays[0][0].dayInfo.month + '月')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
          }
        }
        ForEach(this.weekDays, (items: Day[]) => {
          ForEach(items, (item: Day, index: number) => {
            WeekDayColumnHeader({day: item, weekDay: index})
          }, (item: Day, index: number) => {
            return item.dayNum + '' + index;
          })
          // .justifyContent(FlexAlign.SpaceBetween)
        }, (item: Day[], index: number) => {
          return item.reduce((item1, item2) => {
            return item1 + item2.dayInfo.year + item2.dayInfo.month + item2.dayInfo.date
          }, '') + index
        })
      }
      Scroll() {
        GridRow({ columns: {sm: 8, md: 8, lg:15} }) {
          TimeTableColumn()
          ForEach(this.weekCourse, (item: CourseSchedule[]) => {
            WeekDayColumn({dayCourse: item, currentWeek: this.currentWeek})
          })
        }
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .height('100%')
      .nestedScroll({scrollForward: NestedScrollMode.SELF_ONLY, scrollBackward: NestedScrollMode.SELF_ONLY})
    }.width("100%")
  }
}

@Component
struct WeekDayColumnHeader {
  @Prop day: Day;
  @Prop weekDay: number

  build() {
    GridCol({span: {sm: 1, md: 1, lg: 2}}) {
      Column() {
        Column() {
          Text(this.day.dayInfo.month + '/' + this.day.dayNum.toString())
            .fontSize(12)
          Text(WEEKS[this.weekDay])
            .fontSize(12)
        }
      }
    }
  }
}

@Component
struct TimeTableColumn {
  build() {
    GridCol({span: 1}) {
      Column() {
        ForEach(TIME_TABLE, (item: TimeTable) => {
          Column() {
            Text(item.session.toString())
              .fontSize(12)
            Text(item.StartTime)
              .fontSize(12)
            Text(item.EndTime)
              .fontSize(12)
          }
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
  @Prop dayCourse: CourseSchedule[];
  @Prop currentWeek: number;
  build() {
    GridCol({span: {sm: 1, md: 1, lg: 2}}) {
      Column() {
        ForEach(this.dayCourse, (item: CourseSchedule) => {
          if (item.StartSession === -1) {
            Column()
              .height($r('app.float.course_schedule_height'))
          } else {
            WeekScheduleCard({courseSchedule: item, currentWeek: this.currentWeek})
          }
        })
      }

    }
  }
}
