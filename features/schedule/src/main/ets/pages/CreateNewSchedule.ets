import { TextInputDialog, TopNavigationView } from '@ohos/uicomponents';
import { BreakPointType, BreakPointTypeEnum, DateUtil, LazyDataSource } from '@ohos/utils';
import { intl } from '@kit.LocalizationKit';
import { Course } from '../model/Course';
import { getSchedule, ScheduleNetFunc } from '../service/ScheduleNetFunc';
import { ClassInformationCard } from '../components/CourseInformationCard';
import { promptAction, TipsDialog } from '@kit.ArkUI';
import { Schedule } from '../model/Schedule';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { classDateAndPlaceToCourseSchedule } from '../service/ScheduleBaseFunc';
import { JSON, taskpool } from '@kit.ArkTS';

const INTERVAL = 30;
const DURATION = 300;

const TAG = '[CreateNewSchedule]'

async function getCourseListTask(cookie: string) {
  let task: taskpool.Task = new taskpool.Task(getSchedule, cookie);
  return await taskpool.execute(task) as Course[];
}

@Component
export struct CreateNewSchedule {
  @StorageLink('schedule_cookie') ScheduleCookie: string = AppStorage.get<string>('schedule_cookie') || '';
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @State @Watch('triggerCourseCardAnimation') courseList: LazyDataSource<Course> = new LazyDataSource();
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @State scheduleName: string = '未命名';
  @State inputName: string = '未命名';
  textInputDialogController: CustomDialogController | null = new CustomDialogController({
    builder: TextInputDialog({
      textValue: $inputName,
      inputValue: $scheduleName,
      changeText: '命名课表',
      cancel: () => {
      },
      confirm: () => {
      }
    })
  })
  confirmDialogController: CustomDialogController | null = new CustomDialogController({
    builder: TipsDialog({
      title: '导入课表',
      content: '确认导入该课表吗?',
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {

        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          this.saveNewSchedule();
          promptAction.showToast({ message: '保存成功' })
          this.onDestinationBack()
        }
      }
    })
  })
  private scheduleNetFunc: ScheduleNetFunc = new ScheduleNetFunc();
  private dateUtil = new DateUtil();
  @State selectedDate: Date = new Date(this.dateUtil.getToday())
  private scheduleDBFunc = new ScheduleDatabaseFunc();
  onDestinationBack: () => void = () => {
  };

  aboutToAppear(): void {
    this.getCourseList();
  }

  onBackPress(): boolean | void {

  }

  getCourseList() {
    // this.courseList = await this.scheduleNetFunc.getSchedule(this.ScheduleCookie);
    getCourseListTask(this.ScheduleCookie).then((courseList) => {
      if (courseList) {
        this.courseList.pushArrayData(courseList);
        // this.courseList.reloadData();
        console.debug(TAG, 'aboutToAppear', JSON.stringify(this.courseList))
      }

    })
  }

  triggerCourseCardAnimation() {
    this.getUIContext().animateTo({
      duration: DURATION + INTERVAL * (this.courseList?.totalCount() as number - 1),
      curve: Curve.Friction
    }, () => {

    })
  }

  saveNewSchedule() {
    if (this.courseList) {
      let resultSet = this.scheduleDBFunc.queryScheduleInfomationByScheduleName(new Schedule('', this.scheduleName,
        new intl.DateTimeFormat("zh-cn", { dateStyle: 'short' }).format(this.selectedDate)));

      if (resultSet && resultSet.rowCount > 0) {
        this.scheduleName += resultSet.rowCount.toString()
      }
      let scheduleId = this.scheduleDBFunc.insertScheduleInformation(new Schedule('', this.scheduleName,
        new intl.DateTimeFormat("zh-cn", { dateStyle: 'short' }).format(this.selectedDate)));
      console.debug(TAG, 'scheduleId', scheduleId);
      let courseArray: Course[] | undefined = this.courseList?.getDataList();
      if (courseArray && scheduleId) {
        const scheduleInfomation =
          new Schedule(scheduleId.toString(), this.scheduleName,
            new intl.DateTimeFormat("zh-cn", { dateStyle: 'short' }).format(this.selectedDate))
        console.debug(TAG, 'scheduleInfomation', JSON.stringify(scheduleInfomation))
        this.scheduleDBFunc.insertCourseInformation(courseArray, scheduleInfomation);
        courseArray.forEach((course: Course) => {
          if (course.classDateAndPlace) {
            const courseSchedule = classDateAndPlaceToCourseSchedule(course, scheduleInfomation, true);
            this.scheduleDBFunc.insertCourseSchedule(courseSchedule);
          }
        })
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
      this.confirmDialogController?.open()
    })
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          title: '创建课程表',
          onBackClick: () => this.onDestinationBack(),
          menuView: () => this.checkCreateMenu()
        })
        Column() {
          Column() {
            Column() {
              Row() {
                Text('学期第一天')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)

                Text(new intl.DateTimeFormat("zh-cn", { dateStyle: 'short' }).format(this.selectedDate))
                  .fontSize(14)
                  .fontColor(Color.Grey)
                  .height('100%')
                  .onClick(() => {
                    CalendarPickerDialog.show({
                      selected: this.selectedDate,
                      onAccept: (value: Date) => {
                        this.selectedDate = value;
                      }
                    })
                  })
              }.width('100%')
              .height($r('app.float.interactive_row_height'))
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })

              Divider()
              Row() {
                Text('课表名称')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)

                Text(this.scheduleName)
                  .fontSize(14)
                  .fontColor(Color.Grey)
                  .height('100%')
                  .onClick(() => {
                    if (this.textInputDialogController !== null) {
                      this.textInputDialogController.open();
                    }
                  })
              }.width('100%')
              .height($r('app.float.interactive_row_height'))
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })

            }
            .borderRadius($r('app.float.main_border_radius'))
            .backgroundColor($r('app.color.start_window_background'))

          }
          .padding({ left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })


          Row() {
            Text('课程信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .padding($r('app.float.course_card_padding'))
          }

          // if (!this.courseList.isEmpty()) {
          WaterFlow() {
            LazyForEach(this.courseList, (item: Course, index: number) => {
              if (!this.courseList.isEmpty()) {
                FlowItem() {
                  ClassInformationCard({ courseInfomation: item })
                }
                .padding({ left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })
                .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.8, y: 0.8 }))
                  .animation({ duration: DURATION, curve: Curve.Friction, delay: INTERVAL * index }))

              } else {
                FlowItem() {
                  LoadingProgress()
                }

              }
            })
            FlowItem() {

            }
            .height('90%')
          }
          .cachedCount(3)
          .columnsTemplate(new BreakPointType({
            sm: '1fr',
            md: '1fr 1fr',
            lg: '1fr 1fr 1fr'
          }).getValue(this.currentBreakPoint))
          .columnsGap($r('app.float.course_card_padding'))
          .rowsGap($r('app.float.course_card_padding'))
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

          // }
        }
        .margin({ top: 10 })
      }
      .height('100%')
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
export function CreateNewScheduleBuilder() {
  CreateNewSchedule();
}