import { LazyDataSource } from '@ohos/utils';
import {
  exec,
  query,
  queryOne,
  queryScalar,
  colString,
  colNumber,
  sqlQuote,
  DbRow,
} from '@ohos/datastore';
import { ColorArray, Course } from '../model/Course';
import { CourseSchedule, WEEKS } from '../model/CourseSchedule';
import { Schedule } from '../model/Schedule';

const TAG = '[ScheduleDatabaseFunc]';

// 表名常量：原实现把这些字符串散落在各处，集中于此便于校对
const T_SCHEDULE = 'ScheduleTableInformation';
const T_COURSE = 'CourseInformation';
const T_CS = 'CourseSchedule';
const T_WEEK = 'CourseWeek';

/**
 * 课程表数据访问（原生 NDK RDB 版）。
 *
 * 与原实现的关键差异：
 *
 * 1. 周次改用关联表。原实现把周次存成逗号串，查询靠四个 LIKE 组合
 *    （'1,%' / '%,1' / '%,1,%' / '1'）。这种做法有两个问题：
 *      - 结果依赖字符串格式：写入端一旦出现空格或多余逗号（如 '1, 11'），
 *        '%,11' 就匹配不上，周次会静默丢失；
 *      - 本质是全表扫描 + 字符串匹配，无法走索引。
 *    现在 Week 是 CourseWeek 表里的整数列，周次判断变成等值 EXISTS 子查询，
 *    格式无关、可走索引，且第 1 周与第 11 周在数值上天然区分。
 *
 * 2. WeekDay 存整数。DB 里是 1..7（1=周一），模型对外仍然是中文 '一'..'日'，
 *    转换只在数据层边界发生，UI 代码无需感知。
 *
 * 3. CourseName 不再冗余存在 CourseSchedule 上，统一由 CourseInformation 提供，
 *    读取时 JOIN 回来。改课程名只需改一处。
 *
 * 4. 所有方法改为 async。原实现同步返回 ResultSet，调用方拿着未关闭的游标；
 *    现在游标在原生侧读完即销毁，返回的是普通数组。
 *
 * 5. 幂等写入用"先 UPDATE 再 INSERT"。不能用 INSERT OR REPLACE：
 *    实测该语法在本项目业务库上返回 14800000（RDB_E_ERROR）。
 */

// ---------------------------------------------------------------- 转换helper

/** 中文星期 -> 1..7（1=周一）。已是数字则原样返回；无法识别返回 0 */
export function weekDayToInt(weekDay: string): number {
  const index: number = WEEKS.indexOf(weekDay);
  if (index >= 0) {
    return index + 1;
  }
  const parsed: number = Number(weekDay);
  return Number.isNaN(parsed) ? 0 : parsed;
}

/** 1..7 -> 中文星期；越界返回空串 */
export function weekDayToChinese(day: number): string {
  return day >= 1 && day <= 7 ? WEEKS[day - 1] : '';
}

/** '1,2,11' -> [1,2,11]；忽略空片段与非数字，升序去重 */
export function parseWeekList(weekRanges: string): number[] {
  if (!weekRanges) {
    return [];
  }
  const seen: number[] = [];
  weekRanges.split(',').forEach((piece: string) => {
    const value: number = Number(piece.trim());
    if (!Number.isNaN(value) && value > 0 && seen.indexOf(value) === -1) {
      seen.push(value);
    }
  });
  seen.sort((a: number, b: number) => a - b);
  return seen;
}

/** [1,2,11] -> '1,2,11' */
export function formatWeekList(weeks: number[]): string {
  return weeks.join(',');
}

/**
 * 幂等写入：先 UPDATE，未命中再 INSERT。
 *
 * 为什么不用 INSERT OR REPLACE / INSERT OR IGNORE：
 * 实测这两个带冲突策略关键字的语句在本项目业务库上返回 14800000
 * （RDB_E_ERROR），而同样的语句在探测库上正常 —— 属 HarmonyOS RDB 的
 * 行为差异，不可依赖。两步写法在所有表上均验证通过。
 */
async function upsert(insertSql: string, updateSql: string): Promise<void> {
  const updated: number = await exec(updateSql);
  if (updated > 0) {
    return;
  }
  const inserted: number = await exec(insertSql);
  if (inserted < 0) {
    console.error(TAG, `upsert failed (insert=${inserted}): ${insertSql}`);
  }
}

