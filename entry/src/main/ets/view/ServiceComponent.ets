import { ServiceBlockClass } from '../model/ServiceBlockClass';
import { ServiceBannerClass } from '../model/ServiceBannerClass';
import { ServiceUrl } from '../model/ServiceUrl'
import { bufferToString } from '../common/utils/BufferUtil';
import { LengthMetrics, router } from '@kit.ArkUI';
import { it } from '@ohos/hypium';

@Component
export struct Service {
  @Consume('WebViewStack') webViewStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;

  jumpWebView(item: ServiceUrl): void {
    this.appPathStack.pushPathByName('WebViewPage',
      new Object({
        webUrl: item,
        onDestinationBack: () => {
          this.appPathStack.pop();
          return false;
        }
      }))
  }

  build() {
    Navigation(this.webViewStack) {
      Column() {
        Text($r('app.string.text_service'))
          .fontSize($r('app.float.component_title_size'))
          .fontWeight(700)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 16 })
          .fontFamily('HarmonyHeiTi-Bold')
          .lineHeight(33)

        Scroll() {
          Column() {
            ServiceBanner({ handleClick: (item: ServiceUrl) => this.jumpWebView(item) })
            ServiceBlocks({ handleClick: (item: ServiceUrl) => this.jumpWebView(item) })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.TopStart)
      }
    }
    .mode(NavigationMode.Stack)

  }
}

@Component
export struct ServiceBlocks {
  @State blockList: ServiceBlockClass[] = [];
  handleClick: (item: ServiceUrl) => void = () => {
  }

  aboutToAppear(): void {
    this.getBlockFromJson();
  }

  getBlockFromJson() {
    getContext(this).resourceManager.getRawFileContent('ServiceBlockData.json').then(value => {
      this.blockList = JSON.parse(bufferToString(value.buffer)) as ServiceBlockClass[];
    })
  }

  build() {
    Column() {
      Text('常用服务')
        .fontSize(18)
        .fontWeight(700)
        .fontFamily('HarmonyHeiTi-medium')
        .textAlign(TextAlign.Start)
        .padding({ left: 16, right: 16, top: 11 })
        .width('100%')
      Flex({
        wrap: FlexWrap.Wrap,
        justifyContent: FlexAlign.SpaceBetween,
        space: { main: LengthMetrics.px(10), cross: LengthMetrics.px(20) }
      }) {
        ForEach(this.blockList, (item: ServiceBlockClass) => {
          Row() {
            Text(item.title)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .fontWeight(500)
          }
          .width('49%')
          .height(88)
          .backgroundColor($r('app.color.service_block_background'))
          .backgroundBlurStyle(BlurStyle.Thick)
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.handleClick(item)
            console.log(item.url);
          })
        })
      }
      .padding({ top: 11, left: 16, right: 16 })
    }
  }
}

@Component
export struct ServiceBanner {
  @State bannerList: ServiceBannerClass[] = [];
  handleClick: (item: ServiceUrl) => void = () => {
  }

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
            this.handleClick(item)
            console.log(item.url);
          })
      }, (item: ServiceBannerClass) => item.id)
    }
    .autoPlay(true)
    .loop(true)
    .indicator(
      new DotIndicator()
        .color($r('app.color.swiper_dot_color'))
        .selectedColor($r('app.color.swiper_dot_color_selected')))
  }
}