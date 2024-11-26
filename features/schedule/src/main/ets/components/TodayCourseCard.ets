import { CourseSchedule, TIME_TABLE } from '../model/CourseSchedule';
import { BreakPointType, BreakPointTypeEnum } from '@ohos/utils';

@Component
export struct TodayCourseCard {
  @ObjectLink courseSchedule: CourseSchedule;
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;

  build() {
    Row() {
      Column() {
        Row() {
          Text(this.courseSchedule.CourseName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .padding({ left: $r('app.float.course_card_padding') })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .ellipsisMode(EllipsisMode.END)
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')
        .padding($r('app.float.course_card_padding'))

        Row() {
          SymbolGlyph($r('sys.symbol.clock_fill'))
            .fontSize(18)
            .fontColor(['#ffdc143c'])
            .padding({ left: $r('app.float.course_card_padding') })
          Text(' 第' + this.courseSchedule.StartSession + '-' + this.courseSchedule.EndSession + '节')
            .fontSize(14)
            .padding({ left: $r('app.float.course_card_padding') })
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')
        .padding($r('app.float.course_card_padding'))

        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_circle_fill'))
            .fontSize(18)
            .fontColor(['#ffff7f50'])
            .padding({ left: $r('app.float.course_card_padding') })
          Text(this.courseSchedule.Place.search('undefined') === -1 ? this.courseSchedule.Place : '暂无')
            .fontSize(14)
            .padding({ left: $r('app.float.course_card_padding') })
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')
        .padding($r('app.float.course_card_padding'))
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .height('100%')
      .width(new BreakPointType({ sm: '65%', md: '75%', lg: '70%' }).getValue(this.currentBreakPoint))

      Column() {
        Text(`${TIME_TABLE[this.courseSchedule.StartSession - 1].StartTime}`)
          .fontSize(new BreakPointType({ sm: 16, md: 18, lg: 18 }).getValue(this.currentBreakPoint))
          .fontWeight(FontWeight.Bold)
        Column() {
          SymbolGlyph($r('sys.symbol.dot_grid_1x2'))
            .fontColor([$r('sys.color.icon')])
          SymbolGlyph($r('sys.symbol.dot_grid_1x2'))
            .fontColor([$r('sys.color.icon')])
        }

        Text(`${TIME_TABLE[this.courseSchedule.EndSession - 1].EndTime}`)
          .fontSize(new BreakPointType({ sm: 16, md: 18, lg: 18 }).getValue(this.currentBreakPoint))
          .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ? { right: $r('app.float.lg_course_card_padding') } :
        { right: $r('app.float.course_card_padding') })
      .height('100%')
    }
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.95 })
    .justifyContent(FlexAlign.SpaceAround)
    .borderRadius($r('app.float.main_border_radius'))
    .backgroundColor($r('app.color.whut_yellow_background_thick'))
    .width('100%')
    .height($r('app.float.today_schedule_card_height'))
  }
}