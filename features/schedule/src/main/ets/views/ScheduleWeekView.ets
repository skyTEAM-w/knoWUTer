import { Schedule } from "../model/Schedule"
import { ScheduleWeekViewItem } from "./ScheduleWeekViewItem";

const TAG = '[ScheduleWeekView]'

@Component
export struct ScheduleWeekView {
  @ObjectLink @Watch('onScheduleChange') selectedSchedule: Schedule;
  @Link @Watch('refreshWeekNum') selectedWeek: number;
  @Prop  currentWeek: number;

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
  private oldSelectWeek: number = 1;
  private isSwiping: boolean = false;

  aboutToAppear(): void {
    this.oldSelectWeek = this.selectedWeek
  }

  refreshWeekNum() {
    if (!this.isSwiping) {
      this.weekNumOne = this.selectedWeek - this.currentWeek - 1;
      this.weekNumTwo = this.selectedWeek - this.currentWeek;
      this.weekNumThree = this.selectedWeek - this.currentWeek + 1
      this.oldSelectWeek = this.selectedWeek;
    }

  }

  onScheduleChange() {
    console.debug(TAG, 'onScheduleChange', this.selectedWeek, this.currentWeek)
    this.weekNumOne = -1;
    this.weekNumTwo = 0;
    this.weekNumThree = 1
    this.swiperWeekIndex = 1
  }


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
        console.debug('onAnimationStart', IS_RIGHT_SLIDE)
        // 记录子组件索引
        this.oldWeekViewIndex = index;
        console.debug('onAnimationStart', this.oldWeekViewIndex)
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
      .onAnimationEnd((index: number) => {
        this.isSwiping = true;
        console.debug('onChange old', this.oldWeekViewIndex)
        console.debug('onChange index', index)
        const IS_RIGHT_SLIDE: boolean = (this.oldWeekViewIndex === 1 && index === 0) || (this.oldWeekViewIndex === 0 && index === 2) ||
          (this.oldWeekViewIndex === 2 && index === 1);
        const IS_SWIPE: boolean = this.oldWeekViewIndex === index;
        if (!IS_SWIPE) {
          if (IS_RIGHT_SLIDE) {
            this.selectedWeek = this.selectedWeek - 1;
          } else {
            this.selectedWeek = this.selectedWeek + 1;
          }
          this.oldSelectWeek = this.selectedWeek
          console.debug(TAG,'selectedWeekSlide', this.selectedWeek)
        }
        this.isSwiping = false;
      })
      .indicator(false)
      .loop((1 < this.selectedWeek && this.selectedWeek < 20))
      .index($$this.swiperWeekIndex)
      .height('100%')
    }
    .height('100%')
    .width("100%")
  }
}