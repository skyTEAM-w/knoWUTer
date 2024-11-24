import { BreakPointType, BreakPointTypeEnum, LazyDataSource, ServiceShowType, ServiceUrl } from '@ohos/utils';
import { ServiceListClass } from '../model/ServiceListClass';
import { LengthMetrics } from '@kit.ArkUI';

@Component
export struct ServiceList {
  @ObjectLink listList: LazyDataSource<ServiceListClass>;
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  handleClick: (item: ServiceUrl) => void = () => {
  }

  @Builder
  ServiceListItem(item: ServiceListClass) {
    Flex({
      direction: this.currentBreakPoint === BreakPointTypeEnum.LG ? FlexDirection.Column : FlexDirection.Row,
      justifyContent: FlexAlign.SpaceAround,
      alignItems: ItemAlign.Center,
      space: { main: LengthMetrics.vp(5) }
    }) {
      Image($r(item.imageUrl))
        .objectFit(ImageFit.Contain)
        .height('90%')
        .width(this.currentBreakPoint === BreakPointTypeEnum.LG ? '90%' : '10%')
      Column() {
        Text(item.serviceName)
          .fontColor(Color.White)
          .fontWeight(400)
      }
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .width('90%')
      .backgroundColor($r('app.color.service_list_background'))
      .borderRadius(8)
      .padding(5)
    }
    .onClick(() => {
      this.handleClick(item)
    })
    .height(this.currentBreakPoint === BreakPointTypeEnum.LG ? $r('app.float.lg_service_list_height') :
    $r('app.float.normal_service_list_height'))
    .width('100%')
    .clickEffect({ level: ClickEffectLevel.HEAVY })
    .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
    .borderRadius(8)
    .padding(this.currentBreakPoint === BreakPointTypeEnum.LG ? 2 : 0)
  }

  build() {
    List({ space: 5 }) {
      LazyForEach(this.listList, (item: ServiceListClass, index: number) => {
        if (item.inMainPage === ServiceShowType.TRUE) {
          ListItem() {
            this.ServiceListItem(item)
          }
          .padding(this.currentBreakPoint !== BreakPointTypeEnum.SM ? { right: 5 } : 0)
        }
      })
    }
    .scrollBar(BarState.Off)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .lanes(new BreakPointType({ sm: 1, md: 2, lg: 4 }).getValue(this.currentBreakPoint))
    .padding({
      top: 11,
      left: 16,
      right: 16,
      bottom: 11
    })
  }
}