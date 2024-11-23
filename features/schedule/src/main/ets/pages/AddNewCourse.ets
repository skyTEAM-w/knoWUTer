import { BreakPointTypeEnum, DateUtil, EventType, LazyDataSource } from '@ohos/utils';
import { TipsDialog } from '@kit.ArkUI';
import { ColorSelectDialog, TopNavigationView } from '@ohos/uicomponents';
import { Course } from '../model/Course';
import { CourseSchedule } from '../model/CourseSchedule';
import { CourseScheduleEditCard } from './EditCourseInformation';
import { courseScheduleToClassDateAndPlace } from '../service/ScheduleBaseFunc';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { Schedule } from '../model/Schedule';
import { JSON } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';


@Component
export struct AddNewCourse {
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageProp('selectedTableId') selectedTableId: string | undefined =
    AppStorage.get<string>('selectedTableId') || '1';
  @LocalStorageLink('updateCourse') updateCourse: boolean = false;
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State courseInformation: Course | undefined = undefined;
  @State courseSchedule: LazyDataSource<CourseSchedule> = new LazyDataSource();
  @State courseColor: ResourceColor = '#FF000000';
  confirmDialogController: CustomDialogController | null = new CustomDialogController({
    builder: TipsDialog({
      title: '保存新的课程',
      content: '确认保存吗?',
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
  private scheduleDbFunc = new ScheduleDatabaseFunc();
  private mDate = new DateUtil();
  private scheduleCount = 0;

  onDestinationBack: () => void = () => {
  };

  aboutToAppear(): void {
    this.courseInformation = new Course();
    this.courseInformation.classId = String(this.mDate.getToday() + (Math.random() * 1000).toFixed(4));
    this.courseInformation.courseNo = String(this.mDate.getFullYear().toString() + this.mDate.getMonth());
    this.courseInformation.courseSerialNum = String(this.mDate.getFullYear().toString() + this.mDate.getMonth());
  }

  saveCourseInfomation() {
    if (this.courseInformation && this.courseSchedule) {
      this.courseInformation.classDateAndPlace =
        courseScheduleToClassDateAndPlace(this.courseSchedule?.getDataList() as CourseSchedule[]);
      this.courseInformation.courseName =
        this.courseInformation.courseName === '' ? '新课程' : this.courseInformation.courseName;
      console.debug(JSON.stringify(this.courseInformation))
      this.scheduleDbFunc.insertCourseInformation([this.courseInformation],
        new Schedule(this.selectedTableId as string, '', ''),
        this.courseColor.toString())
      console.debug('courseScheduleList', JSON.stringify(this.courseSchedule.getDataList()))
      this.scheduleDbFunc.updateCourseSchedule(this.courseSchedule.getDataList(), this.courseInformation);
      // this.updateCourse = !this.updateCourse;
      const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
      eventHub.emit(EventType.UPDATE_COURSE);
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
          this.courseSchedule.pushData(new CourseSchedule('1', this.selectedTableId as string,
            this.courseInformation.classId,
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
          title: '添加课程',
          onBackClick: () => this.onDestinationBack(),
          menuView: () => this.checkCreateMenu()
        })
        GridRow({ columns: { sm: 6, md: 6, lg: 10 } }) {
          GridCol({ span: { lg: 1 }, offset: 0, order: 0 })
          GridCol({ span: { lg: 1 }, offset: 0, order: 2 })
          GridCol({ span: { sm: 6, md: 6, lg: 8 }, order: 1 }) {
            List() {
              ListItem() {
                Column() {
                  Button({ type: ButtonType.Normal }) {
                    Row() {
                      SymbolGlyph($r('sys.symbol.square_fill_grid_2x2'))
                        .fontSize(24)
                        .fontColor([$r('app.color.whut_blue')])
                      TextInput({ placeholder: '课程名称', text: this.courseInformation?.courseName })
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
          }
        }
      }
    }
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onReady((scheduleNavContext: NavDestinationContext) => {
      let param = scheduleNavContext.pathInfo.param as Record<string, object>;
      this.onDestinationBack = param.onDestinationBack as () => void;
    })
  }
}

@Builder
export function AddNewCourseBuilder() {
  AddNewCourse();
}