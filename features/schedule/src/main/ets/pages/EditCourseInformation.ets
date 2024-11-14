import { it } from '@ohos/hypium';
import { TopNavigationView } from '@ohos/uicomponents';
import { BreakPointTypeEnum, LazyDataSource } from '@ohos/utils';
import { WeekRangePicker } from '../dialogs/WeekRangePicker';
import { Course } from '../model/Course';
import { CourseSchedule, TIME_TABLE } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { compressRange } from '../service/ScheduleBaseFunc';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';

const TAG = '[EditCourseInformation]'

@Component
export struct EditCourseInformation {
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @State courseInformation: Course | undefined = undefined;
  @State courseSchedule: LazyDataSource<CourseSchedule> | undefined = undefined;
  @State courseColor: ResourceColor = '#FFFFFF';
  courseId: String = '';
  tableId: String = '';
  onDestinationBack: () => void = () => {
  };

  @Styles
  barButtonStyle() {
    .height($r('app.float.interactive_button_height'))
    .width($r('app.float.interactive_button_height'))
    .backgroundColor($r('app.color.interact_button_background'))
  }

  @Builder
  checkCreateMenu() {
    Button({ type: ButtonType.Circle }) {
      SymbolGlyph($r('sys.symbol.checkmark'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
    }
    .backgroundColor(Color.Gray)
    .barButtonStyle()
    .onClick(() => {

    })
  }

  @Builder
  courseScheduleHeader(index: number) {
    Text(`排课${index + 1}`)
      .fontSize(12)
      .padding({left: $r('app.float.lg_padding_margin')})
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          title: '编辑课程',
          onBackClick: () => this.onDestinationBack(),
          menuView: () => this.checkCreateMenu()
        })
        List() {
          ListItem() {
            Column() {
              Button({ type: ButtonType.Normal }) {
                Row() {
                  SymbolGlyph($r('sys.symbol.square_fill_grid_2x2'))
                    .fontSize(24)
                    .fontColor([$r('app.color.whut_blue')])
                  TextInput({ text: this.courseInformation?.courseName })
                    .type(InputType.Normal)
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .backgroundColor(Color.Transparent)
                    .onChange((value: string) => {
                      if (this.courseInformation) {
                        this.courseInformation.courseName = value
                      }
                    })
                }
                .margin({ left: $r('app.float.md_padding_margin') })
              }
              .backgroundColor(Color.Transparent)

              Button({ type: ButtonType.Normal }) {
                Row() {
                  SymbolGlyph($r('sys.symbol.solid_color_mixing'))
                    .fontSize(24)
                    .fontColor([this.courseColor])
                  Text('点击选择颜色')
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontColor(this.courseColor)
                    .padding({left: 16})
                }
                .width('100%')
                .margin({ left: $r('app.float.md_padding_margin') })
              }
              .width('100%')
              .height($r('app.float.list_row_button_height'))
              .enabled(false)
              .backgroundColor(Color.Transparent)
            }
            .backgroundColor($r('sys.color.background_primary'))
          }
          .clip(true)
          .borderRadius($r('app.float.main_border_radius'))
          .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
          .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ?
            { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 10 } :
            { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 10 })

          LazyForEach(this.courseSchedule, (item: CourseSchedule, index: number) => {
            ListItemGroup({header: this.courseScheduleHeader(index)}) {
              ListItem() {
                CourseScheduleEditCard({courseSchedule: item})
              }
              .clip(true)
              .borderRadius($r('app.float.main_border_radius'))
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ?
                { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 10 } :
                { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 10 })
            }
            .margin({top: 20})
          }, (item: CourseSchedule, index: number) => JSON.stringify(item) + index.toString())
        }

      }

    }
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onReady((scheduleNavContext: NavDestinationContext) => {
      let param = scheduleNavContext.pathInfo.param as Record<string, object>;
      this.courseId = param.courseId as String;
      this.tableId = param.tableId as String;
      this.onDestinationBack = param.onDestinationBack as () => void;
      console.debug(TAG, 'onReady', this.courseId, this.tableId);
      this.courseInformation =
        new ScheduleDatabaseFunc().queryCourseInformation(this.tableId as string, this.courseId as string);
      this.courseSchedule = new ScheduleDatabaseFunc().queryCourseAllSchedule(this.courseInformation as Course,
        new Schedule(this.tableId as string, '', ''));
      this.courseColor =
        new ScheduleDatabaseFunc().queryCourseColorByString(this.tableId as string, this.courseId as string)
    })
  }
}

@Component
struct CourseScheduleEditCard {

  @ObjectLink courseSchedule: CourseSchedule;

  @State @Watch('confirmWeekRangeChange') weekRangeList: string = ''

  private weekPickerController: CustomDialogController = new CustomDialogController({
    builder: WeekRangePicker({
      weekRanges: this.weekRangeList,
      confirm: this.confirmWeekRangeChange
    })
  })

  confirmWeekRangeChange() {
    if (this.weekRangeList !== this.courseSchedule.weekRanges) {
      this.courseSchedule.weekRanges = this.weekRangeList;
      console.debug('weekRanges', this.weekRangeList)
      this.courseSchedule.weekRangesStr = compressRange(this.weekRangeList);
      console.debug(this.courseSchedule.weekRangesStr)
    }
  }

  aboutToAppear(): void {
    this.weekRangeList = this.courseSchedule.weekRanges
  }

  build() {
    Column() {
      Button({type: ButtonType.Normal}) {
        Row() {
          SymbolGlyph($r('sys.symbol.calendar_fill'))
            .fontSize(24)
            .fontColor([$r('app.color.whut_blue')])
          Text('第' + this.courseSchedule.weekRangesStr + '周')
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .padding({left: 16})
        }
        .width('100%')
        .margin({ left: $r('app.float.md_padding_margin') })
      }
      .width('100%')
      .backgroundColor(Color.Transparent)
      .height($r('app.float.list_row_button_height'))
      .onClick(() => {
        this.weekPickerController.open()
      })

      Button({type: ButtonType.Normal}) {
        Row() {
          SymbolGlyph($r('sys.symbol.clock_fill'))
            .fontSize(24)
            .fontColor(['#ffdc143c'])
          Text('星期' + this.courseSchedule.WeekDay + ' 第' + this.courseSchedule.StartSession + '-' +
          this.courseSchedule.EndSession + '节' +
            ' ' + `${TIME_TABLE[this.courseSchedule.StartSession as number -
            1].StartTime}-${TIME_TABLE[this.courseSchedule.EndSession as number - 1].EndTime}`)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .padding({left: 16})
        }
        .width('100%')
        .margin({ left: $r('app.float.md_padding_margin') })
      }
      .backgroundColor(Color.Transparent)
      .height($r('app.float.list_row_button_height'))

      Button({type: ButtonType.Normal}) {
        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_circle_fill'))
            .fontSize(24)
            .fontColor(['#ffff7f50'])
          Text(this.courseSchedule.Place.search('undefined') === -1 ? this.courseSchedule.Place : '暂无')
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .padding({ left: 16 })
        }
        .width('100%')
        .margin({ left: $r('app.float.md_padding_margin') })
      }
      .backgroundColor(Color.Transparent)
      .height($r('app.float.list_row_button_height'))
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .borderRadius($r('app.float.main_border_radius'))
  }
}

@Builder
export function EditCourseInformationBuilder() {
  EditCourseInformation()
}