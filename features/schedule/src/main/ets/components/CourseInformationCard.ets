import { DateUtil } from '@ohos/utils/src/main/ets/utils/DateUtil';
import { Course } from '../model/Course';
import { CourseSchedule } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { classDateAndPlaceToCourseSchedule } from '../service/ScheduleBaseFunc';
import { JSON, taskpool } from '@kit.ArkTS';
import { classDateAndPlaceToCourseScheduleTask } from '../service/ScheduleTookPoolFunc';
import { EventType, LazyDataSource, VibrateUtil } from '@ohos/utils';
import { SymbolGlyphModifier, TipsDialog } from '@kit.ArkUI';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { common } from '@kit.AbilityKit';

const TAG = '[ClassInformationCard]';

async function getCourseScheduleTask(course: Course, isList: boolean) {
  let task: taskpool.Task = new taskpool.Task(classDateAndPlaceToCourseScheduleTask, course, isList);
  return await taskpool.execute(task) as CourseSchedule[]
}

@Reusable
@Component
export struct ClassInformationCard {
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @LocalStorageLink('deleteCourse') deleteCourse: boolean = false;
  // @LocalStorageLink('updateCourse') @Watch('updateCourseInformation') updateCourse: boolean = false;
  @State @Watch('updateCourseInformation') courseInformation: Course = new Course();
  @ObjectLink courseInformationList: LazyDataSource<Course>;
  @Prop selectedSchedule: Schedule;
  @State courseSchedules: LazyDataSource<CourseSchedule> = new LazyDataSource();
  @State isShow: boolean = false;
  longPressEnable?: boolean;
  index: number = -1;
  private mDate = new DateUtil();
  jumpEditCourseInformation: (courseId: string, tableId: string) => void = () => {

  };
  confirmDialogController: CustomDialogController | null = new CustomDialogController({
    builder: TipsDialog({
      title: '删除课程',
      content: '操作无法撤回',
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {

        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          new ScheduleDatabaseFunc().deleteCourse(this.selectedSchedule.scheduleId, this.courseInformation.classId);
          this.courseInformationList.deleteData(this.index);
          const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
          eventHub.emit(EventType.DELETE_COURSE)
        },
        fontColor: $r('sys.color.warning')
      }
    })
  })

  @Styles
  scheduleCardStyle() {
    .width('100%')
    .height($r('app.float.schedule_card_item_height'))
    .margin($r('app.float.course_card_padding'))
  }

  aboutToAppear(): void {
    const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
    if (this.courseInformation && this.courseInformation.classDateAndPlace) {
      console.debug(TAG, 'aboutToAppear', JSON.stringify(this.courseInformation))
      let courseScheduleList =
        classDateAndPlaceToCourseSchedule(this.courseInformation, new Schedule('', '', ''), false);
      if (courseScheduleList) {
        this.courseSchedules.pushArrayData(courseScheduleList);
      }
      // this.getCourseSchedule()
    }
    eventHub.on(EventType.UPDATE_COURSE, (): void => this.updateCourseInformation())
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.courseInformation = params.courseInformation as Course;
    if (this.courseInformation && this.courseInformation.classDateAndPlace) {
      console.debug(TAG, 'aboutToReuse', JSON.stringify(this.courseInformation))
      let courseScheduleList =
        classDateAndPlaceToCourseSchedule(this.courseInformation, new Schedule('', '', ''), false);
      if (courseScheduleList) {
        this.courseSchedules.pushArrayData(courseScheduleList);
      }
      // this.getCourseSchedule()
    }
  }

  updateCourseInformation() {
    if (this.courseInformation.classDateAndPlace) {
      let courseScheduleList =
        classDateAndPlaceToCourseSchedule(this.courseInformation, new Schedule('', '', ''), false);
      if (courseScheduleList) {
        this.courseSchedules.pushArrayData(courseScheduleList);
      }
    }
    console.debug(TAG, 'aboutToAppear', JSON.stringify(this.courseSchedules))
  }

  getCourseSchedule() {
    getCourseScheduleTask(this.courseInformation, false).then((courseScheduleList) => {
      this.courseSchedules.pushArrayData(courseScheduleList);
      console.debug(TAG, 'aboutToAppear', JSON.stringify(this.courseSchedules))
    })
  }

  @Builder
  longPressMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.pencil_and_card')).fontSize(24),
        content: '编辑'
      })
        .onClick(() => {
          this.jumpEditCourseInformation(this.courseInformation.classId, this.selectedSchedule.scheduleId);
        })
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.trash')).fontSize(24).fontColor([$r('sys.color.warning')]),
        content: '删除'
      })
        .contentFontColor($r('sys.color.warning'))
        .onClick(() => {
          this.confirmDialogController?.open()
        })
    }
  }

  build() {
    Column() {
      Row() {
        Text(this.courseInformation.courseName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.course_card_font_default_color'))
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .padding($r('app.float.course_card_padding'))

      Column({ space: 5 }) {
        LazyForEach(this.courseSchedules, (item: CourseSchedule) => {
          Column() {
            Row() {
              SymbolGlyph($r('sys.symbol.calendar_fill'))
                .fontSize(20)
                .fontColor([$r('app.color.whut_blue')])
              Text('第' + item.weekRangesStr + '周')
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
    .backgroundColor($r('app.color.course_card_bg_default_color'))
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    // .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .borderRadius($r('app.float.main_border_radius'))
    .padding($r('app.float.course_card_padding'))
    .renderFit(RenderFit.RESIZE_CONTAIN)
    .bindMenu(this.isShow, this.longPressMenu(), {
      onDisappear: () => {
        this.isShow = false;
      }
    })
    .width('100%')
    .gesture(
      LongPressGesture()
        .onAction(() => {
          if (this.longPressEnable) {
            VibrateUtil.getInstance().longPressVibrate();
            this.isShow = true;
          }
        })
    )
  }
}