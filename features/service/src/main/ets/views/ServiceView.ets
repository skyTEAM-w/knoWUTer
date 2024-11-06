import { ServiceBlockClass } from '../model/ServiceBlockClass';
import { ServiceBannerClass } from '../model/ServiceBannerClass';
import { ServiceListClass } from '../model/ServiceListClass';
import { ServiceUrl } from '@ohos/utils/src/main/ets/model/ServiceUrl';
import { bufferToString } from '@ohos/utils';
import { LengthMetrics } from '@kit.ArkUI';
import { ServiceModel } from '../model/ServiceModel';
import LazyDataSource from '@ohos/utils/src/main/ets/utils/LazyDataSource';
import { ServiceShowType } from '@ohos/utils';
import { NavigationTitleBar } from '@ohos/uicomponents';


@Component
export struct Service {
  @Consume('serviceStack') serviceStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State serviceModel: ServiceModel = new ServiceModel();

  aboutToAppear(): void {
    this.getServiceModelFromJSON();
  }

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

  jumpServiceList() {
    this.serviceStack.pushPathByName('AllServiceList', new Object({
      ServiceModel: this.serviceModel,
      onDestinationBack: () => {
        this.serviceStack.pop();
        return false;
      }
    }
    ))
  }

  getServiceModelFromJSON() {
    getContext(this).resourceManager.getRawFileContent("ServiceBannerData.json").then(value => {
      this.serviceModel.swiperData = JSON.parse(bufferToString(value.buffer)) as ServiceBannerClass[];
    });
    getContext(this).resourceManager.getRawFileContent("ServiceBlockData.json").then(value => {
      let jsonObj = JSON.parse(bufferToString(value.buffer)) as ServiceBlockClass[];
      jsonObj.forEach((item: ServiceBlockClass) => {
        this.serviceModel.blockData.pushData(item)
      })
    });
    getContext(this).resourceManager.getRawFileContent("ServiceListData.json").then(value => {
      let jsonObj = JSON.parse(bufferToString(value.buffer)) as ServiceListClass[];
      jsonObj.forEach((item: ServiceListClass) => {
        this.serviceModel.listData.pushData(item)
      })
    })
  }

  @Builder
  NavigationTitle(title: ResourceStr) {
    Column() {
      Text(title)
        .fontSize($r('app.float.component_title_size'))
        .fontWeight(700)
        .width('100%')
        .padding({ left: 16 })
        .fontFamily('HarmonyHeiTi-Bold')
        .lineHeight(33)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .renderFit(RenderFit.CENTER)
    .backgroundBlurStyle(BlurStyle.Thick)
    .padding({ top: AppStorage.get<number>('statusBarHeight') })
  }

  @Builder
  ServiceBlockHeader() {
    Row() {
      Text('常用服务')
        .fontSize(18)
        .fontWeight(700)
        .fontFamily('HarmonyHeiTi-medium')
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .backgroundColor($r('app.color.start_window_background'))
    .padding({
      left: 16,
      right: 16,
      top: 5,
      bottom: 5
    })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  ServiceListHeader() {
    Row() {
      Text('集成站点')
        .fontSize(18)
        .fontWeight(700)
        .fontFamily('HarmonyHeiTi-medium')
        .textAlign(TextAlign.Start)
      Row() {
        Text('更多')
          .fontSize(12)
          .opacity(0.6)
          .textAlign(TextAlign.Start)
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontWeight(FontWeight.Normal)
          .opacity(0.6)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.jumpServiceList()
      })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .backgroundColor($r('app.color.start_window_background'))
    .padding({
      left: 16,
      right: 16,
      top: 5,
      bottom: 5
    })
  }

  build() {
    Column() {
      Navigation(this.serviceStack) {
        Column() {
          List() {
            ListItem() {
              Column()
                .height($r('app.float.navigation_title_bar_half_height'))
            }

            ListItemGroup() {
              ListItem() {
                ServiceBanner({
                  bannerList: this.serviceModel.swiperData,
                  handleClick: (item: ServiceUrl) => this.jumpWebView(item)
                })
              }

            }

            ListItemGroup({ header: this.ServiceBlockHeader() }) {
              ListItem() {
                ServiceBlocks({
                  blockList: this.serviceModel.blockData,
                  handleClick: (item: ServiceUrl) => this.jumpWebView(item)
                })
              }
            }

            ListItemGroup({ header: this.ServiceListHeader() }) {
              ListItem() {
                ServiceList({
                  listList: this.serviceModel.listData,
                  handleClick: (item: ServiceUrl) => this.jumpWebView(item)
                })
              }
            }

            ListItem() {
              Column()
                .height('15%')
            }

          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.TopStart)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .mode(NavigationMode.Stack)
      .title({
        builder: NavigationTitleBar($r('app.string.text_service')),
        height: $r('app.float.navigation_title_bar_height')
      }, {
        barStyle: BarStyle.STACK
      })
      .hideTitleBar(false)
      .hideBackButton(true)
    }
  }
}

@Component
export struct ServiceBlocks {
  @ObjectLink blockList: LazyDataSource<ServiceBlockClass>;
  handleClick: (item: ServiceUrl) => void = () => {
  }

  build() {
    Column() {
      Flex({
        wrap: FlexWrap.Wrap,
        justifyContent: FlexAlign.SpaceBetween,
        space: { main: LengthMetrics.px(10), cross: LengthMetrics.px(20) }
      }) {
        LazyForEach(this.blockList, (item: ServiceBlockClass, index: number) => {
          Row() {
            Text(item.title)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .fontWeight(500)
              .fontColor((index % 2 === 0) ? $r('app.color.whut_yellow') : $r('app.color.whut_blue'))
          }
          .width('49%')
          .height(88)
          .clickEffect({ level: ClickEffectLevel.HEAVY })
          .backgroundColor((index % 2 === 0) ? $r('app.color.whut_blue') : $r('app.color.whut_yellow'))
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.handleClick(item)
            console.log(item.url);
          })
        })
      }
      .padding({
        top: 11,
        left: 16,
        right: 16,
        bottom: 11
      })
    }
  }
}

@Component
export struct ServiceBanner {
  @Prop bannerList: ServiceBannerClass[];
  handleClick: (item: ServiceUrl) => void = () => {
  }

  build() {
    Swiper() {
      ForEach(this.bannerList, (item: ServiceBannerClass) => {
        Image($r(item.imageSrc))
          .objectFit(ImageFit.Contain)
          .width('100%')
          .borderRadius($r('app.float.border_radius'))
          .padding({
            top: 11,
            left: 16,
            right: 16,
            bottom: 5
          })
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

@Component
export struct ServiceList {
  @ObjectLink listList: LazyDataSource<ServiceListClass>;
  handleClick: (item: ServiceUrl) => void = () => {
  }

  @Builder
  ServiceListItem(item: ServiceListClass) {
    Row({ space: 5 }) {
      Image($r(item.imageUrl))
        .objectFit(ImageFit.Contain)
        .height('90%')
        .width('10%')
      Column() {
        Text(item.serviceName)
          .fontColor(Color.White)
          .fontWeight(400)
      }
      .justifyContent(FlexAlign.Center)
      .height('95%')
      .width('88%')
      .backgroundColor($r('app.color.service_list_background'))
      .borderRadius(8)
    }
    .onClick(() => {
      this.handleClick(item)
    })
    .height(44)
    .width('100%')
    .clickEffect({ level: ClickEffectLevel.HEAVY })
    .backgroundColor($r('app.color.normal_background_grey'))
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(8)
    .padding({ left: 5 })
  }

  build() {
    Column() {
      Column({ space: 5 }) {
        LazyForEach(this.listList, (item: ServiceListClass, index: number) => {
          if (item.inMainPage === ServiceShowType.TRUE) {
            this.ServiceListItem(item)
          }
        })
      }
      .padding({
        top: 11,
        left: 16,
        right: 16,
        bottom: 11
      })
    }
  }
}