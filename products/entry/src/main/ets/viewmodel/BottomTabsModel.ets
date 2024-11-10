import { BottomTabsItem } from './BottomTabsItem'

export const BottomTabsList: Array<BottomTabsItem> = [
  {
    icon: $r('sys.symbol.calendar'),
    iconSelected: $r('sys.symbol.calendar_fill'),
    text: $r('app.string.bottom_text_course')
  },
  {
    icon: $r('sys.symbol.square_grid_2x2'),
    iconSelected: $r('sys.symbol.square_fill_grid_2x2'),
    text: $r('app.string.bottom_text_service')
  },
  {
    icon: $r('sys.symbol.book'),
    iconSelected: $r('sys.symbol.book_open_fill'),
    text: $r('app.string.bottom_text_home')
  },
  {
    icon: $r('sys.symbol.briefcase'),
    iconSelected: $r('sys.symbol.briefcase_fill'),
    text: $r('app.string.bottom_text_tools')
  },
  {
    icon: $r('sys.symbol.person'),
    iconSelected: $r('sys.symbol.person_2_fill'),
    text: $r('app.string.bottom_text_user')
  }
]