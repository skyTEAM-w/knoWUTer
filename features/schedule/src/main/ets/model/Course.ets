export class HttpResponseBody {
  datas: Object[] = [];
  code: string = '0';
  msg: string | null = null;
}

@Observed
export class Course {
  classId: string = '';
  courseName: string = '';
  credit: string = '';
  creditHours: string = '';
  examPlace: string = '';
  examDate: string = '';
  teachingProcess: string = '';
  classDateAndPlace: string = '';
  courseNo: string = '';
  courseSerialNum: string = '';
}

@Sendable
export class CourseSendable {
  classId: string = '';
  courseName: string = '';
  credit: string = '';
  creditHours: string = '';
  examPlace: string = '';
  examDate: string = '';
  teachingProcess: string = '';
  classDateAndPlace: string = '';
  courseNo: string = '';
  courseSerialNum: string = '';

  constructor(course: Course) {
    this.classId = course.classId;
    this.courseName = course.courseName;
    this.credit = course.credit;
    this.creditHours = course.creditHours;
    this.examPlace = course.examPlace;
    this.examDate = course.examDate;
    this.teachingProcess = course.teachingProcess;
    this.classDateAndPlace = course.classDateAndPlace;
    this.courseNo = course.courseNo;
    this.courseSerialNum = course.courseSerialNum;
  }
}

export class Term {
  itemCode: string;
  itemName: string;
  selected: string;

  constructor(itemCode: string, itemName: string, selected: string) {
    this.itemCode = itemCode;
    this.itemName = itemName;
    this.selected = selected;
  }
}

export const ColorArray: Array<string> = [
  '#808B3A3A',
  '#80ff8c63',
  '#8000489A',
  '#80EE82EE',
  '#80FFC1C1',
  '#80DC143C'
]