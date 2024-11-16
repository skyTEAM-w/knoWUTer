import { queryTodayScheduleByWeek } from '@feature/schedule';
import { relationalStore } from '@kit.ArkData';

@Concurrent
export async function getTodayCourse(tableId: string, currentWeek: number, weekNumber: number,
  context: Context): Promise<Array<relationalStore.ValuesBucket> | undefined> {
  console.debug('getTodayCourse')
  return await queryTodayScheduleByWeek(tableId, currentWeek, weekNumber, context)
}