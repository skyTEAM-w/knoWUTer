import { DateUtil, Day } from "@ohos/utils";
import { Schedule } from "../model/Schedule"
import { JSON } from "@kit.ArkTS";

@Component
export struct ScheduleWeekViewItem {
  // @Prop selectedSchedule: Schedule;
  // @Prop currentSelectedWeek: number;

  @State weekDays: Day[][] = [];

  @Prop @Watch("updateWeekData") weekNum: number;

  aboutToAppear(): void {
    this.getWeekViewData(this.weekNum);
    console.debug(JSON.stringify(this.weekDays))
  }

  getWeekViewData(weekNum: number) {
    this.weekDays = [...DateUtil.getWeekDays(weekNum)];
  }

  updateWeekData() {
    console.debug('weekNum: ' + this.weekNum)
    this.getWeekViewData(this.weekNum);
  }

  @Builder
  weekDayBuilder(day: Day) {
    GridCol({span: 1}) {
      Text(day.dayInfo.month + '/' + day.dayNum.toString())
    }
    .margin(5)
  }

  build() {
    Column() {
      GridRow({columns: 8}) {
        GridCol({span: 1}) {
          Text(this.weekDays[0][0].dayInfo.month + '月')
        }

        ForEach(this.weekDays, (items: Day[]) => {
            ForEach(items, (item: Day) => {
              this.weekDayBuilder(item)
            }, (item: Day, index: number) => {
              return item.dayNum + '' + index;
            })
          // .justifyContent(FlexAlign.SpaceBetween)
        }, (item: Day[], index: number) => {
          return item.reduce((item1, item2) => {
            return item1 + item2.dayInfo.year + item2.dayInfo.month + item2.dayInfo.date
          }, '') + index
        })
      }
      }.width("100%")
    }

}