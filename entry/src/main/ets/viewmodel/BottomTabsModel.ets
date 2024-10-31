import { BottomTabsItem } from './BottomTabsItem'

export const BottomTabsList: Array<BottomTabsItem> = [
  {
    icon: $r('app.media.ic_public_calendar'),
    iconSelected: $r('app.media.ic_public_calendar_filled'),
    text: $r('app.string.bottom_text_course')
  },
  {
    icon: $r('app.media.ic_public_app'),
    iconSelected: $r('app.media.ic_public_app_filled'),
    text: $r('app.string.bottom_text_service')
  },
  {
    icon: $r('app.media.ic_public_home'),
    iconSelected: $r('app.media.ic_public_home_filled'),
    text: $r('app.string.bottom_text_home')
  },
  {
    icon: $r('app.media.ic_public_folder'),
    iconSelected: $r('app.media.ic_public_folder_filled'),
    text: $r('app.string.bottom_text_tools')
  },
  {
    icon: $r('app.media.ic_public_contacts'),
    iconSelected: $r('app.media.ic_public_contacts_filled'),
    text: $r('app.string.bottom_text_user')
  }
]