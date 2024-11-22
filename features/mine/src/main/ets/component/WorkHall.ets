import { BreakPointType, BreakPointTypeEnum, CommonUrls, EventType } from '@ohos/utils';
import { UserModel } from '../model/UserModel';
import { User } from '../pages/UserView';
import { common } from '@kit.AbilityKit';

@Component
export struct WorkHall {
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @Consume('hallPathStack') hallPathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Consume('minePathStack') minePathStack: NavPathStack;
  @ObjectLink userModel: UserModel;
  @Prop numberOfItemReview: number = 0
  @Prop numberOfItemInProgress: number = 0
  @Prop numberOfItemScore: number = 0
  @Prop numberOfItemClosing: number = 0
  handelClick: (url: string) => void = () => {
  }

  aboutToAppear(): void {
    this.getNumber()
    const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub
    eventHub.on(EventType.REFRESH_HALL, () => {
      this.getNumber()
    })
  }

  getNumber() {
    this.userModel.getWorkHallResourse()
    this.numberOfItemReview = this.userModel.numberOfItemReview;
    this.numberOfItemInProgress = this.userModel.numberOfItemInProgress;
    this.numberOfItemScore = this.userModel.numberOfItemScore;
    this.numberOfItemClosing = this.userModel.numberOfItemClosing;
  }

  @Builder
  workHallHeader() {
    Row() {
      Text($r('app.string.work_hall'))
        .fontSize($r('sys.float.ohos_id_text_size_headline9'))
        .fontWeight(FontWeight.Bold)
      Blank()
        .layoutWeight(1)
      Text($r('app.string.more_work_service'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.font_secondary'))
        .onClick(() => this.handelClick(CommonUrls.WORK_HALL_URL))
    }
    .width('100%')
  }

  build() {
    List() {
      ListItemGroup({ header: this.workHallHeader })
      ListItem() {
        WorkHallItem({
          numberOfItem: this.numberOfItemReview,
          itemName: '待我审核',
          itemSymbol: $r('sys.symbol.pencil_and_card'),
          itemBackgroundColor: $r('app.color.hall_review_item_bg'),
          handelClick: this.handelClick,
          url: CommonUrls.WORK_HALL_REVIVE_URL
        })
      }
      .margin($r('app.float.work_hall_item_margin'))

      ListItem() {
        WorkHallItem({
          numberOfItem: this.numberOfItemInProgress,
          itemName: '在办事项',
          itemSymbol: $r('sys.symbol.list_number'),
          itemBackgroundColor: $r('app.color.hall_progress_item_bg'),
          handelClick: this.handelClick,
          url: CommonUrls.WORK_HALL_PROGRESS_URL
        })
      }
      .margin($r('app.float.work_hall_item_margin'))

      ListItem() {
        WorkHallItem({
          numberOfItem: this.numberOfItemScore,
          itemName: '待我评价',
          itemSymbol: $r('sys.symbol.star'),
          itemBackgroundColor: $r('app.color.hall_score_item_bg'),
          handelClick: this.handelClick,
          url: CommonUrls.WORK_HALL_SCORE_URL
        })
      }
      .margin($r('app.float.work_hall_item_margin'))

      ListItem() {
        WorkHallItem({
          numberOfItem: this.numberOfItemClosing,
          itemName: '办结事项',
          itemSymbol: $r('sys.symbol.checkmark_circle'),
          itemBackgroundColor: $r('app.color.hall_close_item_bg'),
          handelClick: this.handelClick,
          url: CommonUrls.WORK_HALL_CLOSED_URL
        })
      }.margin($r('app.float.work_hall_item_margin'))

    }
    .lanes(new BreakPointType({ sm: 2, md: 2, lg: 2 }).getValue(this.currentBreakPoint))
  }
}

@Component
struct WorkHallItem {
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageProp('isLogged') isLogged: boolean = false;
  @Consume('hallPathStack') hallPathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Consume('minePathStack') minePathStack: NavPathStack;
  @Prop numberOfItem: number;
  @Prop itemName: ResourceStr | undefined = undefined;
  @Prop itemSymbol: Resource;
  @Prop itemBackgroundColor: ResourceColor = 'rgba(0, 0, 233, 0.5)';
  url?: string;
  handelClick: (url: string) => void = () => {

  }

  build() {
    Row() {
      Column() {
        SymbolGlyph(this.itemSymbol)
          .fontSize(32)
          .fontColor([$r('sys.color.white')])
          .fontWeight(FontWeight.Medium)
        Text(this.itemName)
          .fontSize(18)
          .fontColor($r('sys.color.white'))
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .height('100%')

      Blank()
      Text(this.isLogged ? this.numberOfItem.toString() : '0')
        .fontSize(20)
        .fontColor($r('sys.color.white'))
    }
    .onClick(() => this.handelClick(this.url as string))
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.95 })
    .borderRadius($r('app.float.large_border_radius'))
    .padding($r('app.float.work_hall_item_padding'))
    .backgroundColor(this.itemBackgroundColor)
    .width('100%')
    .height($r('app.float.work_hall_item_height'))
  }
}