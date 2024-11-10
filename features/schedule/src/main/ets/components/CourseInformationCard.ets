import { DateUtil } from '@ohos/utils/src/main/ets/utils/DateUtil';
import { Course } from '../model/Course';
import { CourseSchedule } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { classDateAndPlaceToCourseSchedule } from '../service/ScheduleBaseFunc';

@Component
export struct ClassInformationCard {
  @ObjectLink courseInfomation: Course;
  @Prop courseSchedules: CourseSchedule[] | undefined = undefined;

  private mDate = new DateUtil();

  @Styles
  scheduleCardStyle() {
    .width('100%')
    .height($r('app.float.schedule_card_item_height'))
    .margin($r('app.float.course_card_padding'))
  }

  aboutToAppear(): void {
    if (this.courseInfomation.classDateAndPlace) {
      this.courseSchedules = classDateAndPlaceToCourseSchedule(this.courseInfomation, new Schedule('', '', ''));
    }
  }

  build() {
    Column() {
      Row() {
        Text(this.courseInfomation.courseName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .padding($r('app.float.course_card_padding'))

      Column({ space: 5 }) {
        if (this.courseSchedules) {
          ForEach(this.courseSchedules, (item: CourseSchedule) => {
            Column() {
              Row() {
                SymbolGlyph($r('sys.symbol.calendar_fill'))
                  .fontSize(20)
                  .fontColor([$r('app.color.whut_blue')])
                Text('第' + item.weekRanges + '周')
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
    }
    .backgroundColor($r('app.color.whut_blue_background'))
    .borderRadius($r('app.float.main_border_radius'))
    .borderWidth(1)
    .padding($r('app.float.course_card_padding'))
    .renderFit(RenderFit.RESIZE_CONTAIN)
    .width('100%')
  }
}