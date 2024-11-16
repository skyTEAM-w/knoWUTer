import { PreferencesUtil } from '@ohos/datastore';

const SELECT_SCHEDULE_INDEX = 'select_schedule_index';

const CURRENT_WEEK = 'current_week';

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

  public saveCurrentWeek(currentWeek: number) {
    this.preferenceUtil.setValue<number>(CURRENT_WEEK, currentWeek);
    AppStorage.setOrCreate('currentWeek', currentWeek);
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

  public checkCurrentWeek(): void {
    this.preferenceUtil.getValue<number>(CURRENT_WEEK).then((config: number | null) => {
      if (config === null) {
        config = 1;
      }
      AppStorage.setOrCreate('currentWeek', config);
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
    this.saveCurrentWeek(AppStorage.get<number>('currentWeek') || 1);
    this.saveSelectedTableId(AppStorage.get<string>('selectedTableId') || '1');
  }

  public checkAllScheduleSetting() {
    this.checkSelectScheduleIndex();
    this.checkCurrentWeek();
    this.checkSelectedTableId();
  }
}