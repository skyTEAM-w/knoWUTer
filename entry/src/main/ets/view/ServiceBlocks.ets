import { ServiceBlockClass } from '../model/ServiceBlockClass';
import { bufferToString } from '../common/utils/BufferUtil';
import { LengthMetrics, router } from '@kit.ArkUI';

@Component
export struct ServiceBlocks {
  @State blockList: ServiceBlockClass[] = [];

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
            router.pushUrl({
              url: 'pages/WebViewPage',
              params: item
            })
          })
        })
      }
      .padding({ top: 11, left: 16, right: 16 })
    }
  }
}