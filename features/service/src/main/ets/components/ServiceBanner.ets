import { BreakPointType, BreakPointTypeEnum, ServiceUrl } from '@ohos/utils';
import { ServiceBannerClass } from '../model/ServiceBannerClass';

@Component
export struct ServiceBanner {
  @Prop bannerList: ServiceBannerClass[];
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  handleClick: (item: ServiceUrl) => void = () => {
  }

  build() {
    Swiper() {
      ForEach(this.bannerList, (item: ServiceBannerClass) => {
        Image($r(item.imageSrc))
          .objectFit(ImageFit.Contain)
          .width('100%')
          .borderRadius($r('app.float.border_radius'))
          .padding({ right: 8, left: 8 })
          .onClick(() => {
            this.handleClick(item)
            console.log(item.url);
          })
      }, (item: ServiceBannerClass) => item.id)
    }
    .displayCount(new BreakPointType({ sm: 1, md: 1, lg: 2 }).getValue(this.currentBreakPoint))
    .autoPlay(true)
    .loop(true)
    .padding({
      top: 11,
      bottom: 5
    })
    .nextMargin(new BreakPointType({
      sm: $r('app.float.sm_swiper_margin'),
      md: $r('app.float.md_swiper_margin'),
      lg: $r('app.float.lg_swiper_margin')
    }).getValue(this.currentBreakPoint))
    .prevMargin(new BreakPointType({
      sm: $r('app.float.sm_swiper_margin'),
      md: $r('app.float.md_swiper_margin'),
      lg: $r('app.float.lg_swiper_margin')
    }).getValue(this.currentBreakPoint))
    .indicator(this.currentBreakPoint !== BreakPointTypeEnum.LG ?
    new DotIndicator()
      .color($r('app.color.swiper_dot_color'))
      .selectedColor($r('app.color.swiper_dot_color_selected')) : false)
  }
}
