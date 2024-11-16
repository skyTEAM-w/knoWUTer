export interface CourseSchedules {
  weekRanges: string;
  weekRangesStr: string;
  WeekDay: string;
  StartSession: number;
  EndSession: number;
  Place: string;
}

@Observed
export class CourseSchedule implements CourseSchedules {
  weekRanges: string;
  weekRangesStr: string;
  TableId: string;
  ClassId: string;
  CourseName: string;
  ScheduleId: string;
  WeekDay: string;
  StartSession: number;
  EndSession: number;
  Place: string;

  constructor(weekRanges: string, TableId: string, ClassId: string, CourseName: string, ScheduleId: string,
    WeekDay: string,
    StartSession: number, EndSession: number, Place: string, weekRangesStr: string) {
    this.weekRanges = weekRanges;
    this.TableId = TableId;
    this.ClassId = ClassId;
    this.ScheduleId = ScheduleId;
    this.WeekDay = WeekDay;
    this.StartSession = StartSession;
    this.EndSession = EndSession;
    this.Place = Place;
    this.CourseName = CourseName;
    this.weekRangesStr = weekRangesStr;
  }
}

@Sendable
export class CourseScheduleSendable implements CourseSchedules {
  weekRanges: string;
  weekRangesStr: string;
  TableId: string;
  ClassId: string;
  CourseName: string;
  ScheduleId: string;
  WeekDay: string;
  StartSession: number;
  EndSession: number;
  Place: string;

  constructor(weekRanges: string, TableId: string, ClassId: string, CourseName: string, ScheduleId: string,
    WeekDay: string,
    StartSession: number, EndSession: number, Place: string, weekRangesStr: string) {
    this.weekRanges = weekRanges;
    this.TableId = TableId;
    this.ClassId = ClassId;
    this.ScheduleId = ScheduleId;
    this.WeekDay = WeekDay;
    this.StartSession = StartSession;
    this.EndSession = EndSession;
    this.Place = Place;
    this.CourseName = CourseName;
    this.weekRangesStr = weekRangesStr;
  }
}

export const WEEKS: string[] = ["一", "二", "三", "四", "五", "六", "日"];

export const WEEKS_START_SUNDAY: string[] = ["日", "一", "二", "三", "四", "五", "六"];

export const COURSE_SCHEDULE_HEIGHT = 60;

export interface TimeTable {
  session: number;
  StartTime: string;
  EndTime: string;
}

export const TIME_TABLE: Array<TimeTable> = [
  {
    session: 1,
    StartTime: '8:00',
    EndTime: '8:45'
  },
  {
    session: 2,
    StartTime: '8:50',
    EndTime: '9:35'
  },
  {
    session: 3,
    StartTime: '9:55',
    EndTime: '10:40'
  },
  {
    session: 4,
    StartTime: '10:45',
    EndTime: '11:30'
  },
  {
    session: 5,
    StartTime: '11:35',
    EndTime: '12:20'
  },
  {
    session: 6,
    StartTime: '14:00',
    EndTime: '14:45'
  },
  {
    session: 7,
    StartTime: '14:50',
    EndTime: '15:35'
  },
  {
    session: 8,
    StartTime: '15:40',
    EndTime: '16:25'
  },
  {
    session: 9,
    StartTime: '16:45',
    EndTime: '17:30'
  },
  {
    session: 10,
    StartTime: '17:35',
    EndTime: '18:20'
  },
  {
    session: 11,
    StartTime: '19:00',
    EndTime: '19:45'
  },
  {
    session: 12,
    StartTime: '19:50',
    EndTime: '20:35'
  },
  {
    session: 13,
    StartTime: '20:40',
    EndTime: '21:25'
  }
]