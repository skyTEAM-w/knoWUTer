import { WebViewPage } from '@ohos/uicomponents';
import { BreakPointTypeEnum, EventType } from '@ohos/utils';
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
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
  innerScroller?: Scroller
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
      }
      .padding({ left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin'), top: 10 })
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