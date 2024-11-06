import { TopNavigationView } from '../../../../../../../../../common/uicomponents/Index';
import { ServiceType } from '../../../../../../../../../common/utils/Index';
import { ServiceListClass } from '../model/ServiceListClass';
import { ServiceModel } from '../model/ServiceModel';
import { ServiceUrl } from '../../../../../../../../../common/utils/src/main/ets/model/ServiceUrl';

@Component
export struct AllServiceList {
  @Consume('serviceStack') serviceStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State serviceModel: ServiceModel = new ServiceModel();

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

  @Builder
  ServiceListItem(item: ServiceListClass) {
    Row({ space: 5 }) {
      Image($r(item.imageUrl))
        .objectFit(ImageFit.Contain)
        .height('90%')
        .width('10%')
        .borderRadius(8)
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
      this.jumpWebView(item)
    })
    .height(44)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(8)
    .padding({ left: 5 })
  }

  @Builder
  NormalSceneHeader() {
    Row() {
      Text('师生服务')
        .fontSize(18)
        .fontWeight(700)
        .fontFamily('HarmonyHeiTi-medium')
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .backgroundColor($r('app.color.start_window_background'))
    .padding({
      top: 5,
      bottom: 5
    })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  OfficeSceneHeader() {
    Row() {
      Text('办公服务')
        .fontSize(18)
        .fontWeight(700)
        .fontFamily('HarmonyHeiTi-medium')
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .backgroundColor($r('app.color.start_window_background'))
    .padding({
      top: 5,
      bottom: 5
    })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  EducationSceneHeader() {
    Row() {
      Text('教学服务')
        .fontSize(18)
        .fontWeight(700)
        .fontFamily('HarmonyHeiTi-medium')
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .backgroundColor($r('app.color.start_window_background'))
    .padding({
      top: 5,
      bottom: 5
    })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  FinanceSceneHeader() {
    Row() {
      Text('财务服务')
        .fontSize(18)
        .fontWeight(700)
        .fontFamily('HarmonyHeiTi-medium')
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .backgroundColor($r('app.color.start_window_background'))
    .padding({
      top: 5,
      bottom: 5
    })
    .justifyContent(FlexAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          title: $r('app.string.all_service'),
          onBackClick: () => {
            this.serviceStack.pop()
          }
        })
        List({ space: 10 }) {
          ListItemGroup({ header: this.NormalSceneHeader() }) {
            LazyForEach(this.serviceModel.listData, (item: ServiceListClass) => {
              ListItem() {
                if (item.serviceType === ServiceType.NORMAL) {
                  this.ServiceListItem(item)
                }
              }
            })
          }

          ListItemGroup({ header: this.OfficeSceneHeader() }) {
            LazyForEach(this.serviceModel.listData, (item: ServiceListClass) => {
              ListItem() {
                if (item.serviceType === ServiceType.OFFICE) {
                  this.ServiceListItem(item)
                }
              }
            })
          }

          ListItemGroup({ header: this.EducationSceneHeader() }) {
            LazyForEach(this.serviceModel.listData, (item: ServiceListClass) => {
              ListItem() {
                if (item.serviceType === ServiceType.EDUCATION) {
                  this.ServiceListItem(item)
                }
              }
            })
          }

          ListItemGroup({ header: this.FinanceSceneHeader() }) {
            LazyForEach(this.serviceModel.listData, (item: ServiceListClass) => {
              ListItem() {
                if (item.serviceType === ServiceType.FINANCE) {
                  this.ServiceListItem(item)
                }
              }
            })
          }

          ListItem() {
            Column()
              .height('20%')
          }
        }
        .scrollBar(BarState.Off)
        .padding({
          top: 11,
          left: 16,
          right: 16,
          bottom: 11
        })
      }
      .padding({ top: AppStorage.get<number>('statusBarHeight') })

    }
    .hideTitleBar(true)
    .onReady((serviceListNavContext: NavDestinationContext) => {
      let param = serviceListNavContext.pathInfo.param as Record<string, object>;
      this.serviceModel = param.ServiceModel as ServiceModel;
    })
  }
}

@Builder
export function AllServiceListBuilder() {
  AllServiceList()
}