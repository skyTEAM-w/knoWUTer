import { ElectricityFeeUrl, LazyDataSource, UserSettingUtil } from '@ohos/utils';
import { Area, Building, DormitoryLocation, Floor, Room } from '../model/DormitoryLocation';
import { DownloadFileButton, DownloadIconStyle, promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { ArrayList, JSON } from '@kit.ArkTS';
import { HttpReserve } from '../model/HttpPostResponse';
import {
  checkLoginStatusForCWSF,
  getAreaListHttp,
  getBuildingListHttp,
  getElectricityFeeHttp,
  getFloorListHttp,
  getMeterIdHttp,
  getRoomListHttp
} from '../service/ToolsNetFunc';
import {
  deleteDormitory,
  insertOrUpdateDormitory,
  queryAreaListDataBase,
  queryBuildingListDataBase,
  queryDormitoryElectricityFeeAndRemainPower,
  queryDormitoryHistory,
  queryFloorListDataBase,
  queryRoomListDataBase,
  updateDormitoryStarStatus
} from '../service/ToolsDatabaseFunc';

const TAG = '[Elec Comp]'

@Component
export struct ElectricityInquiryTool {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State @Watch('onBindSheetShow') isShow: boolean = false;
  @State areaPickerList: string[] = ['---'];
  @State buildingPickerList: string[] = ['---'];
  @State floorPickerList: string[] = ['---'];
  @State roomPickerList: string[] = ['---'];
  @State pickerList: string[][] =
    [this.areaPickerList, this.buildingPickerList, this.floorPickerList, this.roomPickerList]
  @State tableSet: LazyDataSource<DormitoryLocation> = new LazyDataSource();
  @State selectedDormitoryIndex: number = -1;
  @State selectedDormitory: DormitoryLocation | undefined = undefined;
  @State electricityFee: string | undefined = undefined;
  @State remainPower: string | undefined = undefined;
  @State electricityFeeHistory: string | undefined = undefined;
  @State remainPowerHistory: string | undefined = undefined;
  @State isRefresh: boolean = false;
  @State showChoice: boolean = false;
  @State @Watch('loginButtonAnimation') loginStatus: boolean = false;
  @State loginButtonStatus: boolean = false;
  @State selectedArea: ResourceStr = $r('app.string.text_please_select');
  @State selectedAreaIndex: number = 0;
  @State selectedBuilding: ResourceStr = $r('app.string.text_please_select');
  @State selectedBuildingIndex: number = 0;
  @State selectedFloor: ResourceStr = $r('app.string.text_please_select');
  @State selectedFloorIndex: number = 0;
  @State selectedRoom: ResourceStr = $r('app.string.text_please_select');
  @State selectedRoomIndex: number = 0;
  @StorageLink('fee_cookie') FeeCookie: string = AppStorage.get<string>('fee_cookie') || '';
  private areaList: ArrayList<Area> | undefined = undefined;
  private buildList: ArrayList<Building> | undefined = undefined;
  private floorList: ArrayList<Floor> | undefined = undefined;
  private roomList: ArrayList<Room> | undefined = undefined;
  private httpReserve: HttpReserve | undefined = undefined;
  private webViewController: webview.WebviewController = new webview.WebviewController();
  private scroller: ListScroller = new ListScroller();
  private userUtil: UserSettingUtil = UserSettingUtil.getInstance();

  aboutToAppear(): void {
    this.userUtil.checkCWSFCookie();
    this.refreshLoginState();
    this.getAreaList();
  }

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

  onBindSheetShow() {
    if (this.isShow) {
      this.tableSet = queryDormitoryHistory()
    }
  }

  loginButtonAnimation() {
    this.getUIContext().animateTo({ duration: 200 }, () => {
      this.loginButtonStatus = this.loginStatus;
    })
  }

  async refreshLoginState() {
    this.loginStatus = await checkLoginStatusForCWSF(this.FeeCookie);
    console.debug(TAG, 'login status: ', JSON.stringify(this.loginStatus))
    if (this.loginStatus) {
      this.isShow = false;
      this.isRefresh = false;
      promptAction.showToast({ message: '登录成功' })
      this.getAreaList();
    }
  }

  async checkSelectedDormitory() {
    if (this.selectedDormitoryIndex === -1) {
      promptAction.showToast({ message: '未选择宿舍' });
      return;
    }
    this.isShow = false;
    this.selectedDormitory = this.tableSet.getData(this.selectedDormitoryIndex);
    if (!await this.getElectricityFeeAndPower(new Room(this.selectedDormitory.Room, this.selectedDormitory.RoomId),
      true)) {
      this.electricityFeeHistory =
        (queryDormitoryElectricityFeeAndRemainPower(this.selectedDormitory) as string[])[0];
      this.remainPowerHistory =
        (queryDormitoryElectricityFeeAndRemainPower(this.selectedDormitory) as string[])[1]
    }
  }

  async getAreaList() {
    if (this.areaList = queryAreaListDataBase()) {
      this.parseAreaListToPickerList(this.areaList);
    } else {
      this.areaList = await getAreaListHttp(AppStorage.get<string>('fee_cookie') as string)
      if (this.areaList) {
        this.parseAreaListToPickerList(this.areaList);
      }
    }

    this.selectedAreaIndex = 0;
    this.selectedArea = this.areaPickerList[this.selectedAreaIndex];
    if (this.areaList) {
      this.getBuildingList(this.areaList[this.selectedAreaIndex])
    }
  }

  async getBuildingList(area: Area) {
    if (this.buildList = queryBuildingListDataBase(area)) {
      this.parseBuildingListToPickerList(this.buildList);
    } else {
      this.buildList = await getBuildingListHttp(AppStorage.get<string>('fee_cookie') as string, area);
      if (this.buildList) {
        this.parseBuildingListToPickerList(this.buildList);
      }
    }
    this.selectedBuildingIndex = 0;
    this.selectedBuilding = this.buildingPickerList[this.selectedBuildingIndex];
    if (this.buildList && this.areaList) {
      this.getFloorList(this.areaList[this.selectedAreaIndex], this.buildList[this.selectedBuildingIndex]);
    }
  }

  async getFloorList(area: Area, building: Building) {
    if (this.floorList = queryFloorListDataBase(building)) {
      this.parseFloorListToPickerList(this.floorList);
    } else {
      this.floorList =
        await getFloorListHttp(AppStorage.get<string>('fee_cookie') as string, area, building);
      if (this.floorList) {
        this.parseFloorListToPickerList(this.floorList);
      }
    }
    this.selectedFloorIndex = 0;
    this.selectedFloor = this.floorPickerList[this.selectedFloorIndex];
    if (this.buildList && this.floorList) {
      this.getRoomList(this.buildList[this.selectedBuildingIndex], this.floorList[this.selectedFloorIndex]);
    }
  }

  async getRoomList(building: Building, floor: Floor) {
    if (this.roomList = queryRoomListDataBase(building, floor)) {
      this.parseRoomListToPickerList(this.roomList)
    } else {
      this.roomList =
        await getRoomListHttp(AppStorage.get<string>('fee_cookie') as string, building, floor);
      if (this.roomList) {
        this.parseRoomListToPickerList(this.roomList);
      }
    }
    this.selectedRoomIndex = 0;
    this.selectedRoom = this.roomPickerList[this.selectedRoomIndex];
    this.getElectricityFeeAndPower(this.roomList?.[this.selectedRoomIndex], false)
  }

  async getElectricityFee(cookie: string, room: Room) {
    let meter = await getMeterIdHttp(cookie, room);
    if (meter) {
      let httpReserve = await getElectricityFeeHttp(cookie, meter);
      if (httpReserve) {
        console.debug(JSON.stringify(httpReserve));
        return httpReserve;
      }
      return undefined;
    }
    return undefined;
  }

  async getElectricityFeeAndPower(room: Room | undefined, isHistory: boolean) {
    if (room) {
      this.httpReserve = await this.getElectricityFee(AppStorage.get<string>('fee_cookie') as string, room)
      if (this.httpReserve) {
        if (isHistory) {
          this.electricityFeeHistory = this.httpReserve.meterOverdue;
          this.remainPowerHistory = this.httpReserve.remainPower;
        } else {
          this.electricityFee = this.httpReserve.meterOverdue;
          this.remainPower = this.httpReserve.remainPower;
        }

        return true;
      }
      return false;
    }
    return false;
  }

  saveDormitory() {
    if (this.areaList && this.buildList && this.floorList && this.roomList && this.httpReserve) {
      let dormitoryLocation: DormitoryLocation = new DormitoryLocation()
      dormitoryLocation.Area = this.areaList[this.selectedAreaIndex].area;
      dormitoryLocation.AreaId = this.areaList[this.selectedAreaIndex].areaId;
      dormitoryLocation.Building = this.buildList[this.selectedBuildingIndex].Building;
      dormitoryLocation.BuildingId = this.buildList[this.selectedBuildingIndex].BuildingId;
      dormitoryLocation.Floor = this.floorList[this.selectedFloorIndex].Floor;
      dormitoryLocation.FloorId = this.floorList[this.selectedFloorIndex].FloorId;
      dormitoryLocation.Room = this.roomList[this.selectedRoomIndex].Room;
      dormitoryLocation.RoomId = this.roomList[this.selectedRoomIndex].RoomId;

      console.debug(TAG, 'http reserve', JSON.stringify(this.httpReserve))

      insertOrUpdateDormitory(dormitoryLocation, this.httpReserve.meterOverdue,
        this.httpReserve.remainPower);
    }
  }

  parseAreaListToPickerList(areaList: ArrayList<Area>) {
    let temp: string[] = []
    areaList.forEach((item: Area) => {
      temp.push(item.area);
    })
    this.areaPickerList = temp;
  }

  parseBuildingListToPickerList(buildingList: ArrayList<Building>) {
    let temp: string[] = []
    buildingList.forEach((item: Building) => {
      temp.push(item.Building);
    })
    this.buildingPickerList = temp;
  }

  parseFloorListToPickerList(floorList: ArrayList<Floor>) {
    let temp: string[] = [];
    floorList.forEach((item: Floor) => {
      temp.push(item.Floor);
    })
    this.floorPickerList = temp;
  }

  parseRoomListToPickerList(roomList: ArrayList<Room>) {
    let temp: string[] = [];
    roomList.forEach((item: Room) => {
      temp.push(item.Room);
    })
    this.roomPickerList = temp;
  }

  @Builder
  DormitoryBindSheet() {
    if (!this.isRefresh) {
      List({ scroller: this.scroller }) {
        ListItemGroup({ header: this.DormitoryHistorySheetHeader(), space: 5 }) {
          LazyForEach(this.tableSet, (item: DormitoryLocation, index: number) => {
            DormitoryItem({
              dormitoryItem: item,
              selectedDormitoryIndex: this.selectedDormitoryIndex,
              mIndex: index,
              tableSet: this.tableSet
            })
          })
        }
      }
      .sticky(StickyStyle.Header)
      .margin({ left: 16, right: 16 })
    } else {
      Web({ src: new ElectricityFeeUrl().url, controller: this.webViewController })
        .onPageEnd(() => {
          let FeeCookie =
            webview.WebCookieManager.fetchCookieSync('http://cwsf.whut.edu.cn/nyyPayElecPages51274E035').toString();
          this.userUtil.saveCWSFCookie(FeeCookie);
          console.info(TAG, FeeCookie);
          this.refreshLoginState();
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
          Text('登录')
            .fontSize(18)
            .fontWeight(700)
            .fontFamily('HarmonyHeiTi-medium')
            .textAlign(TextAlign.Start)
        }
        .height(56)
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .padding({ right: 16 })
      }
    }

  }

  build() {
    Column() {
      Row({ space: 5 }) {
        Text('电费查询')
          .fontSize(18)
          .fontWeight(700)
          .fontFamily('HarmonyHeiTi-medium')
          .textAlign(TextAlign.Start)
          .onClick(() => {
            this.isRefresh = true;
            this.isShow = true;
          })
        Button() {
          if (!this.loginButtonStatus) {
            Text('未登录')
              .fontSize(10)
              .fontColor($r('sys.color.warning'))
              .transition(TransitionEffect.OPACITY
                .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 })))
          } else {
            Text('已登录')
              .fontSize(10)
              .fontColor($r('sys.color.confirm'))
              .transition(TransitionEffect.OPACITY
                .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 })))
          }
        }
        .enabled(!this.loginButtonStatus)
        .backgroundColor(Color.Transparent)
        .border({ width: 2 })
        .borderColor(this.loginStatus ? $r('sys.color.confirm') : $r('sys.color.warning'))
        .height('70%')
        .width(44)
        .onClick(() => {
          this.isShow = true;
          this.isRefresh = true;
        })
      }
      .padding({ bottom: 5 })
      .width('100%')
      .height(33)

      if (!this.showChoice) {
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
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.8, y: 0.5 })))
      }

      if (!this.showChoice) {
        Column() {
          Divider()
            .padding({ top: 5, bottom: 5 })
          Row() {
            Text('剩余电费：')
              .fontSize(16)
              .fontWeight(700)
              .fontFamily('HarmonyHeiTi-medium')
              .textAlign(TextAlign.Start)
            Text(this.electricityFeeHistory === undefined ? '元' : this.electricityFeeHistory + '元')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontFamily('HarmonyHeiTi-medium')
              .textAlign(TextAlign.Start)
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')

        }
        .geometryTransition('remain')
        .transition(TransitionEffect.OPACITY)

      } else {
        Column() {
          Row() {
            Text('校区：')
              .fontSize(16)
              .fontWeight(700)
              .fontFamily('HarmonyHeiTi-medium')
              .textAlign(TextAlign.Start)
            Button(this.selectedArea)
              .fontColor(Color.Black)
              .backgroundColor(Color.Transparent)
              .width('70%')
              .onClick(() => {
                this.getUIContext().showTextPickerDialog({
                  range: this.areaPickerList,
                  selected: this.selectedAreaIndex,
                  onAccept: (value: TextPickerResult) => {
                    this.selectedArea = value.value as string;
                    this.selectedAreaIndex = value.index as number;
                    if (this.areaList) {
                      this.getBuildingList(this.areaList[value.index as number])
                    }
                  }
                })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {

            Text('楼栋: ')
              .fontSize(16)
              .fontWeight(700)
              .fontFamily('HarmonyHeiTi-medium')
              .textAlign(TextAlign.Start)
            Button(this.selectedBuilding)
              .fontColor(Color.Black)
              .backgroundColor(Color.Transparent)
              .width('70%')
              .onClick(() => {
                this.getUIContext().showTextPickerDialog({
                  range: this.buildingPickerList,
                  selected: this.selectedBuildingIndex,
                  onAccept: (value: TextPickerResult) => {
                    this.selectedBuilding = value.value as string;
                    this.selectedBuildingIndex = value.index as number;
                    if (this.buildList && this.areaList) {
                      this.getFloorList(this.areaList[this.selectedAreaIndex], this.buildList[value.index as number])
                    }
                  }
                })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('楼层: ')
              .fontSize(16)
              .fontWeight(700)
              .fontFamily('HarmonyHeiTi-medium')
              .textAlign(TextAlign.Start)
            Button(this.selectedFloor)
              .fontColor(Color.Black)
              .backgroundColor(Color.Transparent)
              .width('70%')
              .onClick(() => {
                this.getUIContext().showTextPickerDialog({
                  range: this.floorPickerList,
                  selected: this.selectedFloorIndex,
                  onAccept: (value: TextPickerResult) => {
                    this.selectedFloor = value.value as string;
                    this.selectedFloorIndex = value.index as number;
                    if (this.buildList && this.floorList) {
                      this.getRoomList(this.buildList[this.selectedBuildingIndex],
                        this.floorList[this.selectedFloorIndex]);
                    }
                  }
                })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('房间: ')
              .fontSize(16)
              .fontWeight(700)
              .fontFamily('HarmonyHeiTi-medium')
              .textAlign(TextAlign.Start)

            Button(this.selectedRoom)
              .fontColor(Color.Black)
              .backgroundColor(Color.Transparent)
              .width('70%')
              .onClick(() => {
                this.getUIContext().showTextPickerDialog({
                  range: this.roomPickerList,
                  selected: this.selectedRoomIndex,
                  onAccept: async (value: TextPickerResult) => {
                    this.selectedRoom = value.value as string;
                    this.selectedRoomIndex = value.index as number;
                    if (this.roomList) {
                      this.getElectricityFeeAndPower(this.roomList[this.selectedRoomIndex], false)
                    }
                  }
                })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)


          Column() {
            Divider()
              .padding({ top: 5, bottom: 5 })
            Row() {
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
              .width('45%')
              .geometryTransition('remain')

              Row() {
                Text('剩余电量：')
                  .fontSize(16)
                  .fontWeight(700)
                  .fontFamily('HarmonyHeiTi-medium')
                  .textAlign(TextAlign.Start)
                Text(this.electricityFee === undefined ? '度' : this.remainPower + '度')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontFamily('HarmonyHeiTi-medium')
                  .textAlign(TextAlign.Start)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('45%')

            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')

          }
          .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.8, y: 0.8 })))

          Row() {
            Button($r('app.string.text_save'))
              .width('70%')
              .fontColor(Color.Black)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.saveDormitory();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

        }
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.8, y: 0.8 })))
      }

      Row() {
        SymbolGlyph(this.showChoice ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
          .fontSize(20)
          .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.showChoice)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        animateTo({ duration: 250, curve: Curve.Friction }, () => {
          this.showChoice = !this.showChoice
        })
      })
    }
    .bindSheet($$this.isShow, this.DormitoryBindSheet, {
      title: this.BindSheetTitle(),
      detents: [SheetSize.MEDIUM, SheetSize.LARGE],
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      preferType: SheetType.CENTER,
      onDisappear: () => {
        this.isRefresh = false;
      }
    })
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.whut_blue_background'))
    .borderRadius($r('app.float.border_radius'))
    .borderWidth(1)
    .borderStyle(BorderStyle.Solid)
    .width('100%')
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.99 })
    .padding({
      left: 16,
      right: 16,
      top: 10,
      bottom: 5
    })
  }
}

@Component
struct DormitoryItem {
  @ObjectLink dormitoryItem: DormitoryLocation;
  @Link selectedDormitoryIndex: number;
  @ObjectLink tableSet: LazyDataSource<DormitoryLocation>;
  @State enterDeleteArea: boolean = false;
  mIndex: number = -1;
  private startTrigger: number = 0;

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
    updateDormitoryStarStatus(this.dormitoryItem);
  }

  deleteDormitory() {
    this.selectedDormitoryIndex = -1;
    deleteDormitory(this.dormitoryItem);
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
      this.dormitoryItem.isStar ? $r('app.color.whut_yellow_background_selected') :
      $r('app.color.start_window_background'))
    .onClick(() => {
      this.selectedDormitoryIndex = index;
    })
    .borderRadius(8)
  }

  build() {
    ListItem() {
      this.DormitoryHistorySheetItem(this.dormitoryItem, this.mIndex);
    }
    .transition({ type: TransitionType.Delete, opacity: 0 })
    .swipeAction({
      end: {
        builder: () => this.ListItemSwiper(),
        onAction: () => {
          animateTo({
            duration: 500,
            onFinish: () => {
              this.tableSet.reloadData();
            }
          }, () => {
            this.deleteDormitory()
          })
        },
        actionAreaDistance: 75,
        onEnterActionArea: () => {
          this.enterDeleteArea = true;
        },
        onExitActionArea: () => {
          this.enterDeleteArea = false;
        }
      }
    })
  }
}
