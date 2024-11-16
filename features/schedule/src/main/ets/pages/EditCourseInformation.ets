import { ColorSelectDialog, TopNavigationView } from '@ohos/uicomponents';
import { BreakPointTypeEnum, LazyDataSource } from '@ohos/utils';
import { WeekRangePicker } from '../dialogs/WeekRangePicker';
import { Course } from '../model/Course';
import { CourseSchedule, TIME_TABLE, TimeTable, WEEKS } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { compressRange, courseScheduleToClassDateAndPlace } from '../service/ScheduleBaseFunc';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { JSON } from '@kit.ArkTS';
import { PlaceInputDialog } from '../dialogs/PlaceInputDialog';
import { TipsDialog } from '@kit.ArkUI';

const TAG = '[EditCourseInformation]'

@Component
export struct EditCourseInformation {
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @LocalStorageLink('updateCourse') updateCourse: boolean = false;
  @State courseInformation: Course | undefined = undefined;
  @State courseSchedule: LazyDataSource<CourseSchedule> | undefined = undefined;
  @State courseColor: ResourceColor = '#FFFFFF';
  confirmDialogController: CustomDialogController | null = new CustomDialogController({
    builder: TipsDialog({
      title: '修改课表',
      content: '确认保存修改的内容吗?',
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {

        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          this.saveCourseInfomation();
          this.onDestinationBack();
        }
      }
    })
  })
  colorSelectDialogController: CustomDialogController = new CustomDialogController({
     builder: ColorSelectDialog({
       color: this.courseColor
     })
  })
  courseId: String = '';
  tableId: String = '';
  private deletedCourseSchedule: CourseSchedule[] = [];
  private scheduleCount: number = 0;
  private scheduleDbFunc = new ScheduleDatabaseFunc();
  onDestinationBack: () => void = () => {
  };

  saveCourseInfomation() {
    if (this.courseInformation && this.courseSchedule) {
      this.courseInformation.classDateAndPlace =
        courseScheduleToClassDateAndPlace(this.courseSchedule?.getDataList() as CourseSchedule[]);
      console.debug(JSON.stringify(this.deletedCourseSchedule))
      this.scheduleDbFunc.deleteCourseSchedule(this.deletedCourseSchedule);
      this.scheduleDbFunc.updateCourseInfomation(this.courseInformation, this.tableId.toString(),
        this.courseColor.toString())
      // console.debug(TAG, 'courseScheduleList', JSON.stringify(this.courseSchedule.getDataList()))
      this.scheduleDbFunc.updateCourseSchedule(this.courseSchedule.getDataList(), this.courseInformation);
      this.updateCourse = !this.updateCourse;
    }
  }

  deleteCourseSchedule(index: number) {
    if (this.courseSchedule) {
      console.debug(TAG, 'delete')
      this.deletedCourseSchedule.push(this.courseSchedule.getData(index))
      this.courseSchedule.deleteData(index);
    }
  }

  insertNewCourseSchedule() {
    if (this.courseSchedule) {
      if (!this.courseSchedule.isEmpty()) {
        let newSchedule = this.courseSchedule.getData(this.courseSchedule.totalCount() - 1);
        this.courseSchedule.pushData(new CourseSchedule(newSchedule.weekRanges, newSchedule.TableId,
          newSchedule.ClassId,
          newSchedule.CourseName,
          (this.scheduleCount++).toString(), newSchedule.WeekDay, newSchedule.StartSession,
          newSchedule.EndSession, newSchedule.Place, newSchedule.weekRangesStr));
        this.courseSchedule.reloadData();
      } else {
        if (this.courseInformation) {
          this.courseSchedule.pushData(new CourseSchedule('1', this.tableId.toString(), this.courseId.toString(),
            this.courseInformation.courseName,
            (this.scheduleCount++).toString(), '一', 1, 2, 'undefined', '1'));
        }

      }
    }
  }

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
      this.confirmDialogController?.open();
    })
  }

  @Builder
  courseScheduleHeader(index: number) {
    Row() {
      Text(`课程安排${index + 1}`)
        .fontSize(14)
      Button() {
        Text('删除')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.End)
          .fontColor($r('sys.color.warning'))
      }
      .height(20)
      .width(33)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        animateTo({
          duration: 250,
          curve: Curve.Friction,
          onFinish: () => {
            this.courseSchedule?.reloadData();
          }
        }, () => {
          this.deleteCourseSchedule(index)
        })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin') })
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          title: '编辑课程',
          onBackClick: () => this.onDestinationBack(),
          menuView: () => this.checkCreateMenu()
        })
        GridRow({ columns: { sm: 6, md: 6, lg: 10 } }) {
          GridCol({ span: { lg: 1 }, offset: 0 })
          GridCol({ span: { sm: 6, md: 6, lg: 8 } }) {
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
                        .padding({ left: 16 })
                    }
                    .width('100%')
                    .margin({ left: $r('app.float.md_padding_margin') })
                  }
                  .width('100%')
                  .height($r('app.float.list_row_button_height'))
                  .backgroundColor(Color.Transparent)
                  .onClick(() => {
                    this.colorSelectDialogController.open()
                  })
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
                ListItemGroup({ header: this.courseScheduleHeader(index) }) {
                  ListItem() {
                    CourseScheduleEditCard({ courseSchedule: item })
                  }
                  .clip(true)
                  .borderRadius($r('app.float.main_border_radius'))
                  .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                  .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ?
                    { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 10 } :
                    { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 10 })
                }
                .transition({ type: TransitionType.All, opacity: 0 })
                .margin({ top: 20 })
              }, (item: CourseSchedule, index: number) => JSON.stringify(item) + index.toString())

              ListItem() {
                Button({ type: ButtonType.Normal }) {
                  Column({ space: 10 }) {
                    SymbolGlyph($r('sys.symbol.plus'))
                      .fontSize(33)
                      .fontWeight(FontWeight.Regular)
                    Text('新建课程安排')
                  }
                  .opacity(0.6)
                  .margin(10)
                }
                .width('100%')
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  animateTo({
                    duration: 250,
                    curve: Curve.Friction
                  }, () => {
                    this.insertNewCourseSchedule()
                  })
                })
              }
              .clip(true)
              .borderRadius($r('app.float.main_border_radius'))
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ?
                { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 20 } :
                { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 20 })

              ListItem()
                .height('20%')
            }
            .scrollBar(BarState.Off)
          }

          GridCol({ span: { lg: 1 }, offset: 0 })
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
      this.courseInformation =
        new ScheduleDatabaseFunc().queryCourseInformation(this.tableId as string, this.courseId as string);
      this.courseSchedule = new ScheduleDatabaseFunc().queryCourseAllSchedule(this.courseInformation as Course,
        new Schedule(this.tableId as string, '', ''));
      this.courseColor =
        new ScheduleDatabaseFunc().queryCourseColorByString(this.tableId as string, this.courseId as string);
      this.scheduleCount = this.courseSchedule?.totalCount() as number;
    })
  }
}

