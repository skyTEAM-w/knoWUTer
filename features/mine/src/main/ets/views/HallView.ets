import { WebViewPage } from '@ohos/uicomponents';
import { BreakPointTypeEnum } from '@ohos/utils';
import { WorkHall } from '../component/WorkHall';
import { UserModel } from '../model/UserModel';

@Component
export struct Hall {
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageProp('isLogged') isLogged: boolean = false;
  @Consume('hallPathStack') hallPathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Consume('minePathStack') minePathStack: NavPathStack;
  @State userModel: UserModel = UserModel.getInstance()
  innerScroller?: Scroller
  handelClick: (url: string) => void = () => {

  }

  aboutToAppear(): void {
    this.userModel.getWorkHallResourse();
  }

  @Builder
  pageMap(name: string) {
    if (name === 'WebViewPage') {
      WebViewPage();
    }
  }

  build() {
    Navigation(this.hallPathStack) {
      List({ scroller: this.innerScroller }) {
        ListItem() {
          WorkHall({
            numberOfItemReview: this.userModel.numberOfItemReview,
            numberOfItemInProgress: this.userModel.numberOfItemInProgress,
            numberOfItemScore: this.userModel.numberOfItemScore,
            numberOfItemClosing: this.userModel.numberOfItemClosing,
            handelClick: this.handelClick
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