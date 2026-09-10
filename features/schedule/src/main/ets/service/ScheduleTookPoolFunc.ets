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

/**
 * 保存课程 + 上课安排。
 *
 * 原实现是 @Concurrent 的，在 taskpool 线程里直接调数据层。
 * 现在必须留在主线程：原生数据层的 store 句柄属于创建它的 ArkTS VM，
 * 而 taskpool 每个 worker 是独立 VM —— 在 worker 里调用只会拿到空结果
 * （原生侧的 g_store 为 null）。DB 访问统一收敛到主线程；
 * 与 DB 无关的 classDateAndPlaceToCourseScheduleTask 仍留在 taskpool。
 */
export async function saveCourseInfomation(course: CourseSendable,
  courseSchedule: CourseScheduleSendable[], deleteSchedule: CourseScheduleSendable[],
  tableId: string, color: string): Promise<void> {
  const db: ScheduleDatabaseFunc = new ScheduleDatabaseFunc();
  await db.deleteCourseSchedule(deleteSchedule);
  await db.updateCourseInfomation(course as Course, tableId, color);
  await db.updateCourseSchedule(courseSchedule, course as Course);
  console.debug('saveCourseInfomation')
  new LocalStorage().setOrCreate('updateCourse', true);
}