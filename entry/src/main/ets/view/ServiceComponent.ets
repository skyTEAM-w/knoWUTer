import { ServiceBanner } from './ServiceBanner'
'

@Component
export struct Service {
  build() {
    Navigation() {
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
            ServiceBanner()
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.TopStart)
      }
    }

  }
}