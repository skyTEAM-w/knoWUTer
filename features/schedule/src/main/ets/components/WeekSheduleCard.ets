import { CommonConstants, EventType } from '@ohos/utils';
import { COURSE_SCHEDULE_HEIGHT, CourseSchedule } from '../model/CourseSchedule';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { common } from '@kit.AbilityKit';
import { curves } from '@kit.ArkUI';

@Component
export struct WeekScheduleCard {
  @LocalStorageLink('updateCourse') updateCourse: boolean = false;
  @StorageProp('bottomTabIndex') @Watch('onBottomIndexChange') bottomTabIndex: number = 2;
  @Prop @Watch('onBottomIndexChange') tabSelectedIndexes: number[];
  @State isThisTab: boolean = false;
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
  private weekScheduleCurve: ICurve = curves.springMotion(0.3, 0.66)

  aboutToAppear(): void {
    this.updateCard()
    console.debug('COLOR', this.cardColor)
    const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
    eventHub.on(EventType.UPDATE_COURSE, (): void => this.updateCard());
  }

  updateCard() {
    this.isThisTab = true
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
    .opacity(this.isThisTab ? 1 : 0)
    .scale(this.isThisTab ? CommonConstants.FULL_SCALE : { x: 0.8, y: 0.8 })
    .animation(this.isThisTab ?
      { curve: this.weekScheduleCurve, delay: (this.indexY + this.indexX) * CommonConstants.SHORT_ANIMATION_DELAY } :
      { duration: 0 })
    .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.8, y: 0.8 }))
      .animation({
        curve: this.weekScheduleCurve,
        delay: (this.indexY + this.indexX) * CommonConstants.SHORT_ANIMATION_DELAY
      }))
    .margin({ left: 5, right: 5 })
    .justifyContent(FlexAlign.Center)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .border({ color: '#4000489A', width: 3, radius: 8 })
    .backgroundColor(this.cardColor)
    .width('95%')
    .height(COURSE_SCHEDULE_HEIGHT * (this.courseSchedule.EndSession - this.courseSchedule.StartSession + 1))
    .onClick(() => {
      console.debug(this.indexX.toString(), this.indexY.toString())
      this.selectedCourse = this.weekCourse[this.indexX][this.indexY]
      this.isScheduleShow = true;
    })
  }

  onBottomIndexChange() {
    this.isThisTab = this.bottomTabIndex === CommonConstants.SCHEDULE_BOTTOM_INDEX && this.tabSelectedIndexes[0] === 0;
  }
}