@Component
export struct CourseScheduleEditCard {
  @ObjectLink courseSchedule: CourseSchedule;
  @State @Watch('confirmWeekRangeChange') weekRangeList: string = ''
  @State courseWeek: string = '';
  @State startSession: number = 0;
  @State endSession: number = 0;
  @State @Watch('confirmCoursePlaceChange') coursePlace: string = '';
  @State selectedTimeIndex: number[] = [0, 0, 0];
  private weeks: string[] = [];
  private timeTable: string[] = []
  private weekPickerController: CustomDialogController = new CustomDialogController({
    builder: WeekRangePicker({
      weekRanges: this.weekRangeList,
      confirm: this.confirmWeekRangeChange
    })
  })
  private placeInputController: CustomDialogController = new CustomDialogController({
    builder: PlaceInputDialog({
      coursePlace: this.coursePlace
    })
  })

  aboutToAppear(): void {
    this.weekRangeList = this.courseSchedule.weekRanges;
    this.weeks = WEEKS.map(value => '周' + value);
    this.timeTable = TIME_TABLE.map((item: TimeTable) => '第' + item.session.toString() + '节')
    this.selectedTimeIndex[0] = WEEKS.indexOf(this.courseSchedule.WeekDay);
    this.selectedTimeIndex[1] = this.courseSchedule.StartSession - 1;
    this.selectedTimeIndex[2] = this.courseSchedule.EndSession - 1;
    this.coursePlace = this.courseSchedule.Place;
  }

  confirmWeekRangeChange() {
    if (this.weekRangeList !== this.courseSchedule.weekRanges) {
      this.courseSchedule.weekRanges = this.weekRangeList;
      console.debug('weekRanges', this.weekRangeList)
      this.courseSchedule.weekRangesStr = compressRange(this.weekRangeList);
      console.debug(this.courseSchedule.weekRangesStr)
    }
  }

  confirmCoursePlaceChange() {
    if (this.coursePlace !== this.courseSchedule.Place) {
      this.courseSchedule.Place = this.coursePlace;
    }
  }

  build() {
    Column() {
      Button({ type: ButtonType.Normal }) {
        Row() {
          SymbolGlyph($r('sys.symbol.calendar_fill'))
            .fontSize(24)
            .fontColor([$r('app.color.whut_blue')])
          Text('第' + this.courseSchedule.weekRangesStr + '周')
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .padding({ left: 16 })
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

      Button({ type: ButtonType.Normal }) {
        Row() {
          SymbolGlyph($r('sys.symbol.clock_fill'))
            .fontSize(24)
            .fontColor(['#ffdc143c'])
          Text('星期' + this.courseSchedule.WeekDay + ' 第' + this.courseSchedule.StartSession + '-' +
          this.courseSchedule.EndSession + '节' +
            ' ' + `${TIME_TABLE[this.courseSchedule.StartSession as number -
            1].StartTime}-${TIME_TABLE[this.courseSchedule.EndSession as number - 1].EndTime}`)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .padding({ left: 16 })
        }
        .width('100%')
        .margin({ left: $r('app.float.md_padding_margin') })
      }
      .backgroundColor(Color.Transparent)
      .height($r('app.float.list_row_button_height'))
      .onClick(() => {
        this.getUIContext().showTextPickerDialog({
          selected: this.selectedTimeIndex,
          range: [this.weeks, this.timeTable, this.timeTable],
          onAccept: (result: TextPickerResult) => {
            if (result.index[1] > result.index[2]) {
              this.selectedTimeIndex[2] = this.selectedTimeIndex[1] = result.index[1];
            } else {
              this.selectedTimeIndex[1] = result.index[1];
              this.selectedTimeIndex[2] = result.index[2];
            }
            this.selectedTimeIndex[0] = result.index[0];
            this.courseSchedule.WeekDay = WEEKS[this.selectedTimeIndex[0]];
            this.courseSchedule.StartSession = this.selectedTimeIndex[1] + 1;
            this.courseSchedule.EndSession = this.selectedTimeIndex[2] + 1;
          }
        })
      })

      Button({ type: ButtonType.Normal }) {
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
      .onClick(() => {
        this.placeInputController.open()
      })
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