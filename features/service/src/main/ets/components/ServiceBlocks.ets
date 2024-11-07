import { BreakPointType, BreakPointTypeEnum, LazyDataSource, ServiceUrl } from '@ohos/utils';
import { ServiceBlockClass } from '../model/ServiceBlockClass';

@Component
export struct ServiceBlocks {
  @ObjectLink blockList: LazyDataSource<ServiceBlockClass>;
  @StorageLink('currentBreakPoint') currentBreakPoint: string = BreakPointTypeEnum.MD;
  handleClick: (item: ServiceUrl) => void = () => {
  }

  build() {
    Column() {
      List({ space: 5 }) {
        LazyForEach(this.blockList, (item: ServiceBlockClass, index: number) => {
          ListItem() {
            Row() {
              Text(item.title)
                .fontSize(16)
                .textAlign(TextAlign.Center)
                .fontWeight(500)
                .fontColor((index % 2 === 0) ? $r('app.color.whut_yellow') : $r('app.color.whut_blue'))
            }
            .width('100%')
            .height(88)
            .clickEffect({ level: ClickEffectLevel.HEAVY })
            .backgroundColor((index % 2 === 0) ? $r('app.color.whut_blue') : $r('app.color.whut_yellow'))
            .borderRadius(16)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.handleClick(item)
              console.log(item.url);
            })
          }
          .padding(this.currentBreakPoint !== BreakPointTypeEnum.SM ? { right: 5, left: 5 } : { left: 2.5, right: 2.5 })
        })
      }
      .lanes((new BreakPointType({ sm: 2, md: 3, lg: 4 }).getValue(this.currentBreakPoint)))
      .padding({
        top: 11,
        left: 16,
        right: 16,
        bottom: 11
      })
    }
  }
}