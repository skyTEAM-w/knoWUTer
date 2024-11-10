export interface CourseSchedules {
  weekRanges: string;
  WeekDay: string;
  StartSession: number;
  EndSession: number;
  Place: string;
}

@Observed
export class CourseSchedule implements CourseSchedules {
  weekRanges: string;
  TableId: string;
  ClassId: string;
  ScheduleId: string;
  WeekDay: string;
  StartSession: number;
  EndSession: number;
  Place: string;

  constructor(weekRanges: string, TableId: string, ClassId: string, ScheduleId: string, WeekDay: string,
    StartSession: number, EndSession: number, Place: string) {
    this.weekRanges = weekRanges;
    this.TableId = TableId;
    this.ClassId = ClassId;
    this.ScheduleId = ScheduleId;
    this.WeekDay = WeekDay;
    this.StartSession = StartSession;
    this.EndSession = EndSession;
    this.Place = Place;
  }
}