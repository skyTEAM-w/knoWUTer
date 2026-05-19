import { BottomTabsItem } from './BottomTabsItem'

export const BottomTabsList: Array<BottomTabsItem> = [
  {
    icon: $r('sys.symbol.calendar'),
    iconSelected: $r('sys.symbol.calendar_fill'),
    text: '仓储'
  },
  {
    icon: $r('sys.symbol.more'),
    iconSelected: $r('sys.symbol.more_fill'),
    text: '健康服务'
  },
  {
    icon: $r('sys.symbol.book'),
    iconSelected: $r('sys.symbol.book_open_fill'),
    text: '今日'
  },
  {
    icon: $r('sys.symbol.briefcase'),
    iconSelected: $r('sys.symbol.briefcase_fill'),
    text: '设备状态'
  },
  {
    icon: $r('sys.symbol.person'),
    iconSelected: $r('sys.symbol.person_2_fill'),
    text: $r('app.string.bottom_text_user')
  }
]