import { PreferencesUtil } from "@ohos/datastore";

const SELECT_SCHEDULE_INDEX = 'select_schedule_index'

export class ScheduleSettingFunc {
  private preferenceUtil: PreferencesUtil = PreferencesUtil.getInstance();
  private static  instance: ScheduleSettingFunc;

  public static getInstance() {
    if (!ScheduleSettingFunc.instance) {
      ScheduleSettingFunc.instance = new ScheduleSettingFunc();
    }
    return ScheduleSettingFunc.instance;
  }

  public saveSelectScheduleIndex(selectIndex: number){
    this.preferenceUtil.setValue<number>(SELECT_SCHEDULE_INDEX, selectIndex);
    AppStorage.setOrCreate('selectScheduleIndex', selectIndex);
  }

  public checkSelectScheduleIndex(): void {
    this.preferenceUtil.getValue<number>(SELECT_SCHEDULE_INDEX).then((config: number | null) => {
      if (config === null) {
        config = -1;
      }
      AppStorage.setOrCreate('selectScheduleIndex', config);
    })
  }

  public checkAllScheduleSetting() {
    this.checkSelectScheduleIndex();
  }
}