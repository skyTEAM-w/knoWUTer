import { BreakPointTypeEnum, CommonConstants, CommonUrls } from '@ohos/utils';
import { UserModel } from '../../../../Index';
import { curves } from '@kit.ArkUI';

@Component
export struct MyInformation {
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @Consume('hallPathStack') hallPathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Consume('minePathStack') minePathStack: NavPathStack;
  @Link userModel: UserModel;
  handelClick: (url: string) => void = () => {
  }

  @Builder
  myInformationHeader() {
    Row() {
      Text($r('app.string.my_information'))
        .fontSize($r('sys.float.ohos_id_text_size_headline9'))
        .fontWeight(FontWeight.Bold)
      Blank()
        .layoutWeight(1)
    }
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.scale({ centerY: -vp2px(11), x: 0.5, y: 0.5 })
        .animation({ curve: curves.springMotion(0.4, 0.66) }),
      TransitionEffect.OPACITY.animation({ duration: 0 })
    ))
    .width('100%')
  }

  build() {
    List() {
      ListItemGroup({ header: this.myInformationHeader }) {
        ListItem() {
          MyInformationItem({
            itemName: '图书馆',
            itemText: '在借图书',
            itemSymbol: $r('sys.symbol.book'),
            itemBackgroundColor: $r('app.color.hall_lib_item_bg'),
            url: CommonUrls.USER_LIBRARY,
            handelClick: this.handelClick,
            numberOfItem: this.userModel.numberOfBook,
          })
        }
        .transition(TransitionEffect.asymmetric(
          TransitionEffect.scale({ x: 0.5, y: 0.5 })
            .combine(TransitionEffect.OPACITY)
            .animation({ curve: curves.springMotion(0.35, 0.66), delay: CommonConstants.NORMAL_ANIMATION_DELAY }),
          TransitionEffect.OPACITY.animation({ duration: 0 })
        ))
        .margin($r('app.float.work_hall_item_margin'))

        ListItem() {
          MyInformationItem({
            itemName: '校园卡',
            itemText: '卡余额',
            itemSymbol: $r('sys.symbol.credit_card_repayment'),
            itemBackgroundColor: $r('app.color.hall_card_item_bg'),
            url: CommonUrls.USER_CARD,
            handelClick: this.handelClick,
            numberOfItem: this.userModel.cardMoney
          })
        }
        .transition(TransitionEffect.asymmetric(
          TransitionEffect.scale({ x: 0.5, y: 0.5 })
            .combine(TransitionEffect.OPACITY)
            .animation({ curve: curves.springMotion(0.35, 0.66), delay: CommonConstants.NORMAL_ANIMATION_DELAY * 2 }),
          TransitionEffect.OPACITY.animation({ duration: 0 })
        ))
        .margin($r('app.float.work_hall_item_margin'))

        ListItem() {
          MyInformationItem({
            itemName: 'E-mail',
            itemText: '学校邮箱',
            itemSymbol: $r('sys.symbol.envelope'),
            itemBackgroundColor: $r('app.color.hall_email_item_bg'),
            url: CommonUrls.USER_EMAIL,
            handelClick: this.handelClick
          })
        }
        .transition(TransitionEffect.asymmetric(
          TransitionEffect.scale({ x: 0.5, y: 0.5 })
            .combine(TransitionEffect.OPACITY)
            .animation({ curve: curves.springMotion(0.35, 0.66), delay: CommonConstants.NORMAL_ANIMATION_DELAY * 3 }),
          TransitionEffect.OPACITY.animation({ duration: 0 })
        ))
        .margin($r('app.float.work_hall_item_margin'))

      }
    }
    .clip(false)
  }
}

@Component
struct MyInformationItem {
  @StorageProp('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;
  @StorageProp('isLogged') isLogged: boolean = false;
  @Consume('hallPathStack') hallPathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Consume('minePathStack') minePathStack: NavPathStack;
  @Prop numberOfItem: number | undefined = undefined;
  @Prop itemName: ResourceStr | undefined = undefined;
  @Prop itemText: ResourceStr;
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
      Text(this.itemText)
        .fontSize(16)
        .fontColor($r('sys.color.white'))

      if (this.numberOfItem !== undefined) {
        Text(this.isLogged ? this.numberOfItem.toString() : '0')
          .fontSize(16)
          .fontColor($r('sys.color.white'))
          .margin({ left: 5 })
      }
    }
    .onClick(() => this.handelClick(this.url as string))
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.95 })
    .borderRadius($r('app.float.large_border_radius'))
    .padding({ left: $r('app.float.work_hall_item_padding'), right: $r('app.float.work_hall_item_padding') })
    .backgroundColor(this.itemBackgroundColor)
    .width('100%')
    .height($r('app.float.work_hall_item_height'))
  }
}