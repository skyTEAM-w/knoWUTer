import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { DBUtil, LazyDataSource } from '@ohos/utils';
import { Course } from '../model/Course';
import { CourseSchedule } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';


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
      courseList.forEach((course: Course) => {
        let valuesBucket: ValuesBucket = {
          TableId: Number(schedule.scheduleId),
          ClassId: course.classId,
          CourseName: course.courseName,
          Credit: course.credit.toString(),
          CreditHours: course.creditHours.toString(),
          ExamPlace: course.examPlace,
          ExamDate: course.examDate,
          TeachingProcess: course.teachingProcess.toString(),
          ClassDateAndPlace: course.classDateAndPlace ?  course.classDateAndPlace : null,
          CourseSerialNum: course.courseSerialNum,
          CourseNo: course.courseNo,
          Color: '#FFFFFF'
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
          WeekDay: value.WeekDay,
          StartSession: value.StartSession,
          EndSession: value.EndSession,
          Place: value.Place,
          ScheduleId: value.ScheduleId
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

  public queryCourseAllSchedule(course: Course, schedule: Schedule) {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseScheduleTable);
    predicates.equalTo('ClassId', course.classId)
      .and()
      .equalTo('TableId', schedule.scheduleId)
      .and()
      .orderByAsc('ScheduleId');
    let resultSet = this.dbUtil.queryMyPredicates(predicates,
      ['ScheduleId', 'WeekRanges', 'WeekDay', 'StartSession', 'EndSession', 'Place']);
    if (resultSet) {
      let courseScheduleList: LazyDataSource<CourseSchedule> = new LazyDataSource();
      while (resultSet.goToNextRow()) {
        const scheduleId = resultSet.getString(resultSet.getColumnIndex('ScheduleId'))
        const weekRanges = resultSet.getString(resultSet.getColumnIndex('WeekRanges'));
        const weekDay = resultSet.getString(resultSet.getColumnIndex('WeekDay'));
        const startSession = resultSet.getLong(resultSet.getColumnIndex('StartSession'));
        const endSession = resultSet.getLong(resultSet.getColumnIndex('EndSession'));
        const place = resultSet.getString(resultSet.getColumnIndex('Place'));
        courseScheduleList.pushData(new CourseSchedule(weekRanges, schedule.scheduleId, course.classId, scheduleId,
          weekDay, startSession, endSession, place));
      }
      return courseScheduleList;
    }
    return undefined;
  }

  public deleteSchedule(schedule: Schedule) {
    let courseSchedulePredicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseScheduleTable);
    courseSchedulePredicates.equalTo('TableId', schedule.scheduleId);
    if (this.dbUtil.deleteMyPredicate(courseSchedulePredicates)) {
      let courseInfoPredicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseInfoTable);
      courseInfoPredicates.equalTo('TableId', schedule.scheduleId);
      if (this.dbUtil.deleteMyPredicate(courseInfoPredicates)) {
        let schedulePredicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(ScheduleInfoTable);
        schedulePredicates.equalTo('TableId', schedule.scheduleId);
        if(this.dbUtil.deleteMyPredicate(schedulePredicates)) {
          return true;
        }
      }
    }
    return false;
  }
}