import { BreakPointTypeEnum, CookieUtil, EventType, LazyDataSource, LoadingStatus } from '@ohos/utils';
import { News, NewsType } from '../model/News';
import { NewsModel } from '../model/NewsModel';
import { JSON } from '@kit.ArkTS';
import { LoadingFailed } from '@ohos/uicomponents';
import { common } from '@kit.AbilityKit';

const TAG = '[CampusNews]'

@Component
export struct CampusNews {
  @Consume('homePathStack') homePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State newsModel: NewsModel = NewsModel.getInstance();
  @State currentIndex: number = 0;
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @StorageLink('zhlgd_cookie') cookie: string = AppStorage.get<string>('zhlgd_cookie') || '';
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
  handleClick: (url: string) => void = () => {
  }

  aboutToAppear(): void {
    this.getNews()
    this.eventHub.on(EventType.REFRESH_NEWS, (): void => this.getNews())
  }

  getNews() {
    this.newsModel.checkZHLGDCookie().then((cookie: string | null) => {
      if (cookie) {
        this.newsModel.getNewsResources(this.cookie).then(() => {
          this.loadingStatus = LoadingStatus.SUCCESS;
        }).catch(() => {
          this.loadingStatus = LoadingStatus.FAILED
        })
      } else {
        this.loadingStatus = LoadingStatus.FAILED
      }
    })
  }

  @Builder
  tabBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontColor(this.currentIndex === index ? $r('app.color.whut_blue') : '#182431')
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .margin({ left: 20, right: 20 })
    }.renderFit(RenderFit.RESIZE_CONTAIN)
  }

  build() {
    Column() {
      Row() {
        Text('校园新闻')
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ?
        { left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin'), top: 10 } :
        { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin'), top: 10 })

      if (this.loadingStatus === LoadingStatus.LOADING) {
        LoadingProgress()
          .height(44)
          .width(44)
          .color($r('app.color.whut_blue'))
      }
      if (this.loadingStatus === LoadingStatus.FAILED) {
        LoadingFailed()
          .height('100%')
      }
      if (this.loadingStatus === LoadingStatus.SUCCESS) {
        Tabs({ barPosition: BarPosition.Start }) {
          TabContent() {
            NewsList({ newsList: this.newsModel.comprehensiveNews, handleClick: this.handleClick })
          }.tabBar(this.tabBuilder(NewsType.COMPREHENSIVE_NEWS, 0)).align(Alignment.Top)

          TabContent() {
            NewsList({ newsList: this.newsModel.schoolAnnouncements, handleClick: this.handleClick })
          }.tabBar(this.tabBuilder(NewsType.SCHOOL_ANNOUNCEMENTS, 1)).align(Alignment.Top)

          TabContent() {
            NewsList({ newsList: this.newsModel.departmentNews, handleClick: this.handleClick })
          }.tabBar(this.tabBuilder(NewsType.DEPARTMENT_NEWS, 2)).align(Alignment.Top)

          TabContent() {
            NewsList({ newsList: this.newsModel.collegeAnnouncements, handleClick: this.handleClick })
          }.tabBar(this.tabBuilder(NewsType.COLLEGE_ANNOUNCEMENTS, 3)).align(Alignment.Top)

          TabContent() {
            NewsList({ newsList: this.newsModel.academicLectures, handleClick: this.handleClick })
          }.tabBar(this.tabBuilder(NewsType.ACADEMIC_LECTURES, 4)).align(Alignment.Top)

          TabContent() {
            NewsList({ newsList: this.newsModel.collegeNews, handleClick: this.handleClick })
          }.tabBar(this.tabBuilder(NewsType.COLLEGE_NEWS, 5)).align(Alignment.Top)
        }
        .barMode(BarMode.Scrollable)
        .fadingEdge(true)
        .barHeight($r('app.float.news_tab_bar_height'))
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }

    }
    .width('100%')
  }
}

@Component
struct NewsList {
  @Consume('homePathStack') homePathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @Prop newsList: LazyDataSource<News>;
  handleClick: (url: string) => void = () => {
  }

  aboutToAppear(): void {
    console.debug(JSON.stringify(this.newsList))
  }

  build() {
    List({ space: 15 }) {
      LazyForEach(this.newsList, (item: News, index: number) => {
        ListItem() {
          Row({ space: 10 }) {
            Text(item.TITLE)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .textAlign(TextAlign.Start)
              .width('82%')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(2)
              .ellipsisMode(EllipsisMode.END)
            Text(item.DATE.split('-').length === 3 ? `${item.DATE.split('-')[1]}-${item.DATE.split('-')[2]}` :
            item.DATE)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.font_secondary'))
          }
          .margin(5)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius($r('app.float.light_border_radius'))
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.95 })
        .onClick(() => {
          this.handleClick(item.HREF)
        })
        .margin(this.currentBreakPoint === BreakPointTypeEnum.LG ?
          { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin') } :
          { left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })
      })
    }
    .alignListItem(ListItemAlign.Start)
    .scrollBar(BarState.Off)
    .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
  }
}