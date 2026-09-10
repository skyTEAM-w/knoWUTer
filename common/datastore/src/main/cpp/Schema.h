/*
 * 数据层 schema 单一来源。
 *
 * 设计要点（对应原 DBUtil.ets 的问题修正）：
 *
 * 1. 复合外键：CourseSchedule/CourseWeek/Exams 引用 CourseInformation 时，
 *    必须用 (TableId, ClassId) 复合外键。原代码只写 ClassId，
 *    而 ClassId 在 CourseInformation 里只是 UNIQUE(TableId, ClassId) 的一部分，
 *    SQLite 要求父键必须是主键或整体 UNIQUE —— 单列引用会让建表直接失败。
 *
 * 2. 周次改关联表：原 WeekRanges 存逗号串，查询靠 4 个 LIKE
 *    （'1,%' / '%,1' / '%,1,%' / '1'），查第 1 周会误命中 "11"、"21"。
 *    改为 CourseWeek(TableId, ClassId, ScheduleId, Week)，Week 可走索引，
 *    周次判断变成等值查询，彻底消除假阳性。
 *
 * 3. 主键修正：原 Meters 把 RoomId 设为主键，语义错误。改为 MeterId 主键，
 *    RoomId 加 UNIQUE 约束（一间房一个表）。
 *
 * 4. 外键真正生效：SQLite 默认不开外键，需每次连接执行
 *    PRAGMA foreign_keys = ON（见 Schema_ApplyPragmas）。
 *
 * 5. 索引：为最热的过滤列建索引（原表全无索引）。
 *
 * 6. 类型标注：SQLite 无长度语义，VARCHAR(255) 等同 TEXT。此处按存储
 *    语义如实标注 INTEGER / TEXT，不再用误导性的 (255)。
 */
#ifndef WHUTHELPER_SCHEMA_H
#define WHUTHELPER_SCHEMA_H

#include <database/rdb/relational_store.h>

