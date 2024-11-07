import { relationalStore, ValuesBucket} from '@kit.ArkData'
import { DBUtil } from '@ohos/utils/src/main/ets/utils/DBUtil';
import { Schedule } from "../model/Schedule";

const ScheduleInfoTable = 'ScheduleTableInformation';

export class ScheduleDatabaseFunc {

  private dbUtil = DBUtil.getInstance();

  public insertScheduleInformation(schedule: Schedule): boolean {
    let valueBucket: ValuesBucket = {
      'TableName': schedule.scheduleName,
      'StartDate': schedule.StartDate
    };
    return this.dbUtil.insertMyValueBucket(valueBucket, ScheduleInfoTable, relationalStore.ConflictResolution.ON_CONFLICT_ROLLBACK);
  }

  public insertCourseInformation() {

  }

  public insertCourseSchedule() {

  }
}