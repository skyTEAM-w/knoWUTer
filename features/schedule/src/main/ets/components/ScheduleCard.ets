import { Schedule } from "../model/Schedule"

@Component
export struct ScheduleCard {
  @ObjectLink schedule: Schedule;
  @Link selectedScheduleIndex: number;
  index?: number = undefined;
  build() {
    Column() {
      Rect({width: 40, height: 40})
        .radius(8)
        .fill(this.selectedScheduleIndex === this.index ? $r('app.color.whut_yellow') : $r('app.color.whut_blue'))
      Text(this.schedule.scheduleName)
        .fontSize(10)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .ellipsisMode(EllipsisMode.END)
        .maxLines(1)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .clickEffect({level: ClickEffectLevel.LIGHT, scale: 0.8})
    .onClick(() => {
      console.debug('selectedIndex', this.index)
      if(this.index !== undefined) {
        console.debug('selectedIndex', this.index)
        this.selectedScheduleIndex = this.index;
      }
    })
    .width($r('app.float.schedule_card_width'))
  }
}