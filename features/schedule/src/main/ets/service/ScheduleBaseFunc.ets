import { Course } from '../model/Course';
import { CourseSchedule, CourseSchedules } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { JSON } from '@kit.ArkTS';

const TAG = '[ScheduleBaseFunc]';

export function classDateAndPlaceToCourseSchedule(course: Course, schedule: Schedule) {
  let count = 0;
  let courseScheduleString: string[] = course.classDateAndPlace.split(';') || [course.classDateAndPlace];
  console.debug(TAG, courseScheduleString);

  let parsedSchedules = courseScheduleString.map(schedule => {
    const regex = /星期([一二三四五六日]) 第(\d+)-(\d+)节(?: ([^\-]*)-([^\-]*)-(.*))?/;
    let weekRangesRegex = /\[(.*?)\]/;
    const weekRange = weekRangesRegex.exec(schedule);
    console.debug(TAG, 'classDateAndPlaceToCourseSchedule', 'WeekRange', weekRange)
    let weekRanges = getCourseWeekRange(weekRange)
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
      courseSchedule.push(new CourseSchedule(value.weekRanges, schedule.scheduleId, course.classId, count.toString(),
        value.WeekDay, value.StartSession, value.EndSession, value.Place));
      count++;
    }
  })
  console.debug(TAG, 'classDateAndPlaceToCourseSchedule', JSON.stringify(courseSchedule));
  return courseSchedule;
}

export function getCourseWeekRange(weekRangeResult: RegExpExecArray | null) {
  if (weekRangeResult) {
    console.debug(TAG, 'getCourseWeekRange', weekRangeResult[1])
    let weekRange = weekRangeResult[1].replaceAll('周', '')
    return weekRange;
  }
  return '';
}

export class ScheduleBaseFunc {
  public classDateAndPlaceToCourseSchedule(course: Course, schedule: Schedule) {
    let count = 0;
    let courseScheduleString: string[] = course.classDateAndPlace.split(';') || [course.classDateAndPlace];
    console.debug(TAG, courseScheduleString);

    let parsedSchedules = courseScheduleString.map(schedule => {
      const regex = /星期([一二三四五六日]) 第(\d+)-(\d+)节(?: ([^\-]*)-([^\-]*)-(.*))?/;
      let weekRangesRegex = /\[(.*?)\]/;
      const weekRange = weekRangesRegex.exec(schedule);
      console.debug(TAG, 'classDateAndPlaceToCourseSchedule', 'WeekRange', weekRange)
      let weekRanges = getCourseWeekRange(weekRange)
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
        courseSchedule.push(new CourseSchedule(value.weekRanges, schedule.scheduleId, course.classId, count.toString(),
          value.WeekDay, value.StartSession, value.EndSession, value.Place));
        count++;
      }
    })
    console.debug(TAG, 'classDateAndPlaceToCourseSchedule', JSON.stringify(courseSchedule));
    return courseSchedule;
  }

  getCourseWeekRange(weekRangeResult: RegExpExecArray | null) {
    if (weekRangeResult) {
      console.debug(TAG, 'getCourseWeekRange', weekRangeResult[1])
      let weekRange = weekRangeResult[1].replaceAll('周', '')
      return weekRange;
    }
    return '';

  }
}