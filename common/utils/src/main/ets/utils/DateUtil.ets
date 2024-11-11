import { CalendarData, Day, DayInfo } from "../model/CalendarModel";
import { i18n } from "@kit.LocalizationKit";
import { JSON } from "@kit.ArkTS";

export class  DateUtil extends Date {

  public static readonly WEEKS: string[] = ["日", "一", "二", "三", "四", "五", "六"];

  public getWeeksBetweenDates(startDate: string, endDate: string): number {
    const start = new Date(startDate);
    const end = new Date(endDate);
    const timeDifference = end.getTime() - start.getTime();
    const oneWeekInMs = 7 * 24 * 60 * 60 * 1000;
    const weeks = Math.ceil(timeDifference / oneWeekInMs)
    if (weeks === 0) {
      return weeks + 1;
    } else {
      return weeks;
    }
  }

  public getToday() {
    return this.getFullYear().toString() + '/' + (this.getMonth() + 1).toString() + '/' + this.getDate().toString();
  }

  static getWeekDay(year: number, month: number, day: number): number {
    const DATE = new Date(year, month - 1, day);
    return DATE.getDay();
  }

  static getWeekDays(weekNum: number): Day[][] {
    const onDayInMs = 86400000;
    // 获取当前日期
    const CURRENT_DATE = new Date();
    // 获取当前日期是本周的周几（0-6，其中0代表周日，1代表周一，以此类推）
    let WEEK_DAY = CURRENT_DATE.getDay();
    if (WEEK_DAY === 0) {
      WEEK_DAY = 7;  // 将周日视为一周的第七天
    }
    // 计算并设置目标周的第一天(周一)的日期
    const BEGIN_DATE = new Date(CURRENT_DATE.getTime() - (WEEK_DAY - 1) * onDayInMs +
      (7 * weekNum) * onDayInMs);
    let days: CalendarData[] = [];
    let week: Day[] = [];
    const CALENDAR: Day[][] = [];
    let i18nCalendar: i18n.Calendar = i18n.getCalendar("zh-Hans", "chinese");
    for (let i = 0; i < 7; i++) {
      const DAY = new Date(BEGIN_DATE.getTime() + i * onDayInMs);
      days[i] = {
        year: DAY.getFullYear(),
        month: DAY.getMonth() + 1,
        date: DAY.getDate()
      };
      // 设置日历对象内部的时间日期
      i18nCalendar.setTime(new Date(days[i].year, days[i].month - 1, days[i].date))
      week.push({
        dayNum: days[i].date,
        dayInfo: new DayInfo(days[i].year, days[i].month, days[i].date, 0)
      })
    }
    CALENDAR.push(week);
    return CALENDAR;
  }

  static getLastSunday(date: Date): Date {
    // 获取当前日期是本周的周几（0-6，其中0代表周日，1代表周一，以此类推）
    const DAY_OF_WEEK = date.getDay();
    // 创建一个新的Date对象，其值与传入的date相同，用于后续计算而不改变原始date对象
    const LAST_SUNDAY = new Date(date);
    // 这里假设周日是一周的第一天，因此直接减去dayOfWeek就能得到本周的周日
    LAST_SUNDAY.setDate(LAST_SUNDAY.getDate() - DAY_OF_WEEK);
    // 返回计算后的日期，即本周的周日
    return LAST_SUNDAY;
  }

  static weeksBetweenDates(selectDay: Date): number {
    const TODAY = new Date();
    const oneWeekInMs = 7 * 24 * 60 * 60 * 1000;
    // 周视图中选中日期所属周的第一天（周日）
    let selectLastSunday: Date = DateUtil.getLastSunday(selectDay);
    // 周视图中今天所属周的第一天（周日）
    let todayLastSunday: Date = DateUtil.getLastSunday(TODAY);
    // 计算两个日期之间的毫秒差
    const DIFF = todayLastSunday.getTime() - selectLastSunday.getTime();
    // 将毫秒差转换为天数
    const DIFF_DAYS = DIFF / oneWeekInMs;
    // 将天数差转换为周数，向下取整得到完整的周数
    const DIFF_WEEKS = Math.floor(DIFF_DAYS / 7);
    return -DIFF_WEEKS;
  }

  static getWeeksBetweenDates(startDate:string, endDate: string): number {
    const endDay = new Date(endDate);
    const oneDayInMs = 86400000;
    // 周视图中选中日期所属周的第一天（周日）
    let startLastSunday: Date = DateUtil.getLastSunday(new Date(startDate));
    console.debug('start', JSON.stringify(startLastSunday))
    // 周视图中今天所属周的第一天（周日）
    let endLastSunday: Date = DateUtil.getLastSunday(endDay);
    console.debug('end', JSON.stringify(endLastSunday))
    // 计算两个日期之间的毫秒差
    const DIFF = endLastSunday.getTime() - startLastSunday.getTime();
    // 将毫秒差转换为天数
    const DIFF_DAYS = DIFF / oneDayInMs;
    // 将天数差转换为周数，向下取整得到完整的周数
    const DIFF_WEEKS = Math.floor(DIFF_DAYS / 7) + 1;
    return DIFF_WEEKS;
  }

}


