import { ServiceBlockClass } from '../model/ServiceBlockClass';
import { ServiceBannerClass } from '../model/ServiceBannerClass';
import { ServiceListClass } from '../model/ServiceListClass';
import { bufferToString, ServiceUrl } from '@ohos/utils';
import { ServiceModel } from '../model/ServiceModel';
import { NavigationTitleBar } from '@ohos/uicomponents';
import { ServiceBanner } from '../components/ServiceBanner';
import { ServiceBlocks } from '../components/ServiceBlocks';
import { ServiceList } from '../components/ServiceList';


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




