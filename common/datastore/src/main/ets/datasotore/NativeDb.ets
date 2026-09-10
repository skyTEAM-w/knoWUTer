/**
 * 共享数据层对外门面（原生 NDK RDB 实现）。
 *
 * 架构约定：数据库原生实现位于本模块 src/main/cpp，由 libwhutdb.so 提供。
 * 上层（entry / features/*）一律通过 `@ohos/datastore` 访问数据层，
 * 不得直接 import 'libwhutdb.so'，以保证入口收敛、实现可替换。
 *
 * 本文件解决原 DBUtil 的两个结构性问题：
 *  1. 初始化竞态：原实现 fire-and-forget 地初始化，DBUtil.getInstance() 返回时
 *     store 仍可能未就绪，且用 `as RdbStore` 强转掩盖 undefined，冷启动会崩。
 *     这里改为 ready Promise —— 所有操作先 await 就绪，类型上不可能拿到未就绪的库。
 *  2. 游标泄漏：原实现把 ResultSet 返回给业务层且从不 close()。
 *     这里 expose 的是返回普通行数组的 query()，游标在原生侧读完即销毁。
 */
import {
  dbOpen,
  dbQuery,
  dbExec,
  dbBeginTransaction,
  dbCommit,
  dbRollback,
  dbVerifyPhase0,
  dbDriftProbe,
  DbOpenResult,
  DbRow,
  Phase0VerifyResult,
  DriftProbeResult,
} from '@type/libwhutdb.so';

export type {
  DbOpenResult, DbRow, Phase0VerifyResult, DriftProbeResult,
};

/**
 * 阶段 0 结构验证（在独立验证库上执行，不触碰业务库）。
 * 过渡期诊断接口，正式数据层 API 补齐后可移除。
 */
export function verifyPhase0(databaseDir: string): Phase0VerifyResult {
  return dbVerifyPhase0(databaseDir);
}

/**
 * 漂移自愈验证（在独立库上执行）。
 * 确认"版本号正确但结构不符"能被检出并重建。
 */
export function verifyDriftHealing(databaseDir: string): DriftProbeResult {
  return dbDriftProbe(databaseDir);
}

/** 是否已成功就绪 */
let g_ready: boolean = false;
/** 就绪 Promise；首次初始化时创建，后续复用，避免并发重复初始化 */
let g_readyPromise: Promise<void> | undefined = undefined;
/** 失败原因，便于调用方诊断 */
let g_initError: string = '';

/** 事务互斥：原生侧共用同一连接，必须串行化事务，否则语句会互相插入 */
let g_txLock: Promise<void> = Promise.resolve();

/**
 * 打开数据库并完成 schema 迁移。可重复调用，重复调用为幂等。
 *
 * 建议在 UIAbility.onCreate 中 await，或依赖各 API 内部的隐式就绪等待。
 */
export function initDatabase(databaseDir: string): Promise<void> {
  if (g_readyPromise !== undefined) {
    return g_readyPromise;
  }
  g_readyPromise = new Promise<void>((resolve: () => void, reject: (e: Error) => void) => {
    try {
      const result: DbOpenResult = dbOpen(databaseDir);
      if (result.storeOpened && result.lastError === 0) {
        g_ready = true;
        resolve();
      } else {
        g_initError = `dbOpen failed: storeOpened=${result.storeOpened} lastError=${result.lastError}`;
        reject(new Error(g_initError));
      }
    } catch (e) {
      g_initError = `dbOpen threw: ${e}`;
      reject(new Error(g_initError));
    }
  });
  return g_readyPromise;
}

/** 当前是否已就绪（仅用于状态判断，不要用它替代 await） */
export function isReady(): boolean {
  return g_ready;
}

/** 初始化失败原因，空串表示无错误 */
export function getInitError(): string {
  return g_initError;
}

/**
 * 执行一条写语句。返回受影响行数，失败返回负数。
 * 内部会先等待数据库就绪。
 */
export async function exec(sql: string): Promise<number> {
  await waitReady();
  return dbExec(sql);
}

/**
 * 执行查询，返回行数组。
 * 内部会先等待数据库就绪。
 */
export async function query(sql: string): Promise<DbRow[]> {
  await waitReady();
  return dbQuery(sql);
}

/**
 * 在事务中执行一组操作。
 *
 * 原实现完全没有跨语句事务：插入一套课表是 Schedule + N 门课 + M 次安排
 * 三次循环写入，中途失败会留下半个课表。这里提供真正的原子边界。
 *
 * 事务期间持锁，避免其他调用方的语句插进本事务。
 */
export async function runInTransaction<T>(fn: () => Promise<T>): Promise<T> {
  await waitReady();

  // 排队获取事务锁
  const previous: Promise<void> = g_txLock;
  let release: () => void = () => {};
  g_txLock = new Promise<void>((resolve: () => void) => {
    release = resolve;
  });
  await previous;

  try {
    const beginResult: number = dbBeginTransaction();
    if (beginResult !== 0) {
      throw new Error(`dbBeginTransaction failed: ${beginResult}`);
    }
    try {
      const value: T = await fn();
      const commitResult: number = dbCommit();
      if (commitResult !== 0) {
        throw new Error(`dbCommit failed: ${commitResult}`);
      }
      return value;
    } catch (e) {
      // 业务逻辑失败必须回滚，否则半个课表会落库
      dbRollback();
      throw e as Error;
    }
  } finally {
    release();
  }
}

/** 等待数据库就绪；未初始化时给出明确错误而不是静默失败 */
async function waitReady(): Promise<void> {
  if (g_ready) {
    return;
  }
  if (g_readyPromise === undefined) {
    throw new Error('数据库尚未初始化：请先调用 initDatabase(context.databaseDir)');
  }
  await g_readyPromise;
}

// ---------------------------------------------------------------- 行取值helper
//
// ArkTS 严格模式不允许对 Record 做动态下标访问（obj['key']），
// 而这些 helper 把取值集中在一处，避免每个调用点重复做类型断言与空值处理。

/** 取字符串列；缺列或 NULL 返回 fallback */
export function colString(row: DbRow, column: string, fallback: string = ''): string {
  const value: string | number | boolean | null = row[column];
  if (value === null || value === undefined) {
    return fallback;
  }
  if (typeof value === 'string') {
    return value;
  }
  return String(value);
}

/** 取数值列；缺列或 NULL 返回 fallback */
export function colNumber(row: DbRow, column: string, fallback: number = 0): number {
  const value: string | number | boolean | null = row[column];
  if (value === null || value === undefined) {
    return fallback;
  }
  if (typeof value === 'number') {
    return value;
  }
  if (typeof value === 'boolean') {
    return value ? 1 : 0;
  }
  const parsed: number = Number(value);
  return Number.isNaN(parsed) ? fallback : parsed;
}

/** 取布尔列（SQLite 用 0/1 表示）；缺列或 NULL 返回 fallback */
export function colBool(row: DbRow, column: string, fallback: boolean = false): boolean {
  const value: string | number | boolean | null = row[column];
  if (value === null || value === undefined) {
    return fallback;
  }
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'number') {
    return value !== 0;
  }
  return value === '1' || value === 'true';
}

/** 查询单行；无结果返回 undefined */
export async function queryOne(sql: string): Promise<DbRow | undefined> {
  const rows: DbRow[] = await query(sql);
  return rows.length > 0 ? rows[0] : undefined;
}

/** 查询单列标量（COUNT 等）；无结果或转换失败返回 fallback */
export async function queryScalar(sql: string, fallback: number = 0): Promise<number> {
  const rows: DbRow[] = await query(sql);
  if (rows.length === 0) {
    return fallback;
  }
  const first: DbRow = rows[0];
  const keys: string[] = Object.keys(first);
  if (keys.length === 0) {
    return fallback;
  }
  return colNumber(first, keys[0], fallback);
}

/**
 * 转义 SQL 字符串字面量。
 *
 * 原生层只接受完整 SQL 文本（未做参数绑定），因此拼接用户/网络来源的字符串时
 * 必须转义，否则会注入或语法出错。单引号按 SQL 标准双写转义。
 */
export function sqlQuote(value: string): string {
  return `'${value.replace(/'/g, "''")}'`;
}
