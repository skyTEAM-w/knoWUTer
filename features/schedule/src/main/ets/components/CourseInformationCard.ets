import { DateUtil } from '@ohos/utils/src/main/ets/utils/DateUtil';
import { Course } from '../model/Course';
import { CourseSchedule } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { classDateAndPlaceToCourseSchedule } from '../service/ScheduleBaseFunc';
import { JSON, taskpool } from '@kit.ArkTS';
import { classDateAndPlaceToCourseScheduleTask } from '../service/ScheduleTookPoolFunc';
import { LazyDataSource, VibrateUtil } from '@ohos/utils';
import { SymbolGlyphModifier } from '@kit.ArkUI';

const TAG = '[ClassInformationCard]';

async function getCourseScheduleTask(course: Course, isList: boolean) {
  let task: taskpool.Task = new taskpool.Task(classDateAndPlaceToCourseScheduleTask, course, isList);
  return await taskpool.execute(task) as CourseSchedule[]
}

@Component
export struct ClassInformationCard {
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  // @LocalStorageLink('updateCourse') @Watch('updateCourseInformation') updateCourse: boolean = false;
  @ObjectLink @Watch('updateCourseInformation') courseInfomation: Course;
  @Prop selectedSchedule: Schedule;
  @State courseSchedules: LazyDataSource<CourseSchedule> = new LazyDataSource();
  @State isShow: boolean = false;
  longPressEnable?: boolean;
  private mDate = new DateUtil();
  jumpEditCourseInformation: (courseId: string, tableId: string) => void = () => {

  };

  @Styles
  scheduleCardStyle() {
    .width('100%')
    .height($r('app.float.schedule_card_item_height'))
    .margin($r('app.float.course_card_padding'))
  }

  aboutToAppear(): void {
    if (this.courseInfomation && this.courseInfomation.classDateAndPlace) {
      console.debug(TAG, 'aboutToAppear', JSON.stringify(this.courseInfomation))
      let courseScheduleList =
        classDateAndPlaceToCourseSchedule(this.courseInfomation, new Schedule('', '', ''), false);
      if (courseScheduleList) {
        this.courseSchedules.pushArrayData(courseScheduleList);
      }
      // this.getCourseSchedule()
    }
  }

  updateCourseInformation() {
    let courseScheduleList =
      classDateAndPlaceToCourseSchedule(this.courseInfomation, new Schedule('', '', ''), false);
    if (courseScheduleList) {
      this.courseSchedules.pushArrayData(courseScheduleList);
    }
    console.debug(TAG, 'aboutToAppear', JSON.stringify(this.courseSchedules))
  }

  getCourseSchedule() {
    getCourseScheduleTask(this.courseInfomation, false).then((courseScheduleList) => {
      this.courseSchedules.pushArrayData(courseScheduleList);
      console.debug(TAG, 'aboutToAppear', JSON.stringify(this.courseSchedules))
    })
  }

  @Builder
  longPressMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.pencil_and_card')).fontSize(24),
        content: '编辑'
      })
        .onClick(() => {
          this.jumpEditCourseInformation(this.courseInfomation.classId, this.selectedSchedule.scheduleId);
        })
    }
  }

  build() {
    Column() {
      Row() {
        Text(this.courseInfomation.courseName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.course_card_font_default_color'))
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .padding($r('app.float.course_card_padding'))

      Column({ space: 5 }) {
        LazyForEach(this.courseSchedules, (item: CourseSchedule) => {
          Column() {
            Row() {
              SymbolGlyph($r('sys.symbol.calendar_fill'))
                .fontSize(20)
                .fontColor([$r('app.color.whut_blue')])
              Text('第' + item.weekRangesStr + '周')
                .fontSize(16)
                .padding({ left: 5 })
            }
            .justifyContent(FlexAlign.Start)
            .scheduleCardStyle()

            Divider()
            Row() {
              SymbolGlyph($r('sys.symbol.clock_fill'))
                .fontSize(20)
                .fontColor([$r('app.color.whut_yellow')])
              Text('星期' + item.WeekDay + ' 第' + item.StartSession + '-' + item.EndSession + '节')
                .fontSize(16)
                .padding({ left: 5 })
            }
            .scheduleCardStyle()

            Divider()
            Row() {
              SymbolGlyph($r('sys.symbol.location_north_up_right_circle_fill'))
                .fontSize(20)
                .fontColor([$r('app.color.whut_blue')])
              Text(item.Place.search('undefined') === -1 ? item.Place : '暂无')
                .fontSize(16)
                .padding({ left: 5 })
            }
            .scheduleCardStyle()
          }
          .width('100%')
          .backgroundColor($r('sys.color.background_tertiary'))
          .borderWidth(1)
          .borderRadius($r('app.float.main_border_radius'))
          .padding($r('app.float.course_card_padding'))
        })

      }
    }
    .backgroundColor($r('app.color.course_card_bg_default_color'))
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    // .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .borderRadius($r('app.float.main_border_radius'))
    .padding($r('app.float.course_card_padding'))
    .renderFit(RenderFit.RESIZE_CONTAIN)
    .bindMenu(this.isShow, this.longPressMenu(), {
      onDisappear: () => {
        this.isShow = false;
      }
    })
    .width('100%')
    .gesture(
      LongPressGesture()
        .onAction(() => {
          if (this.longPressEnable) {
            VibrateUtil.getInstance().longPressVibrate();
            this.isShow = true;
          }
        })
    )
  }
}