import { webview } from '@kit.ArkWeb';
import { BreakPointType, BreakPointTypeEnum, CookieUtil, DateUtil, LazyDataSource } from '@ohos/utils';
import { ScheduleNavigation } from '../components/ScheduleNavigationTitle';
import { ScheduleNetFunc } from '../service/ScheduleNetFunc';
import { intl } from '@kit.LocalizationKit';
import { Schedule } from '../model/Schedule';
import { Course } from '../model/Course';
import { ScheduleCard } from '../components/ScheduleCard';
import { ScheduleDatabaseFunc } from '../service/ScheduleDatabaseFunc';
import { ClassInformationCard } from '../components/CourseInformationCard';
import { classDateAndPlaceToCourseSchedule, ScheduleBaseFunc } from '../service/ScheduleBaseFunc';
import { JSON } from '@kit.ArkTS';
import { ScheduleSettingFunc } from '../service/ScheduleSettingFunc';
import { ItemRestriction, SegmentButton, SegmentButtonOptions,
  SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';

const TAG = '[ScheduleTable]'

@Component
export struct ScheduleTable {
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  @StorageLink('schedule_cookie') ScheduleCookie: string = AppStorage.get<string>('schedule_cookie') || '';
  @Consume('schedulePathStack') schedulePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('selectScheduleIndex') @Watch('getAllSchedule') selectedScheduleTableIndex: number  = AppStorage.get<number>('selectScheduleIndex') || -1;
  @State isCookieShow: boolean = false;
  @State @Watch('getAllSchedule') isSettingShow: boolean = false;
  @State cookie: string = '';
  @State currentWeek: number = 1;
  @State scheduleTableList: LazyDataSource<Schedule> = new LazyDataSource();
  @State selectedSchedule: Schedule | undefined = undefined;
  @State courseList: LazyDataSource<Course> | undefined = undefined;
  @State loginStatus: boolean | undefined = undefined;
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '周视图' }, { text: '日视图' }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK
  })
  @State tabSelectedIndexes: number[] = [1]

  private webViewController: webview.WebviewController = new webview.WebviewController();
  private scheduleNetFunc = new ScheduleNetFunc();
  private scheduleDBFunc = new ScheduleDatabaseFunc();
  private scheduleBaseFunc = new ScheduleBaseFunc();
  private scheduleSettingFunc = ScheduleSettingFunc.getInstance();
  private mDate = new DateUtil();
  @State selectedDate: Date = new Date(this.mDate.getToday());

  aboutToAppear(): void {
    ScheduleSettingFunc.getInstance().checkSelectScheduleIndex();
    this.scheduleNetFunc.checkJWXTLoginStatus().then((status: boolean) => {
      this.loginStatus = status;
      console.debug('loginStatus', this.loginStatus)
    });
    this.getAllSchedule();
    this.getCourseList();
  }

  aboutToDisappear(): void {
    console.debug(TAG, 'aboutToDisappear', this.selectedScheduleTableIndex)
    this.scheduleSettingFunc.saveSelectScheduleIndex(this.selectedScheduleTableIndex);
  }

  getAllSchedule() {
    this.scheduleTableList.pushArrayData(this.scheduleDBFunc.queryAllScheduleTable() as Schedule[]);
    console.debug(TAG, 'getAllSchedule', JSON.stringify(this.scheduleTableList))
    this.selectedSchedule = this.scheduleTableList.getData(this.selectedScheduleTableIndex);
    this.getCourseList();
  }

  getCourseList() {
    console.debug(TAG, 'getCourseList', this.selectedScheduleTableIndex)
    if (this.selectedScheduleTableIndex !== -1) {
      const schedule = this.scheduleTableList?.getData(this.selectedScheduleTableIndex);
      this.scheduleSettingFunc.saveSelectScheduleIndex(this.selectedScheduleTableIndex);
      console.debug(TAG, 'getCourseList', JSON.stringify(schedule))
      if (schedule) {
        this.courseList = this.scheduleDBFunc.queryAllCourseInformation(schedule)
      }
    }
  }

  jumpManageSchedule() {
    if (this.currentBreakPoint === BreakPointTypeEnum.LG) {
      this.schedulePathStack.pushPathByName('ManageSchedule', new Object(
        {
          onDestinationBack: () => {
            this.schedulePathStack.pop();
          }
        }
      ))
    } else {
      this.appPathStack.pushPathByName('ManageSchedule', new Object(
        {
          onDestinationBack: () => {
            this.appPathStack.pop();
          }
        }
      ))
    }
  }

  @Styles
  marginStyle() {
    .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ? {left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin')} :
      {left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin')})
  }

  @Builder
  cookieBindSheet() {
    Web({
      src: 'https://jwxt.whut.edu.cn/',
      controller: this.webViewController
    })
      .onPageEnd(() => {
        this.cookie =
          webview.WebCookieManager.fetchCookieSync('https://jwxt.whut.edu.cn/jwapp/sys/homeapp/home/index.html');
        CookieUtil.getInstance().saveJWXTCookie(this.cookie);
      })
  }

  @Builder
  settingBindSheet() {
    Column({space: 10}){

      if (this.currentBreakPoint === BreakPointTypeEnum.SM) {
        Column() {
          SegmentButton({
            options: this.tabOptions,
            selectedIndexes: $tabSelectedIndexes
          })
            .margin(this.currentBreakPoint !== BreakPointTypeEnum.SM ?  {left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 5}:
            {left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 5})
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      Column() {
        Row() {
          Text('课程表')
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
          Text('管理')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .fontColor(Color.Blue)
            .padding({right: $r('app.float.xxl_padding_margin') })
            .onClick(() => {
              this.jumpManageSchedule();
              this.isSettingShow = false;
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .marginStyle()
        .width('100%')

        Scroll() {
          Row({space: 5}) {
            LazyForEach(this.scheduleTableList, (item: Schedule, index: number) => {
              ScheduleCard({schedule: item, selectedScheduleIndex: this.selectedScheduleTableIndex, index: index})
            })
            Row()
              .width('90%')
          }
          .marginStyle()
        }
        .width('100%')
        .margin({top: 5})
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)

      Column() {
        Text('周数')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .marginStyle()
          .width('100%')
        Slider({
          value: this.currentWeek,
          min: 1,
          max: 20,
          step: 1,
          style: SliderStyle.InSet
        })
          .showTips(true, this.currentWeek.toString())
          .showSteps(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.currentWeek = value
            console.info('value:' + value + 'mode:' + mode.toString())
          })
          .marginStyle()
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Row() {
        Column() {

        }
      }
      .width("100%")
    }
    .width("100%")
    .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ? {top: AppStorage.get<number>('statusBarHeight')} : {top: 20})
  }

  build() {
    Navigation(this.schedulePathStack) {
      Column() {
        Stack({alignContent: Alignment.Top}) {
          Scroll() {
            Column() {
              Column()
                .height(88)
              if (this.courseList) {
                WaterFlow() {
                  LazyForEach(this.courseList, (item: Course, index: number) => {
                    FlowItem() {
                      ClassInformationCard({ courseInfomation: item })
                    }
                    .padding({ left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })
                  })
                  FlowItem() {

                  }
                  .height('50%')
                }
                .cachedCount(0)
                .columnsTemplate(new BreakPointType({
                  sm: '1fr',
                  md: '1fr 1fr',
                  lg: '1fr 1fr 1fr'
                }).getValue(this.currentBreakPoint))
                .columnsGap($r('app.float.course_card_padding'))
                .rowsGap($r('app.float.course_card_padding'))
                .scrollBar(BarState.Off)
                .height("100%")
                .nestedScroll({scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST})
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                .padding({top: 5})
              }
            }
          }
          .scrollBar(BarState.Off)
          .height('100%')

          ScheduleNavigation({
            selectedDate: this.selectedDate,
            isCookieShow: this.isCookieShow,
            isSettingShow: this.isSettingShow,
            schedule: this.selectedSchedule,
            loginStatus: this.loginStatus,
            tabOptions: this.tabOptions,
            tabSelectedIndexes: this.tabSelectedIndexes
          });
        }


      }
      .alignItems(HorizontalAlign.Center)
    }
    .bindSheet($$this.isSettingShow, this.settingBindSheet(), {
      preferType: this.currentBreakPoint === BreakPointTypeEnum.LG ? SheetType.CENTER : SheetType.BOTTOM,
      detents: [400],
      showClose: false,
      blurStyle: BlurStyle.Thin,
      backgroundColor: Color.Transparent,
      maskColor: Color.Transparent
    })
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)

  }
}