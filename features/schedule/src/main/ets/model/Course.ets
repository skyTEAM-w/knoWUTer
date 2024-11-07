export class HttpResponseBody {
  datas: Object[] = [];
  code: string = '0';
  msg: string | null = null;
}

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

  constructor(classId: string, courseName: string, credit: string, creditHours: string, examPlace: string,
    examDate: string, teachingProcess: string, classDateAndPlace: string, courseNo: string, courseSerialNum: string) {
    this.classId = classId;
    this.courseName = courseName;
    this.credit = credit;
    this.creditHours = creditHours;
    this.examPlace = examPlace;
    this.examDate = examDate;
    this.teachingProcess = teachingProcess;
    this.classDateAndPlace = classDateAndPlace;
    this.courseNo = courseNo;
    this.courseSerialNum = courseSerialNum;
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