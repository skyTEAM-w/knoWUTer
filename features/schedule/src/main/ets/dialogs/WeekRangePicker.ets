import { BreakPointType, BreakPointTypeEnum } from '@ohos/utils/src/main/ets/utils/BreakPoint';

@CustomDialog
@Component
export struct WeekRangePicker {
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @Link weekRanges: string;
  @State weekRangeNumbers: number[] = [];
  @State weekRangeSelectedStatus: boolean[] = new Array(21).fill(false);
  controller?: CustomDialogController;
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  aboutToAppear(): void {
    this.weekRangeNumbers = this.weekRanges.split(',').map(Number)
    this.weekRangeNumbers.forEach((item: number) => {
      this.weekRangeSelectedStatus[item - 1] = true;
    })
  }

  buildSelectedWeekList() {
    let result: string[] = [];
    this.weekRangeSelectedStatus.forEach((value: boolean, index: number) => {
      if (value) {
        result.push((index + 1).toString())
      }
    })
    return result.join(',')
  }

  @Builder
  weekPickerItem(index: number) {
    Button({ type: ButtonType.Circle }) {
      Text((index + 1).toString())
        .fontSize(12)
        .margin(5)
        .fontWeight(FontWeight.Medium)
    }
    .height($r('app.float.interactive_button_height'))
    .width($r('app.float.interactive_button_height'))
    .backgroundColor(this.weekRangeSelectedStatus[index] ? $r('app.color.whut_yellow') :
    $r('app.color.whut_yellow_background_selected'))
    .margin(5)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
    .onClick(() => {
      this.weekRangeSelectedStatus[index] = !this.weekRangeSelectedStatus[index];
    })
  }

  build() {
    Column() {
      Text('选择上课周')
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .margin({ top: 10, bottom: 10 })
      List() {
        ForEach(this.weekRangeSelectedStatus, (value: boolean, index: number) => {
          ListItem() {
            this.weekPickerItem(index)
          }
        })
      }
      .lanes(new BreakPointType({ sm: 6, md: 7, lg: 8 }).getValue(this.currentBreakPoint))
      .margin({ left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin') })

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
            this.weekRanges = this.buildSelectedWeekList();
            this.controller?.close()
          }).backgroundColor(Color.Transparent).fontColor($r('sys.color.brand_font'))
      }
      .width("100%")
      .margin({ bottom: 10, top: 10 })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
  }
}