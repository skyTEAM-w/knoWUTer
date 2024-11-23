import { CourseSchedule } from '../model/CourseSchedule';
import { JSON } from '@kit.ArkTS';
import { compressRange } from '../service/ScheduleBaseFunc';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { common } from '@kit.AbilityKit';
import { EventType } from '@ohos/utils';

enum SelectedType {
  DeleteThisSchedule = 0,
  DeleteWeekdaySchedule = 1,
  DeleteCourse = 2,
  NONE = 3
}

@CustomDialog
@Component
export struct DeleteOptionDialog {
  @Prop selectedWeek: number;
  @Prop courseSchedule: CourseSchedule;
  @LocalStorageLink('deleteCourse') deleteCourse: boolean = false;
  @StorageProp('selectedTableId') selectedTableId: string | undefined =
    AppStorage.get<string>('selectedTableId') || '1';
  controller?: CustomDialogController;
  private weekRangeSelectedStatus: boolean[] = new Array(21).fill(false);
  private weekRangeNumbers: number[] = [];
  private choice: SelectedType = SelectedType.NONE;

  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  aboutToAppear(): void {
    console.debug(this.selectedWeek.toString(), JSON.stringify(this.courseSchedule));
    this.weekRangeNumbers = this.courseSchedule.weekRanges.split(',').map(Number);
    this.weekRangeNumbers.forEach((item: number) => {
      this.weekRangeSelectedStatus[item - 1] = true;
    })
  }

  onConfirm() {
    const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
    switch (this.choice) {
      case SelectedType.DeleteThisSchedule: {
        this.courseSchedule.weekRanges = this.buildSelectedWeekList();
        this.courseSchedule.weekRangesStr = compressRange(this.courseSchedule.weekRanges);
        console.debug(JSON.stringify(this.courseSchedule));
        new ScheduleDatabaseFunc().updateOneCourseSchedule(this.courseSchedule);
        eventHub.emit(EventType.DELETE_COURSE)
        break;
      }
      case SelectedType.DeleteWeekdaySchedule: {
        new ScheduleDatabaseFunc().deleteCourseSchedule([this.courseSchedule]);
        eventHub.emit(EventType.DELETE_COURSE)
        break;
      }
      case SelectedType.DeleteCourse: {
        new ScheduleDatabaseFunc().deleteCourse(this.courseSchedule.TableId, this.courseSchedule.ClassId);
        eventHub.emit(EventType.DELETE_COURSE)
        break;
      }
      default: {

        break;
      }
    }

  }

  buildSelectedWeekList() {
    let result: string[] = [];
    this.weekRangeSelectedStatus.forEach((value: boolean, index: number) => {
      if (value && index + 1 !== this.selectedWeek) {
        result.push((index + 1).toString())
      }
    })
    return result.join(',')
  }

  @Styles
  radioStyle() {
    .width('100%')
  }

  build() {
    Column() {
      Column({ space: 5 }) {
        Text('删除课程')
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
        Text(this.courseSchedule.CourseName)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontWeight(FontWeight.Medium)
      }
      .margin({ top: 10, bottom: 10 })

      Column({ space: 10 }) {
        Row({ space: 10 }) {
          Radio({ value: 'deleteThisSchedule', group: 'deleteRadio' })
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.choice = SelectedType.DeleteThisSchedule
              }
            })
          Text(`仅删除${this.selectedWeek}周周${this.courseSchedule.WeekDay}的当前课程`)
        }
        .justifyContent(FlexAlign.Start)
        .radioStyle()

        Row({ space: 10 }) {
          Radio({ value: 'deleteWeekdaySchedule', group: 'deleteRadio' })
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.choice = SelectedType.DeleteWeekdaySchedule
              }
            })
          Text(`删除星期${this.courseSchedule.WeekDay}的该课程的所有安排`)
        }
        .justifyContent(FlexAlign.Start)
        .radioStyle()

        Row({ space: 10 }) {
          Radio({ value: 'deleteCourse', group: 'deleteRadio' })
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.choice = SelectedType.DeleteCourse
              }
            })
          Text(`删除该课程`)
        }
        .radioStyle()
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .padding({ left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin') })

      Row() {
        Button($r('app.string.cancel'))
          .width('40%')
          .onClick(() => {
            this.controller?.close()
          }).backgroundColor(Color.Transparent).fontColor($r('sys.color.brand_font'))
        Divider()
          .vertical(true)
          .height(33)
        Button($r('app.string.confirm'))
          .width('40%')
          .onClick(() => {
            this.onConfirm()
            this.controller?.close()
          }).backgroundColor(Color.Transparent).fontColor($r('sys.color.brand_font'))
      }
      .width("100%")
      .margin({ bottom: 10, top: 10 })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .margin({ bottom: 10, top: 10 })
  }
}