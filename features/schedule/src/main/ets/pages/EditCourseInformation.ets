import { DBUtil } from "@ohos/datastore/src/main/ets/datasotore/DBUtil";
import { expect } from "@ohos/hypium";
import { NavigationTitleBar, TopNavigationView } from "@ohos/uicomponents"
import { ScheduleDatabaseFunc } from "../service/ScheduleDatabaseFunc";

const TAG = '[EditCourseInformation]'

@Component
export struct EditCourseInformation {


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

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          title: '编辑课程',
          onBackClick: () => this.onDestinationBack(),
          menuView: () => this.checkCreateMenu()
        })

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
      // new ScheduleDatabaseFunc().queryCourseInformation(this.tableId.toString(), this.courseId.toString())
    })
  }
}

@Builder
export function EditCourseInformationBuilder() {
  EditCourseInformation()
}