export { PreferencesUtil } from './src/main/ets/datasotore/PreferencesUtil';

// 原生数据层（NDK RDB）门面 —— 上层统一入口
// 旧的 ArkTS 数据层 DBUtil 已随 Schedule/Tools 迁移完成而退役（文件已删除）。
export { initDatabase, isReady, getInitError, exec, query, runInTransaction } from './src/main/ets/datasotore/NativeDb';
export { colString, colNumber, colBool, queryOne, queryScalar, sqlQuote } from './src/main/ets/datasotore/NativeDb';
export type { DbOpenResult, DbRow } from './src/main/ets/datasotore/NativeDb';

// 结构自检（都在独立库上执行，不触碰业务库），用于诊断历史库结构是否正常。
// 注意：定位具体 bug 用的一次性探针（写读一致性 / A-B 语句对比 / 宿舍写入二分 /
// 旧数据搬运）在问题定位完成后已随发布一起移除 —— 其中旧数据搬运探针会
// DROP 掉全部业务表，留在正式产物里是数据风险。
export { verifyPhase0, verifyDriftHealing } from './src/main/ets/datasotore/NativeDb';
export type { Phase0VerifyResult, DriftProbeResult } from './src/main/ets/datasotore/NativeDb';