namespace whutdb {

/** 业务库文件名（与旧 ApplicationDB.db 保持一致，便于后续数据迁移） */
constexpr const char *BUSINESS_DB_NAME = "ApplicationDB.db";

/** schema 版本。任何结构变更都必须递增，并在 Schema_Migrate 里补迁移分支。 */
constexpr int SCHEMA_VERSION = 1;

/**
 * 每个新连接都必须执行的 PRAGMA。
 * foreign_keys 默认关闭，不显式打开则所有 FOREIGN KEY 声明形同虚设。
 */
constexpr const char *PRAGMA_SQL[] = {
    "PRAGMA foreign_keys = ON",
};

/**
 * CourseSchedule 建表语句。
 * 单独抽成常量：旧数据搬运时需要"用完全相同的 DDL 重建该表"，
 * 复用同一份定义可避免两处 DDL 漂移。
 */
constexpr const char *COURSE_SCHEDULE_DDL =
    "CREATE TABLE IF NOT EXISTS CourseSchedule ("
    "  TableId INTEGER NOT NULL,"
    "  ClassId TEXT NOT NULL,"
    "  ScheduleId TEXT NOT NULL,"           // 该课程的第几次安排，业务侧编号
    "  WeekDay INTEGER NOT NULL,"            // 1=周一 .. 7=周日，存整数而非中文
    "  StartSession INTEGER NOT NULL,"
    "  EndSession INTEGER NOT NULL,"
    "  Place TEXT,"
    "  WeekRangesStr TEXT,"                   // 仅供界面展示，不参与查询
    "  PRIMARY KEY (TableId, ClassId, ScheduleId),"
    "  FOREIGN KEY (TableId, ClassId) REFERENCES CourseInformation(TableId, ClassId) ON DELETE CASCADE)";

/**
 * 旧数据搬运时的落盘备份表。
 *
 * 为什么需要：搬运过程要"删旧表 -> 建新表 -> 逐行回灌"，中间若进程被杀，
 * 用户课程表就没了。把旧行先原样写进这张表，崩溃后仍可人工恢复。
 *
 * 列全部可空、类型统一 TEXT —— 备份只求"原样存住"，不参与任何业务查询，
 * 因此不依赖旧库的具体形态（旧库 WeekDay 是中文、节次也可能存成文本）。
 * 搬运成功后该表即被删除。
 */
constexpr const char *COURSE_SCHEDULE_LEGACY_DDL =
    "CREATE TABLE CourseSchedule_legacy ("
    "  TableId TEXT,"
    "  ClassId TEXT,"
    "  ScheduleId TEXT,"
    "  WeekDay TEXT,"
    "  StartSession TEXT,"
    "  EndSession TEXT,"
    "  Place TEXT,"
    "  WeekRanges TEXT)";

/**
 * ScheduleTableInformation 的正式 DDL（旧库主键列叫 TableId，新库叫 ScheduleId）。
 */
constexpr const char *SCHEDULE_TABLE_DDL =
    "CREATE TABLE IF NOT EXISTS ScheduleTableInformation ("
    "  ScheduleId INTEGER PRIMARY KEY AUTOINCREMENT,"
    "  TableName TEXT NOT NULL,"
    "  StartDate TEXT NOT NULL,"
    "  UNIQUE (TableName, StartDate))";

constexpr const char *SCHEDULE_TABLE_LEGACY_DDL =
    "CREATE TABLE ScheduleTableInformation_legacy ("
    "  TableId TEXT,"
    "  TableName TEXT,"
    "  StartDate TEXT)";

/**
 * CourseInformation 的正式 DDL。
 * 单独抽成常量：旧数据搬运要"用完全相同的 DDL 重建该表"，
 * 且这里的主键声明正是修复"父键不是主键导致外键全废"的关键。
 */
constexpr const char *COURSE_INFO_DDL =
    "CREATE TABLE IF NOT EXISTS CourseInformation ("
    "  TableId INTEGER NOT NULL,"
    "  ClassId TEXT NOT NULL,"
    "  CourseName TEXT NOT NULL,"
    "  CourseNo TEXT NOT NULL,"
    "  CourseSerialNum TEXT NOT NULL,"
    "  Credit TEXT,"
    "  CreditHours TEXT,"
    "  TeachingProcess TEXT,"
    "  ExamPlace TEXT,"
    "  ExamDate TEXT,"
    "  ClassDateAndPlace TEXT,"
    "  Color TEXT,"
    "  PRIMARY KEY (TableId, ClassId),"
    "  FOREIGN KEY (TableId) REFERENCES ScheduleTableInformation(ScheduleId) ON DELETE CASCADE)";

/** 周次关联表：一次上课安排覆盖哪些周。替代原 WeekRanges 逗号串。 */
constexpr const char *COURSE_WEEK_DDL =
    "CREATE TABLE IF NOT EXISTS CourseWeek ("
    "  TableId INTEGER NOT NULL,"
    "  ClassId TEXT NOT NULL,"
    "  ScheduleId TEXT NOT NULL,"
    "  Week INTEGER NOT NULL,"
    "  PRIMARY KEY (TableId, ClassId, ScheduleId, Week),"
    "  FOREIGN KEY (TableId, ClassId, ScheduleId)"
    "    REFERENCES CourseSchedule(TableId, ClassId, ScheduleId) ON DELETE CASCADE)";

/** 考试安排（原 CourseInformation 内联 ExamPlace/ExamDate 只能存一场，规范化拆出） */
constexpr const char *EXAMS_DDL =
    "CREATE TABLE IF NOT EXISTS Exams ("
    "  TableId INTEGER NOT NULL,"
    "  ClassId TEXT NOT NULL,"
    "  ExamName TEXT,"
    "  ExamPlace TEXT,"
    "  ExamDate TEXT,"
    "  PRIMARY KEY (TableId, ClassId, ExamName),"
    "  FOREIGN KEY (TableId, ClassId) REFERENCES CourseInformation(TableId, ClassId) ON DELETE CASCADE)";

/**
 * v1 建表语句，按依赖顺序排列（父表在前）。
 * 每张表的 DDL 都抽成具名常量，保证"建库"与"旧数据搬运重建"用的是同一份定义。
 */
constexpr const char *SCHEMA_V1_SQL[] = {    // ---- 宿舍 / 电费域 ----
    "CREATE TABLE IF NOT EXISTS Areas ("
    "  AreaId TEXT PRIMARY KEY,"
    "  Area TEXT NOT NULL)",

    "CREATE TABLE IF NOT EXISTS Buildings ("
    "  BuildingId TEXT PRIMARY KEY,"
    "  Building TEXT NOT NULL,"
    "  AreaId TEXT NOT NULL,"
    "  FOREIGN KEY (AreaId) REFERENCES Areas(AreaId) ON DELETE CASCADE)",

    "CREATE TABLE IF NOT EXISTS Floors ("
    "  FloorId TEXT NOT NULL,"
    "  Floor TEXT NOT NULL,"
    "  BuildingId TEXT NOT NULL,"
    "  PRIMARY KEY (FloorId, BuildingId),"
    "  FOREIGN KEY (BuildingId) REFERENCES Buildings(BuildingId) ON DELETE CASCADE)",

    "CREATE TABLE IF NOT EXISTS Rooms ("
    "  RoomId TEXT NOT NULL,"
    "  Room TEXT NOT NULL,"
    "  BuildingId TEXT NOT NULL,"
    "  FloorId TEXT NOT NULL,"
    "  PRIMARY KEY (RoomId, BuildingId, FloorId),"
    "  FOREIGN KEY (FloorId, BuildingId) REFERENCES Floors(FloorId, BuildingId) ON DELETE CASCADE)",

    // MeterId 才是表的主键；一间房一个电表。
    // 注意：Rooms 的主键是 (RoomId, BuildingId, FloorId) 复合键，
    // 因此外键必须整组引用 —— SQLite 要求父键是主键或整体 UNIQUE，
    // 单列引用 Rooms(RoomId) 会让写 Meters 直接失败（实测 RDB_E_ERROR）。
    "CREATE TABLE IF NOT EXISTS Meters ("
    "  MeterId TEXT PRIMARY KEY,"
    "  RoomId TEXT NOT NULL,"
    "  BuildingId TEXT NOT NULL,"
    "  FloorId TEXT NOT NULL,"
    "  UNIQUE (RoomId),"
    "  FOREIGN KEY (RoomId, BuildingId, FloorId)"
    "    REFERENCES Rooms(RoomId, BuildingId, FloorId) ON DELETE CASCADE)",

    // 收藏的宿舍（用户数据）
    // 列名 isStar 与 ArkTS 模型 DormitoryLocation.isStar 保持一致（原实现亦为 isStar），
    // 避免应用层与 DB 层命名不一致导致的隐式错误。
    // ElectricFee / RemainingElectric 是"上次查询到的电费与剩余电量"缓存列，
    // 旧表即有；本次重写 schema 时一度遗漏，导致写入报 RDB_E_ERROR。
    "CREATE TABLE IF NOT EXISTS DormitoryLocation ("
    "  Id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "  Area TEXT NOT NULL, AreaId TEXT NOT NULL,"
    "  Building TEXT NOT NULL, BuildingId TEXT NOT NULL,"
    "  Floor TEXT NOT NULL, FloorId TEXT NOT NULL,"
    "  Room TEXT NOT NULL, RoomId TEXT NOT NULL,"
    "  MeterId TEXT,"
    "  isStar INTEGER NOT NULL DEFAULT 0,"
    "  ElectricFee TEXT,"
    "  RemainingElectric TEXT,"
    "  UNIQUE (AreaId, BuildingId, FloorId, RoomId))",

    // ---- 课程表域（父 -> 子）----
    // 原表名 ScheduleTableInformation 里表的主键叫 TableId，
    // 而代码/模型一律叫 ScheduleId，命名分裂。此处统一为 ScheduleId。
    SCHEDULE_TABLE_DDL,

    COURSE_INFO_DDL,

    // 一次上课安排。ClassId 不再冗余存 CourseName（原表重复存储，改名要同步两处）。
    COURSE_SCHEDULE_DDL,

    COURSE_WEEK_DDL,

    EXAMS_DDL,
};

/**
 * 索引语句。单独成组的原因：旧数据搬运会 DROP + CREATE 业务表，
 * 索引会跟着表一起消失，因此搬运结束后必须再执行一遍（都是 IF NOT EXISTS，幂等）。
 */
constexpr const char *SCHEMA_INDEX_SQL[] = {
    // 主查询形态：WHERE TableId=? AND WeekDay=? ORDER BY StartSession
    "CREATE INDEX IF NOT EXISTS idx_course_schedule_lookup"
    "  ON CourseSchedule(TableId, WeekDay, StartSession)",
    // 周次查询形态：WHERE TableId=? AND Week=? （等值，替代原来的四个 LIKE）
    "CREATE INDEX IF NOT EXISTS idx_course_week_lookup"
    "  ON CourseWeek(TableId, Week, ClassId, ScheduleId)",
    "CREATE INDEX IF NOT EXISTS idx_schedule_table_name"
    "  ON ScheduleTableInformation(TableName)",
    "CREATE INDEX IF NOT EXISTS idx_dorm_star"
    "  ON DormitoryLocation(isStar)",
};

/**
 * 旧 CourseInformation 的落盘备份表（安全副本，形态固定、全部可空）。
 * 与 CourseSchedule_legacy 同理：搬运要重建父表，先把原样数据存住。
 */
constexpr const char *COURSE_INFO_LEGACY_DDL =
    "CREATE TABLE CourseInformation_legacy ("
    "  TableId TEXT,"
    "  ClassId TEXT,"
    "  CourseName TEXT,"
    "  CourseNo TEXT,"
    "  CourseSerialNum TEXT,"
    "  Credit TEXT,"
    "  CreditHours TEXT,"
    "  TeachingProcess TEXT,"
    "  ExamPlace TEXT,"
    "  ExamDate TEXT,"
    "  ClassDateAndPlace TEXT,"
    "  Color TEXT)";

/** 要在搬运中按新结构重建的列（顺序即备份表/新表的列序） */
constexpr const char *COURSE_INFO_COLUMNS[] = {
    "TableId",      "ClassId",  "CourseName",        "CourseNo",
    "CourseSerialNum", "Credit", "CreditHours",     "TeachingProcess",
    "ExamPlace",    "ExamDate", "ClassDateAndPlace", "Color",
};
constexpr int COURSE_INFO_COLUMN_COUNT = 12;

/**
 * 课程表域的重建顺序。
 *
 * 删表必须"先子后父"：父表被 DROP 时 SQLite 会按外键级联删除子表数据，
 * 顺序错了会把数据清掉。建表则相反，"先父后子"，否则子表的外键找不到父键。
 */
constexpr const char *SCHEDULE_DROP_ORDER[] = {
    "CourseWeek",
    "Exams",
    "CourseSchedule",
    "CourseInformation",
    "ScheduleTableInformation",
};

/** 建表语句：与 SCHEDULE_DROP_ORDER 反序，复用各表的正式 DDL，避免两处漂移 */
constexpr const char *SCHEDULE_CREATE_ORDER[] = {
    SCHEDULE_TABLE_DDL,
    COURSE_INFO_DDL,
    COURSE_SCHEDULE_DDL,
    COURSE_WEEK_DDL,
    EXAMS_DDL,
};

/**
 * 早期版本中断搬运时留下的中间表（*_legacy 备份表 / *_new 过渡表）。
 * 搬运开始前必须先清掉，否则残留的旧备份会与本次的备份撞名，
 * 而且会让"搬运后不应残留 _legacy 表"这类断言失真。
 */
constexpr const char *STALE_MIGRATION_TABLES[] = {
    "ScheduleTableInformation_legacy",
    "CourseInformation_legacy",
    "CourseSchedule_legacy",
    "CourseWeek_legacy",
    "CourseSchedule_new",
    "CourseInformation_new",
    "ScheduleTableInformation_new",
    // 排查期间用过的外键隔离实验临时表（可能残留在开发机的库上）
    "T_FK_PARENT",
    "T_FK_CHILD",
    "T_FK_CHILD2",
    "T_FK_PARENT3",
    "T_FK_CHILD3",
};

/**
 * 幂等的结构修正语句：每次打开都执行，用于把"版本号已是最新但列名不对"
 * 的历史库就地修好，无需丢数据重建。
 * 当前项：早期 schema 曾把 DormitoryLocation 的列写作 IsStar，
 * 与模型/旧代码使用的 isStar 不一致。
 */
constexpr const char *SCHEMA_PATCH_SQL[] = {
    "ALTER TABLE DormitoryLocation RENAME COLUMN IsStar TO isStar",
};

} // namespace whutdb

#endif // WHUTHELPER_SCHEMA_H
