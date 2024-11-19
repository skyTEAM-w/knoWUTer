import { PreferencesUtil } from '@ohos/datastore';

const SELECT_SCHEDULE_INDEX = 'select_schedule_index';

const START_DATE = 'start_date';

const SELECTED_TABLE_ID = 'selected_table_id';

export class ScheduleSettingFunc {
  private static instance: ScheduleSettingFunc;
  private preferenceUtil: PreferencesUtil = PreferencesUtil.getInstance();

  public static getInstance() {
    if (!ScheduleSettingFunc.instance) {
      ScheduleSettingFunc.instance = new ScheduleSettingFunc();
    }
    return ScheduleSettingFunc.instance;
  }

  public saveSelectScheduleIndex(selectIndex: number) {
    this.preferenceUtil.setValue<number>(SELECT_SCHEDULE_INDEX, selectIndex);
    AppStorage.setOrCreate('selectScheduleIndex', selectIndex);
  }

  public saveStartDate(startDate: string) {
    this.preferenceUtil.setValue<string>(START_DATE, startDate);
    AppStorage.setOrCreate('startDate', startDate);
  }

  public saveSelectedTableId(tableId: string) {
    this.preferenceUtil.setValue<string>(SELECTED_TABLE_ID, tableId);
    AppStorage.setOrCreate('selectedTableId', tableId);
  }

  public checkSelectScheduleIndex(): void {
    this.preferenceUtil.getValue<number>(SELECT_SCHEDULE_INDEX).then((config: number | null) => {
      if (config === null) {
        config = -1;
      }
      AppStorage.setOrCreate('selectScheduleIndex', config);
    })
  }

  public checkStartDate(): void {
    this.preferenceUtil.getValue<string>(START_DATE).then((config: string | null) => {
      if (config === null) {
        config = '2024-1-1';
      }
      AppStorage.setOrCreate('startDate', config);
    })
  }

  public checkSelectedTableId(): void {
    this.preferenceUtil.getValue<string>(SELECTED_TABLE_ID).then((config: string | null) => {
      if (config === null) {
        config = '1';
      }
      AppStorage.setOrCreate('selectedTableId', config);
    })
  }

  public saveAllScheduleSetting() {
    this.saveSelectScheduleIndex(AppStorage.get<number>('selectScheduleIndex') !== -1 ?
      AppStorage.get<number>('selectScheduleIndex') as number : -1);
    this.saveStartDate(AppStorage.get<string>('startDate') || '2024-1-1');
    this.saveSelectedTableId(AppStorage.get<string>('selectedTableId') || '1');
  }

  public checkAllScheduleSetting() {
    this.checkSelectScheduleIndex();
    this.checkStartDate();
    this.checkSelectedTableId();
  }
}