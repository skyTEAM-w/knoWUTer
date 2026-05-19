import { BottomTabsItem } from './BottomTabsItem';
import { SymbolGlyphModifier } from '@kit.ArkUI';

function createNormalSymbol(icon: Resource): SymbolGlyphModifier {
  return new SymbolGlyphModifier(icon)
    .fontColor([$r('sys.color.ohos_id_color_bottom_tab_icon_off'),
      $r('sys.color.ohos_id_color_bottom_tab_icon_auxcolor_off02')]);
}

function createSelectedSymbol(icon: Resource): SymbolGlyphModifier {
  return new SymbolGlyphModifier(icon)
    .fontColor([$r('app.color.whut_blue'), $r('app.color.whut_yellow')]);
}

export const BottomTabsList: Array<BottomTabsItem> = [
  {
    normalSymbol: createNormalSymbol($r('sys.symbol.calendar')),
    selectedSymbol: createSelectedSymbol($r('sys.symbol.calendar_fill')),
    label: $r('app.string.bottom_text_course')
  },
  {
    normalSymbol: createNormalSymbol($r('sys.symbol.ellipsis_circle')),
    selectedSymbol: createSelectedSymbol($r('sys.symbol.ellipsis_circle')),
    label: $r('app.string.bottom_text_service')
  },
  {
    normalSymbol: createNormalSymbol($r('sys.symbol.book')),
    selectedSymbol: createSelectedSymbol($r('sys.symbol.book_open_fill')),
    label: $r('app.string.bottom_text_home')
  },
  {
    normalSymbol: createNormalSymbol($r('sys.symbol.briefcase')),
    selectedSymbol: createSelectedSymbol($r('sys.symbol.briefcase_fill')),
    label: $r('app.string.bottom_text_tools')
  },
  {
    normalSymbol: createNormalSymbol($r('sys.symbol.person')),
    selectedSymbol: createSelectedSymbol($r('sys.symbol.person_2_fill')),
    label: $r('app.string.bottom_text_user')
  }
];
