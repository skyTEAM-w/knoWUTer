import { CourseSchedule, WEEKS_START_SUNDAY } from '@feature/schedule/src/main/ets/model/CourseSchedule';
import { JSON, taskpool } from '@kit.ArkTS';
import { BreakPointType, BreakPointTypeEnum, DateUtil, EventType, LazyDataSource } from '@ohos/utils';
import { getTodayCourse } from '../service/HomeTaskPoolFunc';
import { relationalStore } from '@kit.ArkData';
import { TodayCourseCard } from '@feature/schedule/src/main/ets/components/TodayCourseCard';
import { common } from '@kit.AbilityKit';
import { ScheduleEventData } from '@feature/schedule/src/main/ets/model/Schedule';

const TAG = '[TodayCourse]'

async function getTodayCourseTask(tableId: string, currentWeek: number, weekNumber: number, context: Context) {
  let task: taskpool.Task = new taskpool.Task(getTodayCourse, tableId, currentWeek, weekNumber, context);
  return await taskpool.execute(task) as Array<relationalStore.ValuesBucket>;
}

@Component
export struct TodayCourse {
  @StorageProp('startDate') @Watch('getCourseScheduleList') startDate: string =
    AppStorage.get<string>('startDate') || '2024-9-2';
  @State currentWeek: number = 1;
  @StorageProp('selectedTableId') @Watch('getCourseScheduleList') selectedTableId: string | undefined =
    AppStorage.get<string>('selectedTableId') || '1';
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @State todayCourseSchedules: LazyDataSource<CourseSchedule> = new LazyDataSource();
  @State hasCourse: boolean = false;
  private currentWeekDay = new Date().getDay()
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;

  aboutToAppear(): void {
    this.eventHub.on(EventType.CHANGE_TABLE, (data: ScheduleEventData) => {
      this.selectedTableId = data.scheduleId;
      this.startDate = data.StartDate;
    })
    this.eventHub.on(EventType.UPDATE_COURSE, (): void => {
      this.getCourseScheduleList()
    })
    this.eventHub.on(EventType.DELETE_COURSE, (): void => {
      this.getCourseScheduleList()
    })
    this.getCourseScheduleList()
  }

  getCourseScheduleList() {
    this.currentWeek = DateUtil.getWeeksBetweenDates(this.startDate, new DateUtil().getToday())
    console.debug(TAG, this.selectedTableId)
    console.debug(TAG, this.startDate)
    console.debug(TAG, this.currentWeekDay)
    getTodayCourseTask(this.selectedTableId as string, this.currentWeek,
      this.currentWeekDay === 7 ? 0 : this.currentWeekDay - 1, getContext(this))
      .then((value: Array<relationalStore.ValuesBucket>) => {
        let dataList: CourseSchedule[] = []
        if (value.length === 0) {
          this.hasCourse = false;
        } else {
          this.hasCourse = true;
        }
        value.forEach((item: relationalStore.ValuesBucket) => {
          const tableId = item.TableId;
          const scheduleId = item.ScheduleId;
          const weekRanges = item.WeekRanges;
          const weekDay = item.WeekDay;
          const startSession = item.StartSession
          const endSession = item.EndSession
          const place = item.Place;
          const courseId = item.ClassId;
          const courseName = item.CourseName;
          const weekRangesStr = item.WeekRangesStr;
          dataList.push(new CourseSchedule(weekRanges as string, tableId as string,
            courseId as string, courseName as string, scheduleId as string,
            weekDay as string, startSession as number, endSession as number, place as string, weekRangesStr as string))
        })
        this.todayCourseSchedules.pushArrayData(dataList);
      })

  }

  build() {
    Column() {
      Row() {
        Text('课程')
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Bold)
        Text(`第${this.currentWeek}周  周${WEEKS_START_SUNDAY[this.currentWeekDay]}`)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .margin({ right: 5 })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ?
        { left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin'), top: 10 } :
        { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 10 })

      if (!this.hasCourse) {
        Text('今日无课<(￣︶￣)> ')
          .height(112)
      } else {
        List({ space: 10 }) {
          LazyForEach(this.todayCourseSchedules, (item: CourseSchedule, index: number) => {
            ListItem() {
              TodayCourseCard({ courseSchedule: item })
            }
            .margin({ left: 5, right: 5 })
          }, (item: CourseSchedule, index: number) => JSON.stringify(item) + index.toString())
        }
        .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
        .lanes(new BreakPointType({ sm: 2, md: 3, lg: 2 }).getValue(this.currentBreakPoint))
        .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ?
          { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 10 } :
          { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 10 })
      }
    }
    .width("100%")

  }
}