/** CourseWeek 的键：同一门课的一次上课安排 */
function weekKey(classId: string, scheduleId: string): string {
  return `${classId}|${scheduleId}`;
}

/**
 * 读取某个课表下周次表，按 [ClassId|ScheduleId] 聚合。
 *
 * 单独查一次而不是在每行里做子查询：一次扫描建表，
 * 避免 N+1，也避免依赖 group_concat 的输出顺序。
 */
async function loadWeekMap(tableId: string, classId?: string): Promise<Map<string, number[]>> {
  const map: Map<string, number[]> = new Map();
  const classFilter: string = classId === undefined ? '' : ` AND ClassId=${sqlQuote(classId)}`;
  const rows: DbRow[] = await query(
    `SELECT ClassId, ScheduleId, Week FROM ${T_WEEK} WHERE TableId=${Number(tableId)}${classFilter} ` +
    `ORDER BY Week`);
  rows.forEach((row: DbRow) => {
    const key: string = weekKey(colString(row, 'ClassId'), colString(row, 'ScheduleId'));
    const weeks: number[] | undefined = map.get(key);
    const week: number = colNumber(row, 'Week');
    if (weeks === undefined) {
      map.set(key, [week]);
    } else {
      weeks.push(week);
    }
  });
  return map;
}

/** 把一行 JOIN 结果拼成 CourseSchedule（WeekDay 由整数转回中文） */
function rowToCourseSchedule(row: DbRow, tableId: string,
  weekMap: Map<string, number[]>): CourseSchedule {
  const classId: string = colString(row, 'ClassId');
  const scheduleId: string = colString(row, 'ScheduleId');
  const weeks: number[] | undefined = weekMap.get(weekKey(classId, scheduleId));
  return new CourseSchedule(
    formatWeekList(weeks === undefined ? [] : weeks),
    tableId,
    classId,
    colString(row, 'CourseName'),
    scheduleId,
    weekDayToChinese(colNumber(row, 'WeekDay')),
    colNumber(row, 'StartSession'),
    colNumber(row, 'EndSession'),
    colString(row, 'Place'),
    colString(row, 'WeekRangesStr'));
}

/** CourseSchedule 的公共查询投影：课程名从 CourseInformation JOIN 回来 */
const CS_SELECT: string =
  `SELECT s.ClassId, s.ScheduleId, s.WeekDay, s.StartSession, s.EndSession, s.Place, s.WeekRangesStr, ` +
  `c.CourseName AS CourseName FROM ${T_CS} s ` +
  `LEFT JOIN ${T_COURSE} c ON c.TableId = s.TableId AND c.ClassId = s.ClassId`;

// ---------------------------------------------------------------- 数据访问

export class ScheduleDatabaseFunc {

  /**
   * 新建课表，返回真正的 ScheduleId。
   *
   * 表上有 UNIQUE(TableName, StartDate)，重名时自动加数字后缀而不是让插入失败。
   * 返回 id 的方式是"插入后按这个唯一键查回来"，而不是 last_insert_rowid() ——
   * RDB 的语句可能落在连接池里的不同连接上，last_insert_rowid 不可靠。
   */
  public async insertScheduleInformation(schedule: Schedule): Promise<string> {
    const startDate: string = schedule.StartDate;
    let name: string = schedule.scheduleName;
    for (let attempt = 1; attempt <= 50; attempt++) {
      const existing: number = await queryScalar(
        `SELECT COUNT(*) FROM ${T_SCHEDULE} WHERE TableName=${sqlQuote(name)} ` +
        `AND StartDate=${sqlQuote(startDate)}`);
      if (existing === 0) {
        break;
      }
      name = `${schedule.scheduleName}${attempt}`;
    }
    await exec(`INSERT INTO ${T_SCHEDULE}(TableName, StartDate) ` +
      `VALUES (${sqlQuote(name)}, ${sqlQuote(startDate)})`);
    const row: DbRow | undefined = await queryOne(
      `SELECT ScheduleId FROM ${T_SCHEDULE} WHERE TableName=${sqlQuote(name)} ` +
      `AND StartDate=${sqlQuote(startDate)}`);
    return row === undefined ? '' : String(colNumber(row, 'ScheduleId'));
  }

  /** 批量写入课程。schedule.scheduleId 必须是已存在的课表 id（外键父键） */
  public async insertCourseInformation(courseList: Course[], schedule: Schedule,
    color?: ResourceColor): Promise<boolean> {
    if (courseList.length === 0) {
      return false;
    }
    const tableId: number = Number(schedule.scheduleId);
    for (let index = 0; index < courseList.length; index++) {
      const course: Course = courseList[index];
      const rowColor: string = color !== undefined ? color.toString() : ColorArray[index % 6];
      await upsert(
        `INSERT INTO ${T_COURSE}(TableId, ClassId, CourseName, CourseNo, CourseSerialNum, ` +
        `Credit, CreditHours, ExamPlace, ExamDate, TeachingProcess, ClassDateAndPlace, Color) VALUES (` +
        `${tableId}, ${sqlQuote(course.classId)}, ${sqlQuote(course.courseName)}, ` +
        `${sqlQuote(course.courseNo)}, ${sqlQuote(course.courseSerialNum)}, ` +
        `${sqlQuote(course.credit.toString())}, ${sqlQuote(course.creditHours.toString())}, ` +
        `${sqlQuote(course.examPlace)}, ${sqlQuote(course.examDate)}, ` +
        `${sqlQuote(course.teachingProcess.toString())}, ` +
        `${sqlQuote(course.classDateAndPlace ? course.classDateAndPlace : '')}, ${sqlQuote(rowColor)})`,
        `UPDATE ${T_COURSE} SET CourseName=${sqlQuote(course.courseName)}, ` +
        `CourseNo=${sqlQuote(course.courseNo)}, CourseSerialNum=${sqlQuote(course.courseSerialNum)}, ` +
        `Credit=${sqlQuote(course.credit.toString())}, ` +
        `CreditHours=${sqlQuote(course.creditHours.toString())}, ` +
        `ExamPlace=${sqlQuote(course.examPlace)}, ExamDate=${sqlQuote(course.examDate)}, ` +
        `TeachingProcess=${sqlQuote(course.teachingProcess.toString())}, ` +
        `ClassDateAndPlace=${sqlQuote(course.classDateAndPlace ? course.classDateAndPlace : '')}, ` +
        `Color=${sqlQuote(rowColor)} ` +
        `WHERE TableId=${tableId} AND ClassId=${sqlQuote(course.classId)}`);
    }
    return true;
  }

  /**
   * 批量写入上课安排，同时把周次展开进 CourseWeek。
   *
   * 先写 CourseSchedule 再写 CourseWeek：后者对前者是外键子表，
   * 父行不存在时插入会被拒（这是真实约束，顺序不能反）。
   */
  public async insertCourseSchedule(courseScheduleList: CourseSchedule[]): Promise<void> {
    for (const value of courseScheduleList) {
      await this.writeOneSchedule(value, value.TableId, value.ClassId, value.ScheduleId,
        value.WeekDay, value.weekRanges, value.weekRangesStr, value.Place,
        value.StartSession, value.EndSession);
    }
  }

  /** 读全部课表 */
  public async queryAllScheduleTable(): Promise<Schedule[]> {
    const rows: DbRow[] = await query(
      `SELECT ScheduleId, TableName, StartDate FROM ${T_SCHEDULE} ORDER BY ScheduleId`);
    return rows.map((row: DbRow) => new Schedule(
      String(colNumber(row, 'ScheduleId')), colString(row, 'TableName'), colString(row, 'StartDate')));
  }

  /**
   * 按名称统计同名课表数量（创建课表时用于自动改名）。
   * 原实现返回 ResultSet 让调用方读 rowCount，这里直接返回计数。
   */
  public async countScheduleByName(scheduleName: string): Promise<number> {
    return await queryScalar(
      `SELECT COUNT(*) FROM ${T_SCHEDULE} WHERE TableName=${sqlQuote(scheduleName)}`);
  }

  /** 按名称 + 开学日期取 ScheduleId；无匹配返回 undefined */
  public async queryScheduleId(schedule: Schedule): Promise<string | undefined> {
    const row: DbRow | undefined = await queryOne(
      `SELECT ScheduleId FROM ${T_SCHEDULE} WHERE TableName=${sqlQuote(schedule.scheduleName)} ` +
      `AND StartDate=${sqlQuote(schedule.StartDate)} LIMIT 1`);
    return row === undefined ? undefined : String(colNumber(row, 'ScheduleId'));
  }

  /**
   * 读某课表下的全部课程。
   *
   * 返回已填充数据的 LazyDataSource —— LazyForEach 在数据到达时会自动刷新，
   * 因此异步化不会影响调用方的 UI 写法。
   */
  public async queryAllCourseInformation(schedule: Schedule): Promise<LazyDataSource<Course>> {
    const list: LazyDataSource<Course> = new LazyDataSource();
    list.pushArrayData(await this.queryCourseList(schedule.scheduleId));
    return list;
  }

  /** 读某课表下的全部课程（普通数组） */
  public async queryCourseList(tableId: string): Promise<Course[]> {
    const rows: DbRow[] = await query(
      `SELECT ClassId, CourseName, Credit, CreditHours, ExamPlace, ExamDate, TeachingProcess, ` +
      `CourseNo, CourseSerialNum, ClassDateAndPlace, Color FROM ${T_COURSE} ` +
      `WHERE TableId=${Number(tableId)} ORDER BY ClassId`);
    return rows.map((row: DbRow) => courseFromRow(row));
  }

  /** 读单门课程；无匹配返回 undefined */
  public async queryCourseInformation(tableId: string, courseId: string): Promise<Course | undefined> {
    const row: DbRow | undefined = await queryOne(
      `SELECT ClassId, CourseName, Credit, CreditHours, ExamPlace, ExamDate, TeachingProcess, ` +
      `CourseNo, CourseSerialNum, ClassDateAndPlace, Color FROM ${T_COURSE} ` +
      `WHERE TableId=${Number(tableId)} AND ClassId=${sqlQuote(courseId)} LIMIT 1`);
    return row === undefined ? undefined : courseFromRow(row);
  }

  /** 读某门课的全部上课安排 */
  public async queryCourseAllSchedule(course: Course,
    schedule: Schedule): Promise<LazyDataSource<CourseSchedule>> {
    const tableId: string = schedule.scheduleId;
    const weekMap: Map<string, number[]> = await loadWeekMap(tableId, course.classId);
    const rows: DbRow[] = await query(
      `${CS_SELECT} WHERE s.TableId=${Number(tableId)} AND s.ClassId=${sqlQuote(course.classId)} ` +
      `ORDER BY s.ScheduleId`);
    const list: LazyDataSource<CourseSchedule> = new LazyDataSource();
    rows.forEach((row: DbRow) => list.pushData(rowToCourseSchedule(row, tableId, weekMap)));
    return list;
  }

  /**
   * 读某周某天的全部课程安排。
   *
   * weekDay 沿用原实现的约定：0=周一 .. 6=周日（WEEKS 的下标），
   * 内部转成 DB 里的 1..7。保持调用方语义不变，避免各处 off-by-one。
   */
  public async queryCourseScheduleByWeek(schedule: Schedule, week: number,
    weekDay: number): Promise<CourseSchedule[]> {
    return await this.queryScheduleByWeek(schedule.scheduleId, week, weekDay + 1);
  }

  /**
   * 读某课表某周某天的课程安排（按上课节次升序）。weekDay 是 DB 约定：1=周一 .. 7=周日
   *
   * 这是替换掉四段 LIKE 的地方：Week 是 CourseWeek 里的整数列，
   * 第 1 周与第 11 周在数值上天然区分，且不依赖周次串的书写格式。
   */
  public async queryScheduleByWeek(tableId: string, week: number,
    weekDay: number): Promise<CourseSchedule[]> {
    const weekMap: Map<string, number[]> = await loadWeekMap(tableId);
    const rows: DbRow[] = await query(
      `${CS_SELECT} WHERE s.TableId=${Number(tableId)} AND s.WeekDay=${weekDay} ` +
      `AND EXISTS (SELECT 1 FROM ${T_WEEK} w WHERE w.TableId = s.TableId ` +
      `AND w.ClassId = s.ClassId AND w.ScheduleId = s.ScheduleId AND w.Week = ${week}) ` +
      `ORDER BY s.StartSession`);
    return rows.map((row: DbRow) => rowToCourseSchedule(row, tableId, weekMap));
  }

  /** 读课程颜色；无记录返回默认色 */
  public async queryCourseColor(courseSchedule: CourseSchedule): Promise<string> {
    return await this.queryCourseColorByString(courseSchedule.TableId, courseSchedule.ClassId);
  }

  /** 读课程颜色；无记录返回默认色 */
  public async queryCourseColorByString(tableId: string, courseId: string): Promise<string> {
    const row: DbRow | undefined = await queryOne(
      `SELECT Color FROM ${T_COURSE} WHERE TableId=${Number(tableId)} ` +
      `AND ClassId=${sqlQuote(courseId)} LIMIT 1`);
    const color: string = row === undefined ? '' : colString(row, 'Color');
    return color.length > 0 ? color : '#800000F0';
  }

  /** 更新课程主体信息（改名 / 学分 / 颜色 / 上课日期地点） */
  public async updateCourseInfomation(course: Course, tableId: string, color: string): Promise<void> {
    await exec(`UPDATE ${T_COURSE} SET CourseName=${sqlQuote(course.courseName)}, ` +
      `Credit=${sqlQuote(course.credit)}, Color=${sqlQuote(color)}, ` +
      `ClassDateAndPlace=${sqlQuote(course.classDateAndPlace)} ` +
      `WHERE TableId=${Number(tableId)} AND ClassId=${sqlQuote(course.classId)}`);
  }

  /**
   * 批量保存某门课的上课安排。
   *
   * ScheduleId 按数组下标重排（与界面上的"课程安排 1/2/3"一一对应）。
   * 重排会让旧行的主键变化，所以先把该课在本次范围内的旧安排清掉再整体写入，
   * 避免留下下标错位的孤儿行。
   */
  public async updateCourseSchedule(courseSchedules: CourseSchedule[], course: Course): Promise<void> {
    if (courseSchedules.length === 0) {
      return;
    }
    const tableId: string = courseSchedules[0].TableId;
    await exec(`DELETE FROM ${T_CS} WHERE TableId=${Number(tableId)} ` +
      `AND ClassId=${sqlQuote(course.classId)}`);
    for (let index = 0; index < courseSchedules.length; index++) {
      const value: CourseSchedule = courseSchedules[index];
      await this.writeOneSchedule(value, tableId, course.classId, index.toString(),
        value.WeekDay, value.weekRanges, value.weekRangesStr, value.Place,
        value.StartSession, value.EndSession);
    }
  }

  /** 只改某次安排的上课周次 */
  public async updateOneCourseSchedule(courseSchedule: CourseSchedule): Promise<void> {
    await this.writeOneSchedule(courseSchedule, courseSchedule.TableId, courseSchedule.ClassId,
      courseSchedule.ScheduleId, courseSchedule.WeekDay, courseSchedule.weekRanges,
      courseSchedule.weekRangesStr, courseSchedule.Place, courseSchedule.StartSession,
      courseSchedule.EndSession);
  }

  /**
   * 删除整张课表。
   * 按"子表 -> 父表"顺序删，不依赖 ON DELETE CASCADE：
   * 级联依赖 PRAGMA foreign_keys 生效，而显式删除在任何配置下都对。
   */
  public async deleteSchedule(schedule: Schedule): Promise<boolean> {
    const tableId: number = Number(schedule.scheduleId);
    await exec(`DELETE FROM ${T_WEEK} WHERE TableId=${tableId}`);
    await exec(`DELETE FROM ${T_CS} WHERE TableId=${tableId}`);
    await exec(`DELETE FROM ${T_COURSE} WHERE TableId=${tableId}`);
    await exec(`DELETE FROM ${T_SCHEDULE} WHERE ScheduleId=${tableId}`);
    return true;
  }

  /** 删除某门课及其全部上课安排 */
  public async deleteCourse(tableId: string, courseId: string): Promise<void> {
    await exec(`DELETE FROM ${T_WEEK} WHERE TableId=${Number(tableId)} ` +
      `AND ClassId=${sqlQuote(courseId)}`);
    await exec(`DELETE FROM ${T_CS} WHERE TableId=${Number(tableId)} ` +
      `AND ClassId=${sqlQuote(courseId)}`);
    await exec(`DELETE FROM ${T_COURSE} WHERE TableId=${Number(tableId)} ` +
      `AND ClassId=${sqlQuote(courseId)}`);
  }

  /** 删除若干次上课安排（连同其周次） */
  public async deleteCourseSchedule(courseSchedules: CourseSchedule[]): Promise<void> {
    for (const value of courseSchedules) {
      await exec(`DELETE FROM ${T_WEEK} WHERE TableId=${Number(value.TableId)} ` +
        `AND ClassId=${sqlQuote(value.ClassId)} AND ScheduleId=${sqlQuote(value.ScheduleId)}`);
      await exec(`DELETE FROM ${T_CS} WHERE TableId=${Number(value.TableId)} ` +
        `AND ClassId=${sqlQuote(value.ClassId)} AND ScheduleId=${sqlQuote(value.ScheduleId)}`);
    }
  }

  /**
   * 写入一次上课安排 + 它的周次集合。
   *
   * WeekDay 在这里从中文转成整数；周次从逗号串展开成 CourseWeek 行，
   * 整组先删后插，保证重复保存不会残留旧周次（例如从"1-16周"改成"1-8周"）。
   */
  private async writeOneSchedule(value: CourseSchedule, tableIdText: string, classId: string,
    scheduleId: string, weekDay: string, weekRanges: string, weekRangesStr: string, place: string,
    startSession: number, endSession: number): Promise<void> {
    const tableId: number = Number(tableIdText);
    const dayInt: number = weekDayToInt(weekDay);
    await upsert(
      `INSERT INTO ${T_CS}(TableId, ClassId, ScheduleId, WeekDay, StartSession, EndSession, ` +
      `Place, WeekRangesStr) VALUES (${tableId}, ${sqlQuote(classId)}, ${sqlQuote(scheduleId)}, ` +
      `${dayInt}, ${startSession}, ${endSession}, ${sqlQuote(place)}, ${sqlQuote(weekRangesStr)})`,
      `UPDATE ${T_CS} SET WeekDay=${dayInt}, StartSession=${startSession}, ` +
      `EndSession=${endSession}, Place=${sqlQuote(place)}, WeekRangesStr=${sqlQuote(weekRangesStr)} ` +
      `WHERE TableId=${tableId} AND ClassId=${sqlQuote(classId)} ` +
      `AND ScheduleId=${sqlQuote(scheduleId)}`);

    await exec(`DELETE FROM ${T_WEEK} WHERE TableId=${tableId} AND ClassId=${sqlQuote(classId)} ` +
      `AND ScheduleId=${sqlQuote(scheduleId)}`);
    for (const week of parseWeekList(weekRanges)) {
      await exec(`INSERT INTO ${T_WEEK}(TableId, ClassId, ScheduleId, Week) VALUES (` +
        `${tableId}, ${sqlQuote(classId)}, ${sqlQuote(scheduleId)}, ${week})`);
    }
  }
}

/** 由查询行构造 Course（CourseInformation 的列集合） */
function courseFromRow(row: DbRow): Course {
  const course: Course = new Course();
  course.classId = colString(row, 'ClassId');
  course.courseName = colString(row, 'CourseName');
  course.credit = colString(row, 'Credit');
  course.creditHours = colString(row, 'CreditHours');
  course.examPlace = colString(row, 'ExamPlace');
  course.examDate = colString(row, 'ExamDate');
  course.teachingProcess = colString(row, 'TeachingProcess');
  course.courseNo = colString(row, 'CourseNo');
  course.courseSerialNum = colString(row, 'CourseSerialNum');
  course.classDateAndPlace = colString(row, 'ClassDateAndPlace');
  return course;
}

/**
 * 读某课表某周某天的课程安排（供首页/小组件调用）。
 *
 * 原实现是 @Concurrent 的，在 taskpool 线程里自己 getRdbStore 再查。
 * 现在改为普通 async：原生数据层的 store 句柄属于创建它的 ArkTS VM，
 * taskpool 每个 worker 是独立 VM，在那里拿不到主线程的句柄，
 * 强行跨线程访问只会得到一个空结果。DB 访问统一收敛到主线程。
 */
export async function queryTodayScheduleByWeek(tableId: string, week: number,
  weekDay: number): Promise<CourseSchedule[]> {
  return await new ScheduleDatabaseFunc().queryScheduleByWeek(tableId, week, weekDay + 1);
}
