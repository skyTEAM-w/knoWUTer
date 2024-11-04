import LazyDataSource from '../common/model/LazyDataSource';
import { DBUtil } from '../common/utils/DBUtil';
import { DormitoryLocation } from '../common/model/DormitoryLocation';
import { ElectricityFeeUrl } from '../model/ElectricityFeeUrl';
import { DownloadFileButton, DownloadIconStyle, promptAction } from '@kit.ArkUI';
import { getElectricCharge } from '../common/utils/PayElectricCharge';
import { webview } from '@kit.ArkWeb';
import { it } from '@ohos/hypium';
import { ArrayList, JSON } from '@kit.ArkTS';
import { faceDetector } from '@kit.CoreVisionKit';
import { ElectricityFeeActionType, HttpUtil } from '../common/utils/HttpUtil';
import { Area } from '../common/model/Area';
import { Building } from '../common/model/Building';

const TAG = '[Elec Comp]'

@Component
export struct ElectricityInquiryTool {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State @Watch('onBindSheetShow') isShow: boolean = false;
  @State areaPickerList: string[] = [];
  @State tableSet: LazyDataSource<DormitoryLocation> = new LazyDataSource();
  @State selectedDormitoryIndex: number = -1;
  @State selectedDormitory: DormitoryLocation | undefined = undefined;
  @State electricityFee: string | undefined = undefined;
  @State isRefresh: boolean = false;
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private scroller: ListScroller = new ListScroller()

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
    if (this.selectedDormitoryIndex === -1) {
      promptAction.showToast({message: '未选择宿舍'});
      return;
    }
    this.isShow = false;
    this.selectedDormitory = this.tableSet.getData(this.selectedDormitoryIndex);
    HttpUtil.getInstance().getAreaListHttp(AppStorage.get<string>('fee_cookie') as string)
    this.electricityFee = DBUtil.getInstance().queryDormitoryElectricityFee(this.selectedDormitory) as string;
  }

  async parseAreaListToPickerList() {
    let httpAreaList = await HttpUtil.getInstance().getAreaListHttp(AppStorage.get<string>('fee_cookie') as string)
    if (this.areaPickerList.length === 0) {
      httpAreaList.forEach((item: Area) =>{
        this.areaPickerList.push(item.area);
      })
    }
    HttpUtil.getInstance().getBuildingListHttp(AppStorage.get<string>('fee_cookie') as string, new Area('0002', '0002'))
    HttpUtil.getInstance().getFloorListHttp(AppStorage.get<string>('fee_cookie') as string, new Area('0002', '0002'), new Building('000023', '000023'))
  }

  @Builder
  DormitoryBindSheet() {
    if (!this.isRefresh) {
      List({scroller: this.scroller}) {
        ListItemGroup({ header: this.DormitoryHistorySheetHeader(), space: 5 }) {
          LazyForEach(this.tableSet, (item: DormitoryLocation, index: number) => {
              DormitoryItem({dormitoryItem: item, selectedDormitoryIndex: this.selectedDormitoryIndex,
                mIndex: index, tableSet: this.tableSet})
          })
        }
      }
      .sticky(StickyStyle.Header)
      .padding({ left: 16, right: 16 })
    } else {
      Web({ src: new ElectricityFeeUrl().url, controller: this.webViewController })
        .onPageEnd(() => {
          let FeeCookie = webview.WebCookieManager.fetchCookieSync('http://cwsf.whut.edu.cn/nyyPayElecPages51274E035').toString();
          AppStorage.setOrCreate('fee_cookie', FeeCookie);
          console.info(TAG, FeeCookie);
        })
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
      Text('电费查询')
        .fontSize(18)
        .fontWeight(700)
        .fontFamily('HarmonyHeiTi-medium')
        .textAlign(TextAlign.Start)
        .width('100%')
        .padding({bottom: 5})

      Row() {
        Text(this.selectedDormitory !== undefined ? `${this.selectedDormitory.Room}` : '请选择')
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .height(20)
          .borderRadius(8)
        SymbolGlyph($r('sys.symbol.arrow_counterclockwise_clock'))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)

      }
      .onClick(() => {
        this.isShow = true;
        console.info(TAG, 'Bind Sheet Show')
      })
      .bindSheet($$this.isShow, this.DormitoryBindSheet, {
        title: this.BindSheetTitle(),
        detents: [SheetSize.MEDIUM, SheetSize.LARGE],
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        preferType: SheetType.CENTER,
        onDisappear: () => {
          this.isRefresh = false;
        }
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')

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

      Column() {
        TextPicker({ range: this.areaPickerList })
          .textStyle({font: {size: 12}})
          .selectedTextStyle({font: {size: 16}})
          .disappearTextStyle({font: {size: 8}})
          .defaultPickerItemHeight(18)
        Button('cookie')
          .onClick(() => {
            this.isRefresh = true;
            this.isShow = true;
          })
        Button('http')
          .onClick(() => {
            this.parseAreaListToPickerList()
          })
      }

    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.whut_blue_background'))
    .borderRadius($r('app.float.border_radius'))
    .borderWidth(1)
    .borderStyle(BorderStyle.Solid)
    .width('100%')
    .clickEffect({level: ClickEffectLevel.LIGHT})
    .padding({
      left: 16,
      right: 16,
      top: 10,
      bottom: 10
    })
  }
}

@Component
struct DormitoryItem {
  @ObjectLink dormitoryItem: DormitoryLocation;
  @Link selectedDormitoryIndex: number;
  @ObjectLink tableSet: LazyDataSource<DormitoryLocation>;
  @State enterDeleteArea: boolean = false;
  private startTrigger: number = 0;
  mIndex: number = -1;

  @Builder
  ListItemSwiper() {
    Row() {
      SymbolGlyph(this.dormitoryItem.isStar ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
        .fontSize(25)
        .fontWeight(FontWeight.Medium)
        .fontColor([$r('app.color.whut_yellow')])
        .margin("10vp")
        .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.startTrigger)
        .onClick(() => this.checkStarDormitory())
      SymbolGlyph(this.enterDeleteArea ? $r('sys.symbol.trash_fill') : $r('sys.symbol.trash'))
        .fontSize(25)
        .fontWeight(FontWeight.Medium)
        .fontColor([Color.Red])
        .margin("10vp")
    }.padding($r('sys.float.corner_radius_level2')).justifyContent(FlexAlign.SpaceEvenly)
  }

  checkStarDormitory() {
    this.startTrigger++;
    this.dormitoryItem.isStar = !this.dormitoryItem.isStar;
    this.tableSet.changeData(this.mIndex, this.dormitoryItem);
    console.info(JSON.stringify(this.dormitoryItem))
    DBUtil.getInstance().updateDormitoryStarStatus(this.dormitoryItem);
  }

  deleteDormitory() {
    this.selectedDormitoryIndex = -1;
    DBUtil.getInstance().deleteDormitory(this.dormitoryItem);
    this.tableSet.deleteData(this.mIndex);
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
    .backgroundColor(this.selectedDormitoryIndex === index ? $r('app.color.whut_blue_background_selected') :
      this.dormitoryItem.isStar ? $r('app.color.whut_yellow_background_selected') : $r('app.color.start_window_background'))
    .onClick(() => {
      this.selectedDormitoryIndex = index;
    })
    .borderRadius(8)
  }

  build() {
    ListItem() {
      this.DormitoryHistorySheetItem(this.dormitoryItem, this.mIndex);
    }
    .transition({type: TransitionType.Delete, opacity: 0})
    .swipeAction({
      end: {builder: () => this.ListItemSwiper(),
      onAction: () => {
        animateTo({duration: 500,
        onFinish: () => {
          this.tableSet.reloadData();
        }}, () => {
          this.deleteDormitory()
        })
      },
        actionAreaDistance: 75,
      onEnterActionArea: () => {
        this.enterDeleteArea = true;
      },
      onExitActionArea: () => {
        this.enterDeleteArea = false;
      }}
    })
  }
}