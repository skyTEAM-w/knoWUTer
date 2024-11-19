@Observed
export class Schedule {
  scheduleId: string;
  scheduleName: string;
  StartDate: string;

  constructor(scheduleId: string, scheduleName: string, StartDate: string) {
    this.scheduleId = scheduleId;
    this.scheduleName = scheduleName;
    this.StartDate = StartDate;
  }
}

export interface ScheduleEventData {
  scheduleId: string;
  scheduleName: string;
  StartDate: string;
}
