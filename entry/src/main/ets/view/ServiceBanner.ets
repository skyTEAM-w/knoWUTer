import { ServiceBannerClass } from '../model/ServiceBannerClass';
import { bufferToString } from '../common/utils/BufferUtil';
import { router } from '@kit.ArkUI';
import { ServiceUrl } from '../model/ServiceUrl';

@Component
export struct ServiceBanner {
  @State bannerList: ServiceBannerClass[] = [];

  aboutToAppear(): void {
    this.getBannerDataFromJSON();
  }

  getBannerDataFromJSON() {
    getContext(this).resourceManager.getRawFileContent('ServiceBannerData.json').then(value => {
      this.bannerList = JSON.parse(bufferToString(value.buffer)) as ServiceBannerClass[];
    })
    console.log(this.bannerList.toString())
  }

  build() {
    Swiper() {
      ForEach(this.bannerList, (item: ServiceBannerClass) => {
        Image($r(item.imageSrc))
          .objectFit(ImageFit.Contain)
          .width('100%')
          .borderRadius($r('app.float.border_radius'))
          .padding({ top: 11, left: 16, right: 16 })
          .onClick(() => {
            let serviceSelected: ServiceUrl = item;
            router.pushUrl({
              url: 'pages/WebViewPage',
              params: serviceSelected
            });
            console.log(item.url);
          })
      }, (item: ServiceBannerClass) => item.id)
    }
    .autoPlay(true)
    .loop(true)
    .indicator(
      new DotIndicator()
        .color('#4b1644d0')
        .selectedColor('#fffac640'))
  }
}