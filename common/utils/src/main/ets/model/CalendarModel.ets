/**
 * 一天的信息。包含农历
 */
export interface Day {
  dayNum: number, // 日期
  dayInfo: DayInfo // 一天的年月日信息
}

/**
 * 日期信息。用于选择日期回调
 */
export interface CalendarData {
  year: number, // 年
  month: number, // 月
  date: number // 日
}

/**
 * 一天的信息
 */
@Observed
export class DayInfo {
  year: number; // 年
  month: number; // 月
  date: number; // 日
  week: number; // 月视图周信息。月视图上点击上个月日期进行月份切换时需要用到

  constructor(year: number, month: number, date: number, week: number) {
    this.year = year;
    this.month = month;
    this.date = date;
    this.week = week;
  }
}

/**
 * 自定义日历控制器。用于控制年、月、周视图间切换场景下刷新日期数据。
 */
export class CalendarController {
  // 视图刷新接口
  swiperRefresh = (value: CalendarViewType) => {
  };
  // 视图刷新接口（仅用于在年视图上点击月份切换到月视图时刷新）
  swiperYearToMonthRefresh = (year: number, month: number) => {
  };
}

/**
 * 自定义日历类型：YEAR年视图 MONTH月视图 WEEK周视图
 */
export enum CalendarViewType {
  YEAR, // 年视图
  MONTH, // 月视图
  WEEK, // 周视图
}

//
// export const SystemCalendarSymbolArray: Array<Resource> = [
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01'),
//   $r('sys.symbol.calendar_01')
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01'),
// $r('sys.symbol.calendar_01')
// ]