import { Course } from '../model/Course';
import { CourseSchedule, CourseSchedules } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { JSON } from '@kit.ArkTS';

const TAG = '[ScheduleBaseFunc]';

export function classDateAndPlaceToCourseSchedule(course: Course, schedule: Schedule, isList?: boolean) {
  let count = 0;
  let courseScheduleString: string[] = course.classDateAndPlace.split(';') || [course.classDateAndPlace];
  // console.debug(TAG, courseScheduleString);

  let parsedSchedules = courseScheduleString.map(schedule => {
    const regex = /星期([一二三四五六日]) 第(\d+)-(\d+)节(?: ([^\-]*)-([^\-]*)-(.*))?/;
    let weekRangesRegex = /\[(.*?)\]/;
    const weekRange = weekRangesRegex.exec(schedule);
    // console.debug(TAG, 'classDateAndPlaceToCourseSchedule', 'WeekRange', weekRange)
    let weekRanges: string = '';
    weekRanges = getCourseWeekRangeList(weekRange);

    let weekRangesStr = getCourseWeekRange(weekRange)

    const match = regex.exec(schedule.replace(/\[(.*?)\]/, ''));
    if (match) {
      return {
        weekRanges,
        weekRangesStr,
        WeekDay: match[1],
        StartSession: Number(match[2]),
        EndSession: Number(match[3]),
        Place: `${match[4]}-${match[5]}-${match[6]}`
      } as CourseSchedules;
    } else {
      return null;
    }
  });

  // console.debug(TAG, JSON.stringify(parsedSchedules))
  let courseSchedule: CourseSchedule[] = [];
  parsedSchedules.forEach((value: CourseSchedules | null) => {
    if (value) {
      courseSchedule.push(new CourseSchedule(value.weekRanges, schedule.scheduleId, course.classId, course.courseName,
        count.toString(),
        value.WeekDay, value.StartSession, value.EndSession, value.Place, value.weekRangesStr));
      count++;
    }
  })
  // console.debug(TAG, 'classDateAndPlaceToCourseSchedule', JSON.stringify(courseSchedule));
  return courseSchedule;
}

export function getCourseWeekRange(weekRangeResult: RegExpExecArray | null) {
  if (weekRangeResult) {
    // console.debug(TAG, 'getCourseWeekRange', weekRangeResult[1])
    let weekRange = weekRangeResult[1].replaceAll('周', '')
    return weekRange;
  }
  return '';
}

export function getCourseWeekRangeList(weekRangeResult: RegExpExecArray | null) {
  if (weekRangeResult) {
    let weekRange = weekRangeResult[1].replaceAll('周', '')
    // console.debug(TAG, 'getCourseWeekRangeList', weekRange);
    let weekRanges: string[] = weekRange.split(',') || [weekRange]
    // console.debug(TAG, 'getCourseWeekRangeList', weekRanges);
    let result: number[] = []
    weekRanges.forEach((item: string) => {
      if (item.includes('-')) {
        const range = item.split('-');
        for (let i = Number(range[0]); i <= Number(range[1]); i++) {
          result.push(i);
        }
      } else {
        result.push(Number(item))
      }
    })
    return result.join(',');
    // console.debug(TAG, 'getCourseWeekRangeList', result.join(','));
  }
  return '';
}

export function paddingCourseSchedule(courseSchedule: CourseSchedule[]) {
  let startSessions: number[] = [];
  let endSessions: number[] = [];
  const paddingCount: number = 13;
  courseSchedule.forEach((item: CourseSchedule) => {
    startSessions.push(item.StartSession)
    endSessions.push(item.EndSession)
  })
  let result: CourseSchedule[] = [];
  for (let i = 1; i <= paddingCount; i++) {
    if (startSessions.includes(i)) {
      result.push(courseSchedule[startSessions.indexOf(i)])
      i = courseSchedule[startSessions.indexOf(i)].EndSession
    } else {
      result.push(new CourseSchedule('', '', '', '', '', '', -1, -1, '', ''))
    }
  }
  return result;
}

export function courseScheduleToClassDateAndPlace(courseScheduleList: CourseSchedule[]) {
  let resultList: string[] = []
  courseScheduleList.forEach((courseSchedule: CourseSchedule) => {
    const weekRangeStr = courseSchedule.weekRangesStr;
    const classDateWeek = `[${weekRangeToNormalWeek(weekRangeStr)}]`;
    const weekDay = `星期${courseSchedule.WeekDay}`;
    const sessions = `第${courseSchedule.StartSession}-${courseSchedule.EndSession}节`;
    const place = courseSchedule.Place.includes('undefined') ? '' : courseSchedule.Place;
    resultList.push([classDateWeek, weekDay, sessions, place].join(' '))
  })
  return resultList.join(';');
}

export function compressRange(weekRangeList: string) {
  const weekRangeNumbers = weekRangeList.split(',').map(Number).sort((a, b) => (a - b));

  let result: string[] = [];
  let rangeStart: number = weekRangeNumbers[0];
  let rangeEnd: number = weekRangeNumbers[0];

  for (let index = 1; index < weekRangeNumbers.length; index++) {
    if (weekRangeNumbers[index] === rangeEnd + 1) {
      rangeEnd = weekRangeNumbers[index];
    } else {
      result.push(rangeStart === rangeEnd ? `${rangeStart}` : `${rangeStart}-${rangeEnd}`);
      rangeStart = weekRangeNumbers[index];
      rangeEnd = weekRangeNumbers[index];
    }
  }
  result.push(rangeStart === rangeEnd ? `${rangeStart}` : `${rangeStart}-${rangeEnd}`);
  return result.join(',')
}

function weekRangeToNormalWeek(weekRangeStr: string) {
  let weekRangeList = weekRangeStr.split(',') || [weekRangeStr]
  for (let index = 0; index < weekRangeList.length; index++) {
    weekRangeList[index] += '周';
  }
  return weekRangeList.join(',')
}

export class ScheduleBaseFunc {
  public classDateAndPlaceToCourseSchedule(course: Course, schedule: Schedule, isList?: boolean) {
    let count = 0;
    let courseScheduleString: string[] = course.classDateAndPlace.split(';') || [course.classDateAndPlace];
    console.debug(TAG, courseScheduleString);

    let parsedSchedules = courseScheduleString.map(schedule => {
      const regex = /星期([一二三四五六日]) 第(\d+)-(\d+)节(?: ([^\-]*)-([^\-]*)-(.*))?/;
      let weekRangesRegex = /\[(.*?)\]/;
      const weekRange = weekRangesRegex.exec(schedule);
      console.debug(TAG, 'classDateAndPlaceToCourseSchedule', 'WeekRange', weekRange)
      let weekRanges: string = '';
      if (isList) {
        weekRanges = this.getCourseWeekRangeList(weekRange);
      } else {
        weekRanges = this.getCourseWeekRange(weekRange)
      }
      const match = regex.exec(schedule.replace(/\[(.*?)\]/, ''));
      if (match) {
        return {
          weekRanges,
          WeekDay: match[1],
          StartSession: Number(match[2]),
          EndSession: Number(match[3]),
          Place: `${match[4]}-${match[5]}-${match[6]}`
        } as CourseSchedules;
      } else {
        return null;
      }
    });

    console.debug(TAG, JSON.stringify(parsedSchedules))
    let courseSchedule: CourseSchedule[] = [];
    parsedSchedules.forEach((value: CourseSchedules | null) => {
      if (value) {
        courseSchedule.push(new CourseSchedule(value.weekRanges, schedule.scheduleId, course.classId, course.courseName,
          count.toString(),
          value.WeekDay, value.StartSession, value.EndSession, value.Place, value.weekRangesStr));
        count++;
      }
    })
    console.debug(TAG, 'classDateAndPlaceToCourseSchedule', JSON.stringify(courseSchedule));
    return courseSchedule;
  }

  public getCourseWeekRange(weekRangeResult: RegExpExecArray | null) {
    if (weekRangeResult) {
      console.debug(TAG, 'getCourseWeekRange', weekRangeResult[1])
      let weekRange = weekRangeResult[1].replaceAll('周', '')
      return weekRange;
    }
    return '';

  }

  public getCourseWeekRangeList(weekRangeResult: RegExpExecArray | null) {
    if (weekRangeResult) {
      let weekRange = weekRangeResult[1].replace('周', '')
      let weekRanges: string[] = weekRange.split(',') || [weekRange]
      let result: number[] = []
      weekRanges.forEach((item: string) => {
        if (item.includes('-')) {
          const range = item.split('-');
          for (let i = Number(range[0]); i <= Number(range[1]); i++) {
            result.push(i);
          }
        } else {
          result.push(Number(item))
        }
      })
      return result.join(',');
      // console.debug(TAG, 'getCourseWeekRangeList', result.join(','));
    }
    return '';
  }

  public courseScheduleToClassDateAndPlace(courseScheduleList: CourseSchedule[]) {
    let resultList: string[] = []
    courseScheduleList.forEach((courseSchedule: CourseSchedule) => {
      const weekRangeStr = courseSchedule.weekRangesStr;
      const classDateWeek = `[${this.weekRangeToNormalWeek(weekRangeStr)}]`;
      const weekDay = `星期${courseSchedule.WeekDay}`;
      const place = courseSchedule.Place;
      resultList.push([classDateWeek, weekDay, place].join(' '))
    })
    return resultList.join(';');
  }

  public compressRange(weekRangeList: string) {
    const weekRangeNumbers = weekRangeList.split(',').map(Number).sort((a, b) => (a - b));

    let result: string[] = [];
    let rangeStart: number = weekRangeNumbers[0];
    let rangeEnd: number = weekRangeNumbers[0];

    for (let index = 0; index < weekRangeNumbers.length; index++) {
      if (weekRangeNumbers[index] === rangeEnd + 1) {
        rangeEnd = weekRangeNumbers[index];
      } else {
        result.push(rangeStart === rangeEnd ? `${rangeStart}` : `${rangeStart}-${rangeEnd}`);
        rangeStart = weekRangeNumbers[index];
        rangeEnd = weekRangeNumbers[index];
      }
    }
    result.push(rangeStart === rangeEnd ? `${rangeStart}` : `${rangeStart}-${rangeEnd}`);
    return result.join(',')
  }

  private weekRangeToNormalWeek(weekRangeStr: string) {
    let weekRangeList = weekRangeStr.split(',') || [weekRangeStr]
    for (let index = 0; index < weekRangeList.length; index++) {
      weekRangeList[index] += '周';
    }
    return weekRangeList.join(',')
  }
}