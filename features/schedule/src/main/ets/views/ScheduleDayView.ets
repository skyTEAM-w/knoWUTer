import { BreakPointType, BreakPointTypeEnum } from '@ohos/utils';
import LazyDataSource from '@ohos/utils/src/main/ets/utils/LazyDataSource';
import { Course } from '../model/Course';
import { ClassInformationCard } from '../components/CourseInformationCard';

@Component
export struct ScheduleDayView {
  @ObjectLink courseList: LazyDataSource<Course> | undefined;
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;

  build() {
    WaterFlow() {
      LazyForEach(this.courseList, (item: Course, index: number) => {
        FlowItem() {
          ClassInformationCard({ courseInfomation: item })
        }
        .padding({ left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })
      })
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
    .columnsGap($r('app.float.course_card_padding'))
    .rowsGap($r('app.float.course_card_padding'))
    .scrollBar(BarState.Off)
    .height("100%")
    .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding({ top: 5 })
  }
}