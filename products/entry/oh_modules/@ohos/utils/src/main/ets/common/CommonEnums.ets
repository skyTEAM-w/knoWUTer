export enum ServiceType {
  EDUCATION = 'education',
  OFFICE = 'office',
  FINANCE = 'finance',
  NORMAL = 'normal',
  NULL = ''
}

export enum ServiceShowType {
  TRUE = 'true',
  FALSE = 'false'
}

export enum SettingTwoStatus {
  ON = 'on',
  OFF = 'off'
}

export enum UserPreferenceType {
  CUSTOM_SERVICE = 'customSettingOfService'
}

export enum LoadingStatus {
  OFF = 'off',
  LOADING = 'loading',
  SUCCESS = 'success',
  FAILED = 'failed'
}

export enum EventType {
  REFRESH_TODAY_COURSE = 'refresh_today_course',
  REFRESH_NEWS = 'refresh_news',
  REFRESH_NEWS_END = 'refresh_news_end',
  UPDATE_COURSE = 'update_course',
  DELETE_COURSE = 'deleted_course',
  CHANGE_TABLE = 'change_schedule_table',
  REFRESH_HALL = 'refresh_hall',
  REFRESH_HALL_END = 'refresh_hall_end',
  NET_ACCOUNT_CHANGE = 'net_account_change'
}

export enum CampusNetStatus {
  AUTH_SUCCESS = '认证成功',
  AUTH_FAILED = '认证失败',
  REQUIRE_CODE = '需要验证码',
  LOGOUT_SUCCESS = '登出成功',
  OTHER = 'other'
}