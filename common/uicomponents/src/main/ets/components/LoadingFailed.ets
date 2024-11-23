import { BreakPointType, BreakPointTypeEnum } from '@ohos/utils';

@Component
export struct LoadingFailed {
  @StorageLink('currentBreakPoint') currentBreakPoint: BreakPointTypeEnum = BreakPointTypeEnum.MD;

  build() {
    Column({ space: 10 }) {
      SymbolGlyph($r('sys.symbol.link_slash'))
        .fontSize(new BreakPointType({ sm: 44, md: 55, lg: 66 }).getValue(this.currentBreakPoint))
        .fontColor([$r('sys.color.font_secondary')])
      Text($r('app.string.loading_failed'))
    }
  }
}