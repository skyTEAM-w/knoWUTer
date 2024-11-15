import { BreakPointType, BreakPointTypeEnum } from '@ohos/utils';
import LazyDataSource from '@ohos/utils/src/main/ets/utils/LazyDataSource';
import { Course } from '../model/Course';
import { ClassInformationCard } from '../components/CourseInformationCard';
import { Schedule } from '../model/Schedule';
import { ScheduleBaseFunc } from '../service/ScheduleBaseFunc';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { ScheduleNetFunc } from '../service/ScheduleNetFunc';

const INTERVAL = 30;
const DURATION = 300;

const TAG = '[ScheduleListView]'

@Component
export struct ScheduleListView {
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('selectScheduleIndex') selectedScheduleTableIndex: number =
    AppStorage.get<number>('selectScheduleIndex') || -1;
  @LocalStorageLink('updateCourse') @Watch("updateCourseInformation") updateCourse: boolean = false;
  @State courseList: LazyDataSource<Course> = new LazyDataSource();
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @ObjectLink selectedSchedule: Schedule;

  private scheduleNetFunc = new ScheduleNetFunc();
  private scheduleDBFunc = new ScheduleDatabaseFunc();

  jumpEditCourseInformation: (courseId: string, tableId: string) => void = () => {

  };

  aboutToAppear(): void {
    this.getCourseList()
  }

  updateCourseInformation() {
    this.courseList.pushArrayData((new ScheduleDatabaseFunc().queryAllCourseInformation(this.selectedSchedule as Schedule) as LazyDataSource<Course>).getDataList())
  }

  getCourseList() {
    if (this.selectedScheduleTableIndex !== -1) {
      if (this.selectedSchedule) {
        this.courseList = this.scheduleDBFunc.queryAllCourseInformation(this.selectedSchedule) as LazyDataSource<Course>
      }
    }
  }

  build() {
    WaterFlow() {
      LazyForEach(this.courseList, (item: Course, index: number) => {
        FlowItem() {
          ClassInformationCard({ courseInfomation: item, longPressEnable: true, selectedSchedule: this.selectedSchedule, jumpEditCourseInformation: this.jumpEditCourseInformation })
        }
        .padding({ left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.8, y: 0.8 }))
          .animation({ duration: DURATION, curve: Curve.Friction, delay: INTERVAL * index }))
      },(item: Course, index: number) => JSON.stringify(item) + index.toString())
      FlowItem() {

      }
      .height('50%')
    }
    .cachedCount(0)
    .columnsTemplate(new BreakPointType({
      sm: '1fr',
      md: '1fr 1fr',
      lg: '1fr 1fr 1fr'
    }).getValue(this.currentBreakPoint))
    .transition(TransitionEffect.opacity(0.8))
    .columnsGap($r('app.float.course_card_padding'))
    .rowsGap($r('app.float.course_card_padding'))
    .scrollBar(BarState.Off)
    .height("100%")
    .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({ top: 5 })
  }
}