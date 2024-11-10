import { Schedule } from "../model/Schedule"
import { ScheduleWeekViewItem } from "./ScheduleWeekViewItem";

@Component
export struct ScheduleWeekView {
  @ObjectLink selectedSchedule: Schedule;
  @Link selectedWeek: number;

  @State swiperWeekIndex: number = 1;
  @State weekNumOne: number = -1;
  @State weekNumTwo: number = 0;
  @State weekNumThree: number = 1;

  private weekYearOne: number = 0;
  private weekYearTwo: number = 0;
  private weekYearThree: number = 0;
  private weekMonthOne: number = 0;
  private weekMonthTwo: number = 0;
  private weekMonthThree: number = 0;
  // 记录swiper上一次显示的子组件索引。
  private oldWeekViewIndex: number = 1;


  build() {
    Column() {
      Swiper() {
        ScheduleWeekViewItem({weekNum: this.weekNumOne})
        ScheduleWeekViewItem({weekNum: this.weekNumTwo})
        ScheduleWeekViewItem({weekNum: this.weekNumThree})
      }
      .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
        // 判断是否右滑切换周
        const IS_RIGHT_SLIDE: boolean = (index === 1 && targetIndex === 0) || (index === 0 && targetIndex === 2) ||
          (index === 2 && targetIndex === 1);
        // 记录子组件索引
        this.oldWeekViewIndex = targetIndex;
        // 切换周时，刷新当前周视图第一天（周日）对应的年月信息

        // 右滑切换周
        if (IS_RIGHT_SLIDE) {
          if (targetIndex === 0) {
            // swiper索引右滑到0时，修改swiper索引2的周为当前周（索引0）的上一周。
            this.weekNumThree = this.weekNumOne - 1;
          } else if (targetIndex === 1) {
            // swiper索引右滑到1时，修改swiper索引0的周为当前周（索引1）的上一周。
            this.weekNumOne = this.weekNumTwo - 1;
          } else if (targetIndex === 2) {
            // swiper索引右滑到2时，修改swiper索引1的周为当前周（索引2）的上一周。
            this.weekNumTwo = this.weekNumThree - 1;
          }
        } else {
          // 左滑切换周
          if (targetIndex === 0) {
            // swiper索引左滑到0时，修改swiper索引1的周为当前周（索引0）的下一周。
            this.weekNumTwo = this.weekNumOne + 1;
          } else if (targetIndex === 1) {
            // swiper索引左滑到1时，修改swiper索引2的周为当前周（索引1）的下一周。
            this.weekNumThree = this.weekNumTwo + 1;
          } else if (targetIndex === 2) {
            // swiper索引右滑到2时，修改swiper索引0的周为当前周（索引2）的下一周。
            this.weekNumOne = this.weekNumThree + 1;
          }
        }
      })
      .indicator(false)
      .loop(true)
      .index($$this.swiperWeekIndex)

    }
    .height('100%')
    .width("100%")
  }
}