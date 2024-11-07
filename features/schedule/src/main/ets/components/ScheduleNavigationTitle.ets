import { DownloadFileButton } from "@ohos.arkui.advanced.DownloadFileButton"
import { DateUtil } from "@ohos/utils";

@Component
export struct ScheduleNavigation {
  @Link selectedDate: Date;
  @Link isShow: boolean;

  @Styles
  barButtonStyle() {
    .height($r('app.float.interactive_button_height'))
    .width($r('app.float.interactive_button_height'))
    .backgroundColor(Color.Transparent)
  }

  build() {
    Row() {
      Column() {
        TextClock()
          .format('yyyy/MM/dd')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        TextClock()
          .format('EEEE')
      }
      .alignItems(HorizontalAlign.Start)

      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.download'))
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
        }
        .barButtonStyle()
        .onClick(() => {
          CalendarPickerDialog.show({
            selected: this.selectedDate,
            onAccept: (value: Date) => {
              this.selectedDate = value;
            }
          })
        })
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
        }
        .barButtonStyle()
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
        }
        .barButtonStyle()
        .onClick(() => {
          this.isShow = true;
        })
      }
    }
    .height($r('app.float.schedule_navigation_height'))
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: AppStorage.get<number>('statusBarHeight'),
      left: $r('app.float.md_padding_margin'),
      right: $r('app.float.md_padding_margin')
    })
  }
}