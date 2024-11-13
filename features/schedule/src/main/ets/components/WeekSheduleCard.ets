import { COURSE_SCHEDULE_HEIGHT, CourseSchedule } from '../model/CourseSchedule';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { JSON } from '@kit.ArkTS';

@Component
export struct WeekScheduleCard {
  @Link isCookieShow: boolean;
  @Link isSettingShow: boolean;
  @Link isScheduleShow: boolean;
  @Link weekCourse: CourseSchedule[][];
  @Link selectedCourse: CourseSchedule;
  @Prop @Watch('updateCard') currentWeek: number;
  @ObjectLink courseSchedule: CourseSchedule;
  @State cardColor: ResourceColor = $r('app.color.course_card_bg_default_color');
  indexY: number = 0;
  indexX: number = 0;

  aboutToAppear(): void {
    this.cardColor = new ScheduleDatabaseFunc().queryCourseColor(this.courseSchedule);
    console.debug('COLOR', this.cardColor)
  }

  updateCard() {
    this.cardColor = new ScheduleDatabaseFunc().queryCourseColor(this.courseSchedule);
  }



  build() {
    Column({ space: 2 }) {
      Text(this.courseSchedule.CourseName)
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
      if (this.courseSchedule.Place.includes('undefined')) {
        Text('暂无')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
      } else {
        Text(this.courseSchedule.Place)
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
      }

    }
    .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.8, y: 0.8 }))
      .animation({ duration: 300, curve: Curve.Friction }))
    .margin({ left: 5, right: 5 })
    .justifyContent(FlexAlign.Center)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .border({ color: $r('app.color.whut_blue_background_selected'), width: 3, radius: 8 })
    .backgroundColor(this.cardColor)
    .width('95%')
    .height(COURSE_SCHEDULE_HEIGHT * (this.courseSchedule.EndSession - this.courseSchedule.StartSession + 1))
    .onClick(() => {
      console.debug(this.indexX.toString(), this.indexY.toString())
        this.selectedCourse = this.weekCourse[this.indexX][this.indexY]
      this.isScheduleShow = true;
    })
  }
}