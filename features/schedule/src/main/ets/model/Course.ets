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