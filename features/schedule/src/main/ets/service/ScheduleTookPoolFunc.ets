import { Course, CourseSendable } from '../model/Course';
import { CourseSchedules, CourseScheduleSendable } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { getCourseWeekRange, getCourseWeekRangeList } from './ScheduleBaseFunc';
import { ScheduleDatabaseFunc } from './ScheduleDatabaseFunc';

@Concurrent
export function classDateAndPlaceToCourseScheduleTask(course: Course, schedule?: Schedule, isList?: boolean) {
  let count = 0;
  let courseScheduleString: string[] = course.classDateAndPlace.split(';') || [course.classDateAndPlace];
  console.debug('[SCHEDULE TASK]', courseScheduleString);

  let parsedSchedules = courseScheduleString.map(schedule => {
    const regex = /星期([一二三四五六日]) 第(\d+)-(\d+)节(?: ([^\-]*)-([^\-]*)-(.*))?/;
    let weekRangesRegex = /\[(.*?)\]/;
    const weekRange = weekRangesRegex.exec(schedule);
    // console.debug(TAG, 'classDateAndPlaceToCourseSchedule', 'WeekRange', weekRange)
    let weekRanges: string = '';
    if (isList) {
      weekRanges = getCourseWeekRangeList(weekRange);
    } else {
      weekRanges = getCourseWeekRange(weekRange)
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

  // console.debug(TAG, JSON.stringify(parsedSchedules))
  let courseSchedule: CourseScheduleSendable[] = [];
  parsedSchedules.forEach((value: CourseSchedules | null) => {
    if (value) {
      courseSchedule.push(new CourseScheduleSendable(value.weekRanges, '', course.classId, course.courseName,
        count.toString(),
        value.WeekDay, value.StartSession, value.EndSession, value.Place, value.weekRangesStr));
      count++;
    }
  })
  // console.debug(TAG, 'classDateAndPlaceToCourseSchedule', JSON.stringify(courseSchedule));
  return courseSchedule;
}

@Concurrent
export function saveCourseInfomation(course: CourseSendable, courseSchedule: CourseScheduleSendable[],
  deleteSchedule: CourseScheduleSendable[], tableId: string, color: string) {
  new ScheduleDatabaseFunc().deleteCourseSchedule(deleteSchedule);
  new ScheduleDatabaseFunc().updateCourseInfomation(course as Course, tableId, color);
  new ScheduleDatabaseFunc().updateCourseSchedule(courseSchedule, course as Course);
  console.debug('saveCourseInfomation')
  new LocalStorage().setOrCreate('updateCourse', true);
}