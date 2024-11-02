import LazyDataSource from '../common/model/LazyDataSource';
import { DBUtil } from '../common/utils/DBUtil';
import { DormitoryLocation } from '../model/DormitoryLocation';
import { ElectricityFeeUrl } from '../model/ElectricityFeeUrl';
import { DownloadFileButton, DownloadIconStyle, promptAction } from '@kit.ArkUI';
import { getElectricCharge } from '../common/utils/PayElectricCharge';
import { webview } from '@kit.ArkWeb';

@Component
export struct ElectricityInquiryTool {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State @Watch('onBindSheetShow') isShow: boolean = false;
  @State tableSet: LazyDataSource<DormitoryLocation> = new LazyDataSource();
  @State selectedDormitoryIndex: number = -1;
  @State selectedDormitory: DormitoryLocation | undefined = undefined;
  @State electricityFee: string | undefined = undefined;
  @State isRefresh: boolean = false;
  private webViewController: webview.WebviewController = new webview.WebviewController();

  jumpWebView() {
    this.isShow = false;
    this.appPathStack.pushPathByName('WebViewPage', new Object({
      webUrl: new ElectricityFeeUrl(),
      isImport: true,
      onDestinationBack: () => {
        this.appPathStack.pop();
        return false;
      }
    }))
  }

  jumpWebViewToRefresh() {
    if (this.selectedDormitory !== undefined) {
      this.appPathStack.pushPathByName('WebViewPage', new Object({
        webUrl: new ElectricityFeeUrl(),
        dormitoryLocation: this.selectedDormitory,
        isRefresh: true,
        onDestinationBack: () => {
          this.electricityFee = DBUtil.getInstance().queryDormitoryElectricityFee(this.selectedDormitory) as string;
          this.appPathStack.pop();
          return false;
        }
      }))
    } else {
      promptAction.showToast({ message: '未选择宿舍' })
    }
  }

  onBindSheetShow() {
    if (this.isShow) {
      this.tableSet = DBUtil.getInstance().queryDormitoryHistory()
    }
  }

  checkSelectedDormitory() {
    this.isShow = false;
    this.selectedDormitory = this.tableSet.getData(this.selectedDormitoryIndex);
    this.electricityFee = DBUtil.getInstance().queryDormitoryElectricityFee(this.selectedDormitory) as string;
  }

  @Builder
  DormitoryBindSheet() {
    if (!this.isRefresh) {
      List() {
        ListItemGroup({ header: this.DormitoryHistorySheetHeader(), space: 5 }) {
          LazyForEach(this.tableSet, (item: DormitoryLocation, index: number) => {
            ListItem() {
              this.DormitoryHistorySheetItem(item, index)
            }
          })
        }
      }
      .sticky(StickyStyle.Header)
      .padding({ left: 16, right: 16 })
    } else {
      Web({ src: new ElectricityFeeUrl().url, controller: this.webViewController })
    }

  }

  @Builder
  DormitoryHistorySheetHeader() {
    RowSplit() {
      Text('校区')
        .textAlign(TextAlign.Center)
        .fontWeight(600)
        .width('25%')
      Text('宿舍楼')
        .textAlign(TextAlign.Center)
        .fontWeight(600)
        .width('25%')
      Text('楼层')
        .textAlign(TextAlign.Center)
        .fontWeight(600)
        .width('25%')
      Text('房间')
        .textAlign(TextAlign.Center)
        .fontWeight(600)
        .width('25%')
    }
    .width('100%')
    .padding({ bottom: 10 })
  }

  @Builder
  DormitoryHistorySheetItem(item: DormitoryLocation, index: number) {
    Row() {
      Text(`${item.Area}`)
        .textAlign(TextAlign.Center)
        .fontSize(12)
        .fontWeight(400)
        .width('24%')
      Text(`${item.Building}`)
        .textAlign(TextAlign.Center)
        .fontSize(12)
        .fontWeight(400)
        .width('24%')
      Text(`${item.Floor}`)
        .fontSize(12)
        .textAlign(TextAlign.Center)
        .fontWeight(400)
        .width('24%')
      Text(`${item.Room}`)
        .fontSize(12)
        .textAlign(TextAlign.Center)
        .fontWeight(400)
        .width('24%')
    }
    .width('100%')
    .height(44)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(this.selectedDormitoryIndex === index ? $r('app.color.whut_blue_background') :
    $r('app.color.start_window_background'))
    .onClick(() => {
      this.selectedDormitoryIndex = index;
    })
    .borderRadius(8)
  }

  @Builder
  BindSheetTitle() {
    Row() {
      if (!this.isRefresh) {
        Row({ space: 10 }) {
          Text('已导入的宿舍')
            .fontSize(18)
            .fontWeight(700)
            .fontFamily('HarmonyHeiTi-medium')
            .textAlign(TextAlign.Start)

          Row({ space: 20 }) {
            DownloadFileButton({
              contentOptions: {
                icon: DownloadIconStyle.FULL_FILLED
              },
              styleOptions: {
                iconColor: Color.Black,
                iconSize: 24,
                fontWeight: FontWeight.Medium
              }
            })
              .onClick(() => this.jumpWebView())

            SymbolGlyph($r('sys.symbol.checkmark'))
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.checkSelectedDormitory();
              })
          }
        }
        .height(56)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ right: 16 })
      } else {
        Row({ space: 10 }) {
          Text('更新宿舍信息')
            .fontSize(18)
            .fontWeight(700)
            .fontFamily('HarmonyHeiTi-medium')
            .textAlign(TextAlign.Start)

          SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              if (this.isRefresh && this.selectedDormitory !== undefined) {
                getElectricCharge(this.webViewController, this.selectedDormitory).then((fee) => {
                  this.electricityFee = fee;
                  this.isShow = false;
                  promptAction.showToast({message: '更新成功'})
                })
              }
            })
        }
        .height(56)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ right: 16 })
      }
    }

  }

  build() {
    Column() {

      Row() {
        Text('电费查询')
          .fontSize(18)
          .fontWeight(700)
          .fontFamily('HarmonyHeiTi-medium')
          .textAlign(TextAlign.Start)
        SymbolGlyph($r('sys.symbol.arrow_counterclockwise_clock'))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.isShow = true;
            console.info('bind sheet')
          })
          .bindSheet($$this.isShow, this.DormitoryBindSheet, {
            title: this.BindSheetTitle(),
            detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200],
            scrollSizeMode: ScrollSizeMode.CONTINUOUS,
            preferType: SheetType.CENTER,
            onDisappear: () => {
              this.isRefresh = false;
            }
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .padding({bottom: 5})

      Text(this.selectedDormitory !== undefined ? `${this.selectedDormitory.Room}` : '请选择')
        .textAlign(TextAlign.Start)
        .fontSize(16)
        .height(20)
        .width('100%')
        .borderRadius(8)

      Divider()
        .padding({ top: 5, bottom: 5 })

      Row() {
        Text('剩余电费：')
          .fontSize(16)
          .fontWeight(700)
          .fontFamily('HarmonyHeiTi-medium')
          .textAlign(TextAlign.Start)
        Text(this.electricityFee === undefined ? '元' : this.electricityFee + '元')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi-medium')
          .textAlign(TextAlign.Start)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')

      Row() {
        Button('更新')
          .width('100%')
          .fontColor(Color.Black)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            if (this.selectedDormitory !== undefined) {
              this.isRefresh = true;
              this.isShow = true;
            } else {
              promptAction.showToast({message: '未选择宿舍'})
            }
          })
      }

    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.whut_blue_background'))
    .borderRadius($r('app.float.border_radius'))
    .borderWidth(1)
    .borderStyle(BorderStyle.Solid)
    .width('100%')
    .clickEffect({level: ClickEffectLevel.MIDDLE})
    .padding({
      left: 16,
      right: 16,
      top: 10,
      bottom: 10
    })
  }
}