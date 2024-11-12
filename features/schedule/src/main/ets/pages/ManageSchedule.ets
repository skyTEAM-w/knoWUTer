import { TopNavigationView } from '@ohos/uicomponents';
import { BreakPointTypeEnum, LazyDataSource } from '@ohos/utils';
import { Schedule } from '../model/Schedule';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { promptAction, SymbolGlyphModifier } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { it } from '@ohos/hypium';
import { paddingCourseSchedule } from '../service/ScheduleBaseFunc';

const TAG = 'ManageSchedule'

@Component
export struct ManageSchedule {
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @StorageLink('selectScheduleIndex') selectedScheduleTableIndex: number =
    AppStorage.get<number>('selectScheduleIndex') || -1;
  @State scheduleList: LazyDataSource<Schedule> = new LazyDataSource();
  @State @Watch('showConfirmDialog') mSelectedIndex: number = -1;
  private scheduleDBFunc = new ScheduleDatabaseFunc();
  onDestinationBack: () => void = () => {
  };

  aboutToAppear(): void {
    this.scheduleList.pushArrayData(this.scheduleDBFunc.queryAllScheduleTable() as Schedule[]);
    // let csList = this.scheduleDBFunc.queryCourseScheduleByWeek(this.scheduleList.getData(1), 11, 4);
    // if (csList) {
    //   console.debug(TAG, JSON.stringify(paddingCourseSchedule(csList)))
    // }
  }

  deleteSelectedSchedule(index: number) {
    if (!this.scheduleList.isEmpty()) {
      let schedule = this.scheduleList.getData(index)
      console.debug(TAG, 'deleteSelectedSchedule', JSON.stringify(schedule));
      this.scheduleDBFunc.deleteSchedule(schedule);
      this.scheduleList.deleteData(index);
    }
    if (index < this.selectedScheduleTableIndex) {
      this.selectedScheduleTableIndex -= 1;
    }
  }

  showConfirmDialog() {
    if (this.mSelectedIndex !== -1) {
      AlertDialog.show({
        title: '确认删除该课表吗？',
        autoCancel: true,
        buttons: [
          {
            value: $r('app.string.cancel'),
            action: () => {
            }
          },
          {
            value: $r('app.string.confirm'),
            action: () => {
              animateTo({
                duration: 250,
                onFinish: () => {
                  this.scheduleList.reloadData();
                  this.mSelectedIndex = -1;
                }
              }, () => {
                this.deleteSelectedSchedule(this.mSelectedIndex)
              })

            },
            fontColor: $r('sys.color.warning')
          }
        ],
        message: "操作无法撤回"
      })
    }
  }

  @Builder
  listBindMenu(index: number) {
    Menu() {
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.trash')).fontSize(24),
        content: '删除'
      })
        .onClick(() => {
          if (index === this.selectedScheduleTableIndex) {
            promptAction.showToast({ message: '无法删除正在展示的课程表' })
          } else {
            this.mSelectedIndex = index;
          }
        })
    }
  }

  @Builder
  listItem(item: Schedule) {
    Button({ type: ButtonType.Normal }) {
      Row() {
        Text(item.scheduleName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width("50%")
          .textAlign(TextAlign.Start)
          .margin({ left: 5 })
        Text(item.StartDate)
          .fontSize(14)
          .fontColor(Color.Gray)
          .width("50%")
          .textAlign(TextAlign.End)
          .margin({ right: 5 })
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin(16)
    }
    .width("100%")
    .backgroundColor(Color.Transparent)
  }

  build() {
    NavDestination() {
      TopNavigationView({
        title: '管理课程表',
        onBackClick: () => {
          this.onDestinationBack();
        }
      })

      List() {
        LazyForEach(this.scheduleList, (item: Schedule, index: number) => {
          ListItem() {
            this.listItem(item);
          }
          .transition({ type: TransitionType.Delete, opacity: 0 })
          .bindMenu(this.listBindMenu(index))
        }, (item: Schedule, index: number) => JSON.stringify(item) + index.toString())
      }
      .divider({ strokeWidth: 1, color: $r('sys.color.ohos_id_divider_color') })
      .borderRadius($r('app.float.main_border_radius'))
      .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
      .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ?
        { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 10 } :
        { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 10 })

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
export function ManageScheduleBuilder() {
  ManageSchedule();
}