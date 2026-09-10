/** 打开业务库并执行迁移的结果 */
export interface DbOpenResult {
  /** 库是否成功打开 */
  storeOpened: boolean;
  /**
   * `PRAGMA foreign_keys` 读数。
   * 警告：该读数在 HarmonyOS RDB 上恒为 false 且不可作准 ——
   * RDB 在内部连接池上维护外键开关，查询走的是另一条连接。
   * 判断外键是否生效请以 Phase0VerifyResult.compositeFkEnforced 的行为证据为准。
   */
  foreignKeyEnabled: boolean;
  /** 迁移后的 schema 版本，-1 表示读取失败 */
  schemaVersion: number;
  /** 最后一次错误码，0 表示无错误 */
  lastError: number;
}

/** 阶段 0 验证结果 */
export interface Phase0VerifyResult {
  /** sqlite_master 中的业务表数量 */
  tables: number;
  /** 以 idx_ 开头的索引数量 */
  indexes: number;
  /** schema 版本 */
  schemaVersion: number;
  /** `PRAGMA foreign_keys` 读数，见 DbOpenResult 中的警告，不可作准 */
  foreignKeyEnabled: boolean;
  /**
   * 周次关联表是否消除了假阳性：
   * 数据只含第 1 周与第 11 周时，等值查询各自恰好命中 1 条且整表共 2 条。
   * 旧的 LIKE 实现在此场景下查第 1 周会误命中第 11 周。
   */
  week1And11Separated: boolean;
  /**
   * 外键是否真正强制 —— 权威行为证据：
   * 插入父行不存在的孤儿行应被拒绝，同时合法行必须能插入成功。
   * 该结论不依赖 PRAGMA 读数。
   */
  compositeFkEnforced: boolean;
  /** 主键列写 NULL 是否被列级 NOT NULL 拒绝（期望 true） */
  nullKeyRejectedByNotNull: boolean;
  /** 复合外键某列为 NULL 时是否绕过约束（在 HarmonyOS RDB 上实测未绕过，属已记录边界） */
  compositeFkNullBypassed: boolean;
  /** 最后一次错误码 */
  lastError: number;
}

/**
 * 打开业务库并完成 schema 迁移。
 * @param databaseDir 来自 ArkTS 侧 context.databaseDir
 */
export const dbOpen: (databaseDir: string) => DbOpenResult;

/**
 * 阶段 0 结构验证（在独立验证库上执行，不触碰业务库）。
 * @param databaseDir 来自 ArkTS 侧 context.databaseDir
 */
export const dbVerifyPhase0: (databaseDir: string) => Phase0VerifyResult;

/** 查询返回的单行：列名 -> 值。类型由 SQLite 列类型决定（INTEGER/REAL -> number，TEXT -> string，NULL -> null） */
export type DbRow = Record<string, string | number | boolean | null>;

/**
 * 泛型查询。必须在 dbOpen 成功之后调用。
 *
 * 返回普通 JS 数组 —— 游标在原生侧读完即销毁，不跨越 NAPI 边界，
 * 从结构上杜绝原实现的 ResultSet 句柄泄漏。
 * 查询失败返回空数组（错误详情见 hilog）。
 */
export const dbQuery: (sql: string) => DbRow[];

/**
 * 泛型执行（INSERT/UPDATE/DELETE/DDL）。返回受影响行数，失败返回负数。
 */
export const dbExec: (sql: string) => number;

/** 开启事务。返回 0 表示成功。 */
export const dbBeginTransaction: () => number;

/** 提交事务。返回 0 表示成功。 */
export const dbCommit: () => number;

/** 回滚事务。返回 0 表示成功。 */
export const dbRollback: () => number;

/** 漂移自愈探针结果（诊断用） */
export interface DriftProbeResult {
  /** 是否成功人为注入结构漂移（前置条件） */
  driftDetected: boolean;
  /** 重跑迁移后是否已自愈（表重建、列恢复） */
  healed: boolean;
  /** 最后一次错误码 */
  lastError: number;
}

/**
 * 漂移自愈探针（诊断用，在独立库上执行）。
 * 验证"版本号正确但结构不符"时能检出并重建，这是保护历史库的关键路径。
 */
export const dbDriftProbe: (databaseDir: string) => DriftProbeResult;

