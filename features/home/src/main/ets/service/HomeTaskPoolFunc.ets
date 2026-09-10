import { CourseSchedule, queryTodayScheduleByWeek } from '@feature/schedule';

/**
 * 读取今天（某周某天）的课程安排。
 *
 * 原实现是 @Concurrent 的：在 taskpool worker 里自己 getRdbStore 再查。
 * 改为普通 async —— 原生数据层的 store 句柄属于创建它的 ArkTS VM，
 * taskpool worker 是独立 VM，拿不到主线程的句柄（原生侧 g_store 为 null），
 * 在 worker 里查只会得到空结果。DB 访问统一收敛到主线程。
 *
 * weekNumber 沿用原约定：0=周一 .. 6=周日。
 */
export async function getTodayCourse(tableId: string, currentWeek: number,
  weekNumber: number): Promise<CourseSchedule[]> {
  console.debug('getTodayCourse')
  return await queryTodayScheduleByWeek(tableId, currentWeek, weekNumber)
}