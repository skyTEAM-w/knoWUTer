import { BreakPointTypeEnum } from '@ohos/utils';
import { CourseSchedule, TIME_TABLE } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { ScheduleWeekViewItem } from './ScheduleWeekViewItem';

const TAG = '[ScheduleWeekView]'

@Component
export struct ScheduleWeekView {
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @ObjectLink @Watch('onScheduleChange') selectedSchedule: Schedule;
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @Link @Watch('refreshWeekNum') selectedWeek: number;
  @Link isCookieShow: boolean;
  @Link isSettingShow: boolean;
  @Link isScheduleShow: boolean;
  @Prop currentWeek: number;
  @State swiperWeekIndex: number = 1;
  @State weekNumOne: number = -1;
  @State weekNumTwo: number = 0;
  @State weekNumThree: number = 1;
  @State @Watch('showBindSheet') selectedCourse: CourseSchedule | undefined = undefined;
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

  jumpEditCourseInformation: (courseId: string, tableId: string) => void = () => {

  };

  aboutToAppear(): void {
    this.oldSelectWeek = this.selectedWeek
    switch ((this.selectedWeek % 3)) {
      case 0: {
        this.weekNumOne = this.selectedWeek - this.currentWeek + 1;
        this.weekNumTwo = this.selectedWeek - this.currentWeek - 1;
        this.weekNumThree = this.selectedWeek - this.currentWeek;
        this.swiperWeekIndex = 2;
        break;
      }
      case 1: {
        this.weekNumOne = this.selectedWeek - this.currentWeek;
        this.weekNumTwo = this.selectedWeek - this.currentWeek + 1;
        this.weekNumThree = this.selectedWeek - this.currentWeek - 1;
        this.swiperWeekIndex = 0;
        break;
      }
      case 2: {
        this.weekNumOne = this.selectedWeek - this.currentWeek - 1;
        this.weekNumTwo = this.selectedWeek - this.currentWeek;
        this.weekNumThree = this.selectedWeek - this.currentWeek + 1
        this.swiperWeekIndex = 1;
        break;
      }
    }
  }

  refreshWeekNum() {
    if (!this.isSwiping) {
      switch ((this.selectedWeek % 3)) {
        case 0: {
          this.weekNumOne = this.selectedWeek - this.currentWeek + 1;
          this.weekNumTwo = this.selectedWeek - this.currentWeek - 1;
          this.weekNumThree = this.selectedWeek - this.currentWeek;
          this.swiperWeekIndex = 2;
          break;
        }
        case 1: {
          this.weekNumOne = this.selectedWeek - this.currentWeek;
          this.weekNumTwo = this.selectedWeek - this.currentWeek + 1;
          this.weekNumThree = this.selectedWeek - this.currentWeek - 1;
          this.swiperWeekIndex = 0;
          break;
        }
        case 2: {
          this.weekNumOne = this.selectedWeek - this.currentWeek - 1;
          this.weekNumTwo = this.selectedWeek - this.currentWeek;
          this.weekNumThree = this.selectedWeek - this.currentWeek + 1
          this.swiperWeekIndex = 1;
          break;
        }
      }
    }

  }

  onScheduleChange() {
    console.debug(TAG, 'onScheduleChange', this.selectedWeek, this.currentWeek)
    switch (this.selectedWeek % 3) {
      case 0: {
        console.debug(TAG, 'CASE 0')
        this.weekNumOne = 1;
        this.weekNumTwo = -1;
        this.weekNumThree = 0;
        this.swiperWeekIndex = 2;
        break;
      }
      case 1: {
        console.debug(TAG, 'CASE 1')
        this.weekNumOne = 0;
        this.weekNumTwo = 1;
        this.weekNumThree = -1;
        this.swiperWeekIndex = 0;
        break;
      }
      case 2: {
        console.debug(TAG, 'CASE 2')
        this.weekNumOne = -1;
        this.weekNumTwo = 0;
        this.weekNumThree = 1;
        this.swiperWeekIndex = 1;
        break;
      }
    }
  }

  showBindSheet() {
    // if (!this.isScheduleShow) {
    //   this.isScheduleShow = true;
    //   this.isCookieShow = false;
    //   this.isSettingShow = false;
    // }
  }

  @Styles
  scheduleCardStyle() {
    .width('100%')
    .height($r('app.float.schedule_item_height'))
    .margin($r('app.float.course_card_padding'))
  }

  @Builder
  courseScheduleBindSheet() {
    Column() {
      Row({space: 10}) {
        Button({ type: ButtonType.Capsule }) {
          Row() {
            SymbolGlyph($r('sys.symbol.pencil_and_card'))
              .fontSize(18)
              .fontColor([$r('app.color.whut_blue')])
            Text('编辑')
              .fontSize(14)
              .fontColor($r('app.color.whut_blue'))
          }
        }
        .onClick(() => {
          this.isScheduleShow = false;
          this.jumpEditCourseInformation(this.selectedCourse?.ClassId as string, this.selectedCourse?.TableId as string)
        })
        .clickEffect({level: ClickEffectLevel.LIGHT, scale: 0.95})
        .backgroundColor($r('app.color.whut_blue_background_selected'))
        .width(66)
        .height('80%')

        Button({ type: ButtonType.Capsule, role: ButtonRole.ERROR}) {
          Row() {
            SymbolGlyph($r('sys.symbol.trash'))
              .fontSize(18)
              .fontColor([Color.Red])
            Text('删除')
              .fontSize(14)
              .fontColor(Color.Red)
          }
        }
        .clickEffect({level: ClickEffectLevel.LIGHT, scale: 0.95})
        .backgroundColor($r('app.color.delete_button_background'))
        .width(66)
        .height('80%')
      }
      .height(33)
      .width('90%')
      .justifyContent(FlexAlign.Start)
      .margin($r('app.float.course_card_padding'))

      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.calendar_fill'))
            .fontSize(20)
            .fontColor([$r('app.color.whut_blue')])
            .padding({ left: 5 })
          Text('第' + this.selectedCourse?.weekRangesStr + '周')
            .fontSize(16)
            .padding({ left: 5 })

        }
        .justifyContent(FlexAlign.Start)
        .scheduleCardStyle()

        Row() {
          SymbolGlyph($r('sys.symbol.clock_fill'))
            .fontSize(20)
            .fontColor(['#ffdc143c'])
            .padding({ left: 5 })
          Text('星期' + this.selectedCourse?.WeekDay + ' 第' + this.selectedCourse?.StartSession + '-' +
            this.selectedCourse?.EndSession + '节' +
            ' ' + `${TIME_TABLE[this.selectedCourse?.StartSession as number -
            1].StartTime}-${TIME_TABLE[this.selectedCourse?.EndSession as number - 1].EndTime}`)
            .fontSize(16)
            .padding({ left: 5 })
        }
        .scheduleCardStyle()

        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_circle_fill'))
            .fontSize(20)
            .fontColor(['#ffff7f50'])
            .padding({ left: 5 })
          Text(this.selectedCourse?.Place.search('undefined') === -1 ? this.selectedCourse?.Place : '暂无')
            .fontSize(16)
            .padding({ left: 5 })
        }
        .scheduleCardStyle()
      }
      .width('90%')
      .backgroundColor($r('app.color.whut_blue_background'))
      .borderRadius($r('app.float.main_border_radius'))
    }
    .width('100%')
  }

  build() {
    Column() {
      Swiper() {
        ScheduleWeekViewItem({
          weekNum: this.weekNumOne,
          selectedWeek: this.selectedWeek,
          currentWeek: this.currentWeek,
          selectedSchedule: this.selectedSchedule,
          isCookieShow: this.isCookieShow,
          isSettingShow: this.isSettingShow,
          isScheduleShow: this.isScheduleShow,
          selectedCourse: this.selectedCourse
        })
        ScheduleWeekViewItem({
          weekNum: this.weekNumTwo,
          selectedWeek: this.selectedWeek,
          currentWeek: this.currentWeek,
          selectedSchedule: this.selectedSchedule,
          isCookieShow: this.isCookieShow,
          isSettingShow: this.isSettingShow,
          isScheduleShow: this.isScheduleShow,
          selectedCourse: this.selectedCourse
        })
        ScheduleWeekViewItem({
          weekNum: this.weekNumThree,
          selectedWeek: this.selectedWeek,
          currentWeek: this.currentWeek,
          selectedSchedule: this.selectedSchedule,
          isCookieShow: this.isCookieShow,
          isSettingShow: this.isSettingShow,
          isScheduleShow: this.isScheduleShow,
          selectedCourse: this.selectedCourse
        })
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
        const IS_RIGHT_SLIDE: boolean =
          (this.oldWeekViewIndex === 1 && index === 0) || (this.oldWeekViewIndex === 0 && index === 2) ||
            (this.oldWeekViewIndex === 2 && index === 1);
        const IS_SWIPE: boolean = this.oldWeekViewIndex === index;
        if (!IS_SWIPE) {
          if (IS_RIGHT_SLIDE) {
            this.selectedWeek = this.selectedWeek - 1;
          } else {
            this.selectedWeek = this.selectedWeek + 1;
          }
          this.oldSelectWeek = this.selectedWeek
          console.debug(TAG, 'selectedWeekSlide', this.selectedWeek)
        }
        this.isSwiping = false;
      })
      .indicator(false)
      .loop((1 < this.selectedWeek && this.selectedWeek < 20))
      .index($$this.swiperWeekIndex)
      .height('100%')
    }
    .transition(TransitionEffect.opacity(0.8))
    .bindSheet(this.isScheduleShow, this.courseScheduleBindSheet, {
      title: { title: this.selectedCourse?.CourseName },
      preferType: this.currentBreakPoint === BreakPointTypeEnum.LG ? SheetType.CENTER : SheetType.BOTTOM,
      detents: [300, SheetSize.MEDIUM],
      blurStyle: BlurStyle.Thin,
      backgroundColor: $r('app.color.whut_blue_background'),
      onWillDismiss: ((DismissSheetAction: DismissSheetAction) => {
        if (DismissSheetAction.reason == DismissReason.SLIDE_DOWN) {
          DismissSheetAction.dismiss()
        }
        this.isScheduleShow = false;
      }),
      onWillSpringBackWhenDismiss: ((SpringBackAction: SpringBackAction) => {

      }),
    })
    .margin({ top: 5 })
    .height('100%')
    .width("100%")
  }
}