import { WebViewPage } from '@ohos/uicomponents';
import { BreakPointTypeEnum } from '@ohos/utils';
import { WorkHall } from '../component/WorkHall';
import { UserModel } from '../model/UserModel';
import { common } from '@kit.AbilityKit';
import { MyInformation } from '../component/MyInformation';

@Component
export struct Hall {
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageProp('isLogged') isLogged: boolean = false;
  @Consume('hallPathStack') hallPathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Consume('minePathStack') minePathStack: NavPathStack;
  @State userModel: UserModel = UserModel.getInstance()
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  innerScroller?: Scroller
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;

  handelClickWork: (url: string) => void = () => {

  }
  handelClickInfo: (url: string) => void = () => {

  }

  aboutToAppear(): void {
    this.userModel.getWorkHallResourse();
    this.userModel.getUnbackBook();
    this.userModel.getCardMoney();
  }

  @Builder
  pageMap(name: string) {
    if (name === 'WebViewPage') {
      WebViewPage();
    }
  }

  build() {
    Navigation(this.hallPathStack) {
      List({ scroller: this.innerScroller, space: 10 }) {
        ListItem() {
          WorkHall({
            userModel: this.userModel,
            handelClick: this.handelClickWork,
            numberOfItemReview: this.userModel.numberOfItemReview,
            numberOfItemInProgress: this.userModel.numberOfItemInProgress,
            numberOfItemScore: this.userModel.numberOfItemScore,
            numberOfItemClosing: this.userModel.numberOfItemClosing
          })
        }

        ListItem() {
          MyInformation({
            userModel: this.userModel,
            handelClick: this.handelClickInfo
          })
        }


        ListItem() {

        }
        .height('50%')
      }
      .scrollBar(BarState.Off)
      .padding({ left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin') })
      .edgeEffect(EdgeEffect.None)
      .width('100%')
      .height('100%')
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })

    }
    .navDestination(this.pageMap)
    .height('100%')
    .navBarWidth('40%')
    .hideBackButton(true)
    .hideTitleBar(true)
    .mode(this.currentBreakPoint === BreakPointTypeEnum.LG ? NavigationMode.Split : NavigationMode.Stack)
  }
}