import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { LazyDataSource } from '@ohos/utils';
import { DBUtil } from '@ohos/datastore';
import { ColorArray, Course } from '../model/Course';
import { CourseSchedule, WEEKS } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';
import { JSON } from '@kit.ArkTS';


const ScheduleInfoTable = 'ScheduleTableInformation';

const CourseInfoTable = 'CourseInformation';

const CourseScheduleTable = 'CourseSchedule';

const TAG = 'ScheduleDatabaseFunc';

export class ScheduleDatabaseFunc {
  private dbUtil = DBUtil.getInstance();

  public insertScheduleInformation(schedule: Schedule): number {
    let valueBucket: ValuesBucket = {
      'TableName': schedule.scheduleName,
      'StartDate': schedule.StartDate
    };
    return this.dbUtil.insertMyValueBucket(valueBucket, ScheduleInfoTable,
      relationalStore.ConflictResolution.ON_CONFLICT_ROLLBACK);
  }

  public insertCourseInformation(courseList: Course[], schedule: Schedule) {
    if (courseList.length > 0) {
      courseList.forEach((course: Course, index: number) => {
        let valuesBucket: ValuesBucket = {
          TableId: Number(schedule.scheduleId),
          ClassId: course.classId,
          CourseName: course.courseName,
          Credit: course.credit.toString(),
          CreditHours: course.creditHours.toString(),
          ExamPlace: course.examPlace,
          ExamDate: course.examDate,
          TeachingProcess: course.teachingProcess.toString(),
          ClassDateAndPlace: course.classDateAndPlace ? course.classDateAndPlace : null,
          CourseSerialNum: course.courseSerialNum,
          CourseNo: course.courseNo,
          Color: ColorArray[index % 6]
        }
        console.debug(TAG, 'insertCourseInformation', JSON.stringify(valuesBucket))
        this.dbUtil.insertMyValueBucket(valuesBucket, CourseInfoTable,
          relationalStore.ConflictResolution.ON_CONFLICT_ROLLBACK);
      })
      return true;
    }
    return false;
  }

  public insertCourseSchedule(courseScheduleList: CourseSchedule[]) {
    if (courseScheduleList.length > 0) {
      courseScheduleList.forEach((value: CourseSchedule) => {
        let valueBucket: ValuesBucket = {
          TableId: value.TableId,
          ClassId: value.ClassId,
          WeekRanges: value.weekRanges,
          WeekRangesStr: value.weekRangesStr,
          WeekDay: value.WeekDay,
          StartSession: value.StartSession,
          EndSession: value.EndSession,
          Place: value.Place,
          ScheduleId: value.ScheduleId,
          CourseName: value.CourseName
        };
        this.dbUtil.insertMyValueBucket(valueBucket, CourseScheduleTable,
          relationalStore.ConflictResolution.ON_CONFLICT_ROLLBACK);
      })
    }
  }

  public queryAllScheduleTable() {
    let sql: string = 'select * from ' + ScheduleInfoTable + ';';
    let resultSet = this.dbUtil.queryMySql(sql);
    if (resultSet) {
      let scheduleTableList: Array<Schedule> = new Array();
      while (resultSet.goToNextRow()) {
        const scheduleTable = new Schedule(resultSet.getString(resultSet.getColumnIndex('TableId')),
          resultSet.getString(resultSet.getColumnIndex('TableName')),
          resultSet.getString(resultSet.getColumnIndex('StartDate')));
        scheduleTableList.push(scheduleTable);
      }
      return scheduleTableList;
    }
    return undefined;
  }

  public queryScheduleInfomationByScheduleName(schedule: Schedule): false | relationalStore.ResultSet {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(ScheduleInfoTable);
    predicates.equalTo('TableName', schedule.scheduleName);
    return this.dbUtil.queryMyPredicates(predicates);
  }

  public queryScheduleId(schedule: Schedule) {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(ScheduleInfoTable);
    predicates.equalTo('TableName', schedule.scheduleName).and().equalTo('StartDate', schedule.StartDate);
    let resultSet = this.dbUtil.queryMyPredicates(predicates, ['ScheduleId']);
    if (resultSet && resultSet.goToFirstRow()) {
      return resultSet.getString(resultSet.getColumnIndex('ScheduleId'))
    }
    return undefined;
  }

  // public queryCourseId(schedule: Schedule, course: Course) {
  //   let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseInfoTable);
  //   predicates.equalTo('TableId', schedule.scheduleId).and().equalTo('', schedule.StartDate);
  //   let resultSet = this.dbUtil.queryMyPredicates(predicates, ['ScheduleId']);
  //   if (resultSet && resultSet.goToFirstRow()) {
  //     return resultSet.getString(resultSet.getColumnIndex('ScheduleId'))
  //   }
  //   return undefined;
  // }

  public queryAllCourseInformation(schedule: Schedule) {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseInfoTable);
    predicates.equalTo('TableId', schedule.scheduleId);
    let resultSet = this.dbUtil.queryMyPredicates(predicates);
    if (resultSet) {
      let courseInformationList: LazyDataSource<Course> = new LazyDataSource();
      while (resultSet.goToNextRow()) {
        let course: Course = new Course();
        course.classId = resultSet.getString(resultSet.getColumnIndex('ClassId'));
        course.courseName = resultSet.getString(resultSet.getColumnIndex('CourseName'));
        course.credit = resultSet.getString(resultSet.getColumnIndex('Credit'));
        course.creditHours = resultSet.getString(resultSet.getColumnIndex('CreditHours'));
        course.examPlace = resultSet.getString(resultSet.getColumnIndex('ExamPlace'));
        course.examDate = resultSet.getString(resultSet.getColumnIndex('ExamDate'));
        course.teachingProcess = resultSet.getString(resultSet.getColumnIndex('TeachingProcess'));
        course.courseNo = resultSet.getString(resultSet.getColumnIndex('CourseNo'));
        course.courseSerialNum = resultSet.getString(resultSet.getColumnIndex('CourseSerialNum'));
        course.classDateAndPlace = resultSet.getString(resultSet.getColumnIndex('ClassDateAndPlace'));
        courseInformationList.pushData(course);
      }
      return courseInformationList;
    }
    return undefined;
  }

  public queryCourseInformation(tableId: string, courseId: string) {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseInfoTable);
    predicates.equalTo('TableId', tableId).and().equalTo('ClassID', courseId);
    let resultSet = this.dbUtil.queryMyPredicates(predicates);
    if (resultSet) {
      while (resultSet.goToNextRow()) {
        let course: Course = new Course();
        course.classId = resultSet.getString(resultSet.getColumnIndex('ClassId'));
        course.courseName = resultSet.getString(resultSet.getColumnIndex('CourseName'));
        course.credit = resultSet.getString(resultSet.getColumnIndex('Credit'));
        course.creditHours = resultSet.getString(resultSet.getColumnIndex('CreditHours'));
        course.examPlace = resultSet.getString(resultSet.getColumnIndex('ExamPlace'));
        course.examDate = resultSet.getString(resultSet.getColumnIndex('ExamDate'));
        course.teachingProcess = resultSet.getString(resultSet.getColumnIndex('TeachingProcess'));
        course.courseNo = resultSet.getString(resultSet.getColumnIndex('CourseNo'));
        course.courseSerialNum = resultSet.getString(resultSet.getColumnIndex('CourseSerialNum'));
        course.classDateAndPlace = resultSet.getString(resultSet.getColumnIndex('ClassDateAndPlace'));
        console.debug(TAG, 'queryCourseInformation', JSON.stringify(course));
      }
    }
  }

  public queryCourseAllSchedule(course: Course, schedule: Schedule) {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseScheduleTable);
    predicates.equalTo('ClassId', course.classId)
      .and()
      .equalTo('TableId', schedule.scheduleId)
      .and()
      .orderByAsc('ScheduleId');
    let resultSet = this.dbUtil.queryMyPredicates(predicates,
      ['ScheduleId', 'WeekRanges', 'WeekDay', 'StartSession', 'EndSession', 'Place', 'WeekRangesStr']);
    if (resultSet) {
      let courseScheduleList: LazyDataSource<CourseSchedule> = new LazyDataSource();
      while (resultSet.goToNextRow()) {
        const scheduleId = resultSet.getString(resultSet.getColumnIndex('ScheduleId'))
        const weekRanges = resultSet.getString(resultSet.getColumnIndex('WeekRanges'));
        const weekDay = resultSet.getString(resultSet.getColumnIndex('WeekDay'));
        const startSession = resultSet.getLong(resultSet.getColumnIndex('StartSession'));
        const endSession = resultSet.getLong(resultSet.getColumnIndex('EndSession'));
        const place = resultSet.getString(resultSet.getColumnIndex('Place'));
        const weekRangesStr = resultSet.getString(resultSet.getColumnIndex('WeekRangesStr'));
        courseScheduleList.pushData(new CourseSchedule(weekRanges, schedule.scheduleId, course.classId,
          course.courseName, scheduleId,
          weekDay, startSession, endSession, place, weekRangesStr));
      }
      return courseScheduleList;
    }
    return undefined;
  }

  public queryCourseScheduleByWeek(schedule: Schedule, week: number, weekDay: number) {
    let predicates = this.weekPredicatesBuilder(week);
    predicates.and().equalTo('TableId', schedule.scheduleId).and().equalTo('WeekDay', `${WEEKS[weekDay]}`)
    let resultSet = this.dbUtil.queryMyPredicates(predicates);
    if (resultSet) {
      let dayScheduleList: CourseSchedule[] = [];
      while (resultSet.goToNextRow()) {
        const scheduleId = resultSet.getString(resultSet.getColumnIndex('ScheduleId'))
        const weekRanges = resultSet.getString(resultSet.getColumnIndex('WeekRanges'));
        const weekDay = resultSet.getString(resultSet.getColumnIndex('WeekDay'));
        const startSession = resultSet.getLong(resultSet.getColumnIndex('StartSession'));
        const endSession = resultSet.getLong(resultSet.getColumnIndex('EndSession'));
        const place = resultSet.getString(resultSet.getColumnIndex('Place'));
        const courseId = resultSet.getString(resultSet.getColumnIndex('ClassId'));
        const courseName = resultSet.getString(resultSet.getColumnIndex('CourseName'));
        const weekRangesStr = resultSet.getString(resultSet.getColumnIndex('WeekRangesStr'));
        dayScheduleList.push(new CourseSchedule(weekRanges, schedule.scheduleId, courseId, courseName, scheduleId,
          weekDay, startSession, endSession, place, weekRangesStr));
      }
      // console.debug(TAG, 'queryCourseScheduleByWeek', JSON.stringify(dayScheduleList))
      return dayScheduleList;
    }
    return undefined;
  }

  public queryCourseColor(courseSchedule: CourseSchedule) {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseInfoTable);
    predicates.equalTo('ClassId', courseSchedule.ClassId).and().equalTo('TableId', courseSchedule.TableId);
    let resultSet = this.dbUtil.queryMyPredicates(predicates, ['Color']);
    if (resultSet) {
      resultSet.goToFirstRow()
      return resultSet.getString(resultSet.getColumnIndex('Color'));
    }
    return '#800000F0';
  }

  public deleteSchedule(schedule: Schedule) {
    let courseSchedulePredicates: relationalStore.RdbPredicates =
      new relationalStore.RdbPredicates(CourseScheduleTable);
    courseSchedulePredicates.equalTo('TableId', schedule.scheduleId);
    if (this.dbUtil.deleteMyPredicate(courseSchedulePredicates)) {
      let courseInfoPredicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseInfoTable);
      courseInfoPredicates.equalTo('TableId', schedule.scheduleId);
      if (this.dbUtil.deleteMyPredicate(courseInfoPredicates)) {
        let schedulePredicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(ScheduleInfoTable);
        schedulePredicates.equalTo('TableId', schedule.scheduleId);
        if (this.dbUtil.deleteMyPredicate(schedulePredicates)) {
          return true;
        }
      }
    }
    return false;
  }

  weekPredicatesBuilder(week: number) {
    const field: string = 'WeekRanges'
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseScheduleTable);
    predicates.beginWrap()
      .like(field, `${week},%`)
      .or()
      .like(field, `%,${week}`)
      .or()
      .like(field, `%,${week},%`)
      .or()
      .equalTo(field, `${week}`)
      .endWrap()
    return predicates;
  }
}