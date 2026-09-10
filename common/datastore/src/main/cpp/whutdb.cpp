/*
 * 共享数据层原生实现（NDK RDB）。
 *
 * 架构位置：隶属于 common/datastore（共享数据层 HAR）。
 * 上层通过 @ohos/datastore 访问，不直接依赖本 .so。
 *
 * 当前阶段：阶段 0（止血）——schema 单一来源、版本迁移、外键真正生效、
 * 周次关联表、主键修正、索引补齐。业务查询 API 在后续阶段逐步补齐。
 */
#include <hilog/log.h>
#include <database/rdb/relational_store.h>
#include <database/rdb/oh_cursor.h>
#include <database/rdb/oh_values_bucket.h>
#include <string>
#include <vector>
#include <ctime>
#include <cstdio>
#include <cstring>
#include "napi/native_api.h"
#include "Schema.h"

namespace {
constexpr int LOG_DOMAIN_ID = 0x0001;
// 注意：不能叫 LOG_TAG，hilog/log.h 已定义同名宏（展开成 NULL 导致语法错误）
constexpr const char *DB_TAG = "whutdb";
constexpr const char *BUNDLE_NAME = "com.wuchengpei.whuthelper";
// 原生库在 entry 模块内被加载，数据库按模块目录隔离
constexpr const char *MODULE_NAME = "entry";

/**
 * 进程内复用的业务库句柄。
 * 每次查询都重开库会重复跑迁移与 PRAGMA，代价高且会让连接池状态漂移；
 * 因此 dbOpen 成功后保留句柄，后续 query/exec 直接复用。
 */
OH_Rdb_Store *g_store = nullptr;

/** 单列最大读取长度上界，用于 getSize 异常时的保护 */
constexpr size_t MAX_TEXT_LEN = 1 << 20; // 1 MiB

void LogInfo(const char *step, const std::string &msg)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN_ID, DB_TAG, "%{public}s: %{public}s", step, msg.c_str());
}

void LogErr(const char *step, const std::string &msg, int code)
{
    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN_ID, DB_TAG,
                 "%{public}s failed: %{public}s, code=%{public}d", step, msg.c_str(), code);
}

// ---------------------------------------------------------------- NAPI helpers

napi_value MakeString(napi_env env, const std::string &value)
{
    napi_value out = nullptr;
    napi_create_string_utf8(env, value.c_str(), value.length(), &out);
    return out;
}

napi_value MakeBool(napi_env env, bool value)
{
    napi_value out = nullptr;
    napi_get_boolean(env, value, &out);
    return out;
}

napi_value MakeInt(napi_env env, int64_t value)
{
    napi_value out = nullptr;
    napi_create_int64(env, value, &out);
    return out;
}

bool GetStringArg(napi_env env, napi_callback_info info, size_t argIndex, std::string *out)
{
    size_t argc = argIndex + 1;
    napi_value args[4] = {nullptr};
    if (napi_get_cb_info(env, info, &argc, args, nullptr, nullptr) != napi_ok) {
        return false;
    }
    if (argc <= argIndex || args[argIndex] == nullptr) {
        return false;
    }
    size_t len = 0;
    if (napi_get_value_string_utf8(env, args[argIndex], nullptr, 0, &len) != napi_ok) {
        return false;
    }
    std::string buf(len + 1, '\0');
    // 末参必须是独立 size_t*；C++17 起 string::data() 返回 const char*，故用 &buf[0]
    size_t copied = 0;
    if (napi_get_value_string_utf8(env, args[argIndex], &buf[0], len + 1, &copied) != napi_ok) {
        return false;
    }
    buf.resize(copied);
    *out = buf;
    return true;
}

// ---------------------------------------------------------------- RDB helpers

OH_Rdb_Store *OpenStore(const std::string &dbDir, const char *storeName, int *errCode)
{
    OH_Rdb_ConfigV2 *config = OH_Rdb_CreateConfig();
    if (config == nullptr) {
        *errCode = -1;
        return nullptr;
    }
    OH_Rdb_SetDatabaseDir(config, dbDir.c_str());
    OH_Rdb_SetStoreName(config, storeName);
    OH_Rdb_SetBundleName(config, BUNDLE_NAME);
    OH_Rdb_SetModuleName(config, MODULE_NAME);
    OH_Rdb_SetSecurityLevel(config, OH_Rdb_SecurityLevel::S3);
    OH_Rdb_SetEncrypted(config, false);
    OH_Rdb_SetArea(config, RDB_SECURITY_AREA_EL2);

    OH_Rdb_Store *store = OH_Rdb_CreateOrOpen(config, errCode);
    OH_Rdb_DestroyConfig(config);
    return store;
}

/**
 * 取业务库的 store 句柄，供探针复用。
 *
 * 为什么不能各开各的：真机实测 OH_Rdb_CreateOrOpen 对同一份配置返回的是
 * **同一个缓存实例**，所以"探针自己开一条连接"实际拿到的就是业务句柄。
 * 探针结束时若 CloseStore，业务侧随后所有查询都在用一个已失效的句柄，
 * 表现为"迁移明明成功、界面查询却读到空结果"。
 * 因此探针一律复用全局句柄，并且不负责关闭它。
 */
OH_Rdb_Store *AcquireBusinessStore(const std::string &dbDir, int *errOut)
{
    if (g_store != nullptr) {
        return g_store;
    }
    return OpenStore(dbDir, whutdb::BUSINESS_DB_NAME, errOut);
}

/** 关闭 store —— 但绝不关闭业务库的全局句柄（那是 dbOpen 的职责） */
void ReleaseStore(OH_Rdb_Store *store)
{
    if (store != nullptr && store != g_store) {
        OH_Rdb_CloseStore(store);
    }
}

/** 执行一条无结果集 SQL，失败时记录日志 */
bool ExecSql(OH_Rdb_Store *store, const char *sql, int *errOut)
{
    int ret = OH_Rdb_Execute(store, sql);
    if (ret != 0) {
        LogErr("execSql", std::string("SQL failed: ") + sql, ret);
        if (errOut != nullptr) {
            *errOut = ret;
        }
        return false;
    }
    return true;
}

/**
 * 把 OH_Cursor 的文本列读成 std::string。
 *
 * 关键坑：OH_Cursor::getSize 返回的长度**包含结尾的 '\0'**。
 * 若直接 resize(size) 会把那个 '\0' 当成内容留在字符串尾部，
 * 表现为"取回的文本比原值多一个字符"，且与期望值字符串比较恒不相等。
 * 因此这里按实际写入的 C 串长度截断。
 *
 * 返回 false 表示读取失败或超长。
 */
bool ReadTextColumn(OH_Cursor *cursor, int32_t columnIndex, std::string *out)
{
    size_t size = 0;
    if (cursor->getSize(cursor, columnIndex, &size) != 0) {
        return false;
    }
    if (size == 0) {
        out->clear();
        return true;
    }
    if (size >= MAX_TEXT_LEN) {
        LogErr("readText", "column size over limit", static_cast<int>(size));
        return false;
    }
    // 多要 1 字节保证 NUL 终止
    std::string buf(size + 1, '\0');
    if (cursor->getText(cursor, columnIndex, &buf[0], static_cast<int>(size + 1)) != 0) {
        return false;
    }
    // getText 写入的是以 NUL 结尾的 C 串，按真实长度截断
    buf.resize(std::char_traits<char>::length(buf.c_str()));
    *out = buf;
    return true;
}

/** 查单个整数（用于 PRAGMA / COUNT 等标量查询） */
bool QueryScalarInt(OH_Rdb_Store *store, const char *sql, int64_t *out, int *errOut)
{
    OH_Cursor *cursor = OH_Rdb_ExecuteQuery(store, sql);
    if (cursor == nullptr) {
        if (errOut != nullptr) {
            *errOut = -1;
        }
        return false;
    }
    bool ok = false;
    if (cursor->goToNextRow(cursor) == 0) {
        int64_t value = 0;
        if (cursor->getInt64(cursor, 0, &value) == 0) {
            *out = value;
            ok = true;
        }
    }
    cursor->destroy(cursor);
    return ok;
}

/**
 * 把一个游标列读成字符串，**按列的实际类型分派**。
 *
 * 这是一个必须踩过才知道的坑：OH_Cursor::getSize / getText 对 INTEGER 列返回空串
 * （不是报错，是"成功但长度为 0"）。如果一律用 getText 读，整数列会静默变成空字符串，
 * 再经 std::stoll / ToInt64 一转换就成了 0。
 *
 * 实际后果：旧库 CourseSchedule.TableId 是 INTEGER，搬运时读回 "" -> 0，
 * 于是所有搬过来的行 TableId 都成了 0；而代码按 TableId=1 查询自然一条都查不到。
 * 表面看像"数据没搬过来"，其实是"读列的方式不对"。
 */
bool ReadColumnAsText(OH_Cursor *cursor, int32_t columnIndex, std::string *out)
{
    OH_ColumnType type = TYPE_NULL;
    if (cursor->getColumnType(cursor, columnIndex, &type) != 0) {
        // 拿不到类型时退回按文本读，保持行为可预期
        return ReadTextColumn(cursor, columnIndex, out);
    }
    switch (type) {
        case TYPE_NULL:
            out->clear();
            return true;
        case TYPE_INT64: {
            int64_t value = 0;
            if (cursor->getInt64(cursor, columnIndex, &value) != 0) {
                return false;
            }
            *out = std::to_string(value);
            return true;
        }
        case TYPE_REAL: {
            double value = 0;
            if (cursor->getReal(cursor, columnIndex, &value) != 0) {
                return false;
            }
            // 用 %.17g 保证往返精度，避免 1.10 变成 1.1 之类
            char buf[64] = {0};
            std::snprintf(buf, sizeof(buf), "%.17g", value);
            *out = buf;
            return true;
        }
        case TYPE_TEXT:
        default:
            return ReadTextColumn(cursor, columnIndex, out);
    }
}

/** 不区分大小写地比较两个标识符 */
bool EqualsIgnoreCase(const std::string &a, const char *b)
{
    size_t n = std::strlen(b);
    if (a.size() != n) {
        return false;
    }
    for (size_t i = 0; i < n; i++) {
        char ca = a[i];
        char cb = b[i];
        if (ca >= 'A' && ca <= 'Z') {
            ca = static_cast<char>(ca - 'A' + 'a');
        }
        if (cb >= 'A' && cb <= 'Z') {
            cb = static_cast<char>(cb - 'A' + 'a');
        }
        if (ca != cb) {
            return false;
        }
    }
    return true;
}

/** 取 sqlite_master 里某张表的建表语句；不存在返回 false */
bool ReadTableDdl(OH_Rdb_Store *store, const char *table, std::string *ddlOut)
{
    std::string sql = std::string("SELECT sql FROM sqlite_master WHERE type='table' AND name='") +
                      table + "'";
    OH_Cursor *cursor = OH_Rdb_ExecuteQuery(store, sql.c_str());
    if (cursor == nullptr) {
        return false;
    }
    bool found = false;
    if (cursor->goToNextRow(cursor) == 0) {
        found = ReadTextColumn(cursor, 0, ddlOut);
    }
    cursor->destroy(cursor);
    return found;
}

/**
 * 建表语句里是否出现某个关键字（整段文本子串匹配）。
 * 只适合查 "PRIMARY KEY" / "AUTOINCREMENT" 这类关键字，不要拿来判列名。
 */
bool TableDdlContains(OH_Rdb_Store *store, const char *table, const char *needle)
{
    std::string ddl;
    if (!ReadTableDdl(store, table, &ddl)) {
        return false;
    }
    return ddl.find(needle) != std::string::npos;
}

/**
 * 判断某表是否具备指定列；依据 sqlite_master 中记录的建表语句 —— 不依赖 PRAGMA，
 * 因为 RDB 下 PRAGMA 读数走的是另一条连接、不可靠。
 *
 * 这里必须把列定义真正解析出来做**整词**比较，不能用 ddl.find(column)：
 * 新结构的 WeekRangesStr 含有子串 "WeekRanges"，子串匹配会把已经迁移完成的库
 * 误判成旧结构，于是每次启动都去跑"旧数据搬运"，而搬运第一步就是按旧列名 SELECT，
 * 必然查不到列、读回 0 行，看起来像"数据丢了"。
 */
bool TableHasColumn(OH_Rdb_Store *store, const char *table, const char *column)
{
    std::string ddl;
    if (!ReadTableDdl(store, table, &ddl)) {
        return false;
    }
    size_t lp = ddl.find('(');
    size_t rp = ddl.rfind(')');
    if (lp == std::string::npos || rp == std::string::npos || rp <= lp) {
        return false;
    }
    // 按顶层逗号切出各个列定义（跳过类型声明里的括号，如 DECIMAL(10,2)）
    std::vector<std::string> defs;
    std::string current;
    int depth = 0;
    for (size_t i = lp + 1; i < rp; i++) {
        char c = ddl[i];
        if (c == '(') {
            depth++;
        } else if (c == ')') {
            depth--;
        }
        if (c == ',' && depth == 0) {
            defs.push_back(current);
            current.clear();
        } else {
            current.push_back(c);
        }
    }
    if (!current.empty()) {
        defs.push_back(current);
    }
    for (const std::string &def : defs) {
        // 取该定义的第一个词作为候选列名
        size_t s = def.find_first_not_of(" \t\r\n");
        if (s == std::string::npos) {
            continue;
        }
        size_t e = def.find_first_of(" \t\r\n(", s);
        std::string name = def.substr(s, (e == std::string::npos ? def.size() : e) - s);
        // 表级约束不是列名
        if (EqualsIgnoreCase(name, "PRIMARY") || EqualsIgnoreCase(name, "FOREIGN") ||
            EqualsIgnoreCase(name, "UNIQUE") || EqualsIgnoreCase(name, "CHECK") ||
            EqualsIgnoreCase(name, "CONSTRAINT")) {
            continue;
        }
        if (EqualsIgnoreCase(name, column)) {
            return true;
        }
    }
    return false;
}

// ---------------------------------------------------------------- schema 管理

/**
 * 应用每个新连接都必须的 PRAGMA。
 * 这一步缺失是原实现外键完全失效的根因。
 */
bool ApplyPragmas(OH_Rdb_Store *store, int *errOut)
{
    for (const char *sql : whutdb::PRAGMA_SQL) {
        if (!ExecSql(store, sql, errOut)) {
            return false;
        }
    }
    return true;
}

/**
 * 补建索引（幂等）。
 * 建表、漂移重建、旧数据搬运都会让索引缺失，所以每个路径结束时都要跑一遍。
 * 失败只记日志不报错：可能只是某张表在当前阶段还不存在（例如旧数据搬运中途）。
 */
void ApplyIndexes(OH_Rdb_Store *store)
{
    for (const char *sql : whutdb::SCHEMA_INDEX_SQL) {
        int err = 0;
        if (!ExecSql(store, sql, &err)) {
            LogInfo("index", std::string("deferred (table not ready yet): ") + sql);
        }
    }
}

/**
 * 判定当前库中的表结构是否与代码期望的 schema 一致。
 *
 * 存在的理由：版本号只解决"从旧版本升级"，解决不了"版本号对但结构不符"——
 * 例如历史上 DDL 由外部 ArkTS 代码建过、或开发期结构变过但版本未动。
 * 这种漂移会让查询静默失败（列不存在），必须显式检出。
 *
 * 检测方式用哨兵列：这些列的命名正是本次重构修正过的地方，
 * 旧结构下必然缺失。
 */
bool SchemaMatchesExpectation(OH_Rdb_Store *store)
{
    // ScheduleTableInformation: 旧结构叫 TableId，新结构叫 ScheduleId
    if (!TableHasColumn(store, "ScheduleTableInformation", "ScheduleId")) {
        LogInfo("schemaCheck", "drift: ScheduleTableInformation.ScheduleId missing");
        return false;
    }
    // CourseSchedule: 新结构有 WeekDay(INTEGER) 与 WeekRangesStr，旧结构有 WeekRanges 逗号串
    if (!TableHasColumn(store, "CourseSchedule", "WeekRangesStr")) {
        LogInfo("schemaCheck", "drift: CourseSchedule.WeekRangesStr missing");
        return false;
    }
    // Floors / Rooms: 新结构为复合主键，必须带 BuildingId；
    // 旧结构只有单列主键，需检出并重建（否则 Meters 的复合外键无法成立）
    if (!TableHasColumn(store, "Floors", "BuildingId")) {
        LogInfo("schemaCheck", "drift: Floors.BuildingId missing");
        return false;
    }
    if (!TableHasColumn(store, "Rooms", "BuildingId")) {
        LogInfo("schemaCheck", "drift: Rooms.BuildingId missing");
        return false;
    }
    // Meters: 新结构用复合外键，必须带 BuildingId / FloorId
    if (!TableHasColumn(store, "Meters", "BuildingId")) {
        LogInfo("schemaCheck", "drift: Meters.BuildingId missing");
        return false;
    }
    // DormitoryLocation: 必须带电费缓存列（旧表即有；漏建会让写入直接失败）
    if (!TableHasColumn(store, "DormitoryLocation", "ElectricFee")) {
        LogInfo("schemaCheck", "drift: DormitoryLocation.ElectricFee missing");
        return false;
    }
    // 新结构特有的周次关联表
    {
        int64_t count = 0;
        int err = 0;
        QueryScalarInt(store,
                       "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='CourseWeek'",
                       &count, &err);
        if (count != 1) {
            LogInfo("schemaCheck", "drift: CourseWeek table missing");
            return false;
        }
    }
    return true;
}

/**
 * 旧表是否存在（用于判定是否需要数据搬运）
 * 依据 sqlite_master 查询，不依赖 PRAGMA。
 */
bool TableExists(OH_Rdb_Store *store, const char *table)
{
    int64_t count = 0;
    int err = 0;
    std::string sql = std::string("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='")
                      + table + "'";
    QueryScalarInt(store, sql.c_str(), &count, &err);
    return count == 1;
}

/**
 * 宽松地把字符串转成 int64。
 *
 * 旧库里同一列可能以文本形式存放（例如 TableId 存 '1'、节次存 '1'），
 * 直接 stoll 会在非数字时抛异常并终止整个迁移，因此这里显式做校验，
 * 无法解析时返回 def 而不是抛出。
 */
int64_t ToInt64(const std::string &text, int64_t def)
{
    if (text.empty()) {
        return def;
    }
    size_t i = 0;
    bool negative = false;
    if (text[0] == '-') {
        negative = true;
        i = 1;
    }
    if (i >= text.size()) {
        return def;
    }
    int64_t value = 0;
    for (; i < text.size(); i++) {
        char c = text[i];
        if (c < '0' || c > '9') {
            return def;
        }
        value = value * 10 + static_cast<int64_t>(c - '0');
    }
    return negative ? -value : value;
}

/** 旧表列是否存在（与 TableHasColumn 同，但语义上用于"旧结构"判定） */
bool LegacyHasColumn(OH_Rdb_Store *store, const char *table, const char *column)
{
    return TableHasColumn(store, table, column);
}

/** 把中文星期（旧结构 WeekDay 的取值）映射为整数 1..7；无法识别返回 -1 */
int WeekDayToInt(const std::string &weekDay)
{
    static const char *NAMES[] = {"一", "二", "三", "四", "五", "六", "日"};
    for (int i = 0; i < 7; i++) {
        if (weekDay == NAMES[i]) {
            return i + 1;
        }
    }
    return -1;
}

/**
 * 把旧结构里逗号分隔的周次串拆成整数列表。
 * 旧结构示例："1,2,3" / "1" / 空。
 * 会忽略非法片段，去重后返回。
 */
std::vector<int64_t> ParseWeekRanges(const std::string &ranges)
{
    std::vector<int64_t> weeks;
    std::string current;
    auto flush = [&]() {
        if (current.empty()) {
            return;
        }
        // 仅接受纯数字，避免把 "undefined" 之类当周次
        bool numeric = true;
        for (char c : current) {
            if (c < '0' || c > '9') {
                numeric = false;
                break;
            }
        }
        if (numeric) {
            int64_t value = std::stoll(current);
            if (value > 0) {
                bool exists = false;
                for (int64_t w : weeks) {
                    if (w == value) {
                        exists = true;
                        break;
                    }
                }
                if (!exists) {
                    weeks.push_back(value);
                }
            }
        }
        current.clear();
    };
    for (char c : ranges) {
        if (c == ',') {
            flush();
        } else {
            current.push_back(c);
        }
    }
    flush();
    return weeks;
}

/** 单行搬运的结果：成功 / 孤儿行（父行不存在，跳过）/ 其他错误（应回滚） */
enum class InsertRowResult {
    kOk = 0,
    kOrphan = 1,
    kError = 2,
};

/** 把文本按 SQL 字面量转义（单引号加倍）。仅用于迁移期的内部查询。 */
std::string SqlQuoteText(const std::string &text)
{
    std::string out = "'";
    for (char c : text) {
        if (c == '\'') {
            out += "''";
        } else {
            out.push_back(c);
        }
    }
    out += "'";
    return out;
}

/**
 * 把一行"旧结构 CourseSchedule"按新结构写入 CourseSchedule 表。
 *
 * 列序（与迁移时的 SELECT 一致）：
 *   0 TableId, 1 ClassId, 2 ScheduleId, 3 WeekDay, 4 StartSession,
 *   5 EndSession, 6 Place, 7 WeekRanges（逗号串）
 *
 * 转换点：
 *   - WeekDay：旧结构存中文（'四'），新结构存整数 1..7
 *   - StartSession / EndSession：新结构声明为 INTEGER，用 putInt64 保证类型正确
 *   - CourseName：旧结构冗余在 CourseSchedule 上，新结构统一由 CourseInformation 提供，丢弃
 *   - WeekRanges：逗号串搬进 WeekRangesStr 供界面展示，结构化周次另行写入 CourseWeek
 *
 * 失败时区分"孤儿行"：旧库可能存在 CourseInformation 已删、CourseSchedule 残留的行，
 * 新结构的复合外键会拒绝它们。为保住用户其余数据，这类行跳过而不是让整次搬运回滚。
 */
InsertRowResult InsertCourseScheduleRow(OH_Rdb_Store *store, const std::vector<std::string> &row)
{
    if (row.size() < 8) {
        return InsertRowResult::kError;
    }
    int dayInt = WeekDayToInt(row[3]);
    if (dayInt < 0) {
        // 已是整数（重复搬运 / 二次迁移场景），沿用原值
        dayInt = static_cast<int>(ToInt64(row[3], 0));
    }
    OH_VBucket *bucket = OH_Rdb_CreateValuesBucket();
    if (bucket == nullptr) {
        return InsertRowResult::kError;
    }
    bucket->putInt64(bucket, "TableId", ToInt64(row[0], 0));
    bucket->putText(bucket, "ClassId", row[1].c_str());
    bucket->putText(bucket, "ScheduleId", row[2].c_str());
    bucket->putInt64(bucket, "WeekDay", dayInt);
    bucket->putInt64(bucket, "StartSession", ToInt64(row[4], 0));
    bucket->putInt64(bucket, "EndSession", ToInt64(row[5], 0));
    bucket->putText(bucket, "Place", row[6].c_str());
    bucket->putText(bucket, "WeekRangesStr", row[7].c_str());
    int ret = OH_Rdb_Insert(store, "CourseSchedule", bucket);
    bucket->destroy(bucket);
    if (ret >= 0) {
        return InsertRowResult::kOk;
    }
    // 失败原因判定：父行是否存在
    std::string parentSql = "SELECT COUNT(*) FROM CourseInformation WHERE TableId=" +
                            std::to_string(ToInt64(row[0], 0)) +
                            " AND ClassId=" + SqlQuoteText(row[1]);
    int64_t parentCount = -1;
    int parentErr = 0;
    QueryScalarInt(store, parentSql.c_str(), &parentCount, &parentErr);
    if (parentCount == 0) {
        LogErr("legacyMigration",
               "skip orphan CourseSchedule row (no parent course) classId=" + row[1] +
                   " scheduleId=" + row[2],
               ret);
        return InsertRowResult::kOrphan;
    }
    LogErr("legacyMigration", "insert CourseSchedule failed", ret);
    return InsertRowResult::kError;
}

/**
 * 读取整张表的所有行为字符串矩阵（只用 ExecuteQuery，避免 Execute 的语句兼容性问题）。
 */
bool ReadAllRows(OH_Rdb_Store *store, const char *sql, std::vector<std::vector<std::string>> *out)
{
    OH_Cursor *cursor = OH_Rdb_ExecuteQuery(store, sql);
    if (cursor == nullptr) {
        LogErr("legacyMigration", std::string("query failed: ") + sql, -1);
        return false;
    }
    int columnCount = 0;
    cursor->getColumnCount(cursor, &columnCount);
    while (cursor->goToNextRow(cursor) == 0) {
        std::vector<std::string> row;
        for (int32_t i = 0; i < columnCount; i++) {
            std::string cell;
            // 必须按列类型分派：整数列用 getText 读会得到空串（见 ReadColumnAsText）
            if (!ReadColumnAsText(cursor, i, &cell)) {
                cell.clear();
            }
            row.push_back(cell);
        }
        out->push_back(row);
    }
    cursor->destroy(cursor);
    return true;
}

/**
 * 核对某张表的行数是否等于期望值。
 * 回灌类操作最容易"静默少写"，所以每一步都要对数，而不是只看 Insert 的返回值。
 */
bool VerifyRowCount(OH_Rdb_Store *store, const char *table, size_t expected)
{
    int64_t count = -1;
    int e = 0;
    QueryScalarInt(store, (std::string("SELECT COUNT(*) FROM ") + table).c_str(), &count, &e);
    if (count != static_cast<int64_t>(expected)) {
        LogErr("legacyMigration", std::string(table) + " row count mismatch: got " +
                                       std::to_string(count) + " want " + std::to_string(expected),
               -1);
        return false;
    }
    return true;
}

/**
 * 旧 CourseInformation 是否存在"结构病"：把 (TableId, ClassId) 只声明为 UNIQUE 而不是主键。
 *
 * 这为什么要单独修：新结构里 CourseSchedule / CourseWeek / Exams 都以
 * (TableId, ClassId) 作复合外键指向它。父键不是主键时，插子行会直接失败（真机实测 -1），
 * 表现为"课程表一条都写不进去"。所以必须连父表一起重建，不能只重建子表。
 */
bool CourseInfoNeedsRebuild(OH_Rdb_Store *store)
{
    if (!TableExists(store, "CourseInformation")) {
        return true; // 根本不存在，按新结构建
    }
    if (!TableHasColumn(store, "CourseInformation", "ClassId")) {
        return true;
    }
    // 有 PRIMARY KEY 关键字即视为新结构（新 DDL 里必然出现）
    if (!TableDdlContains(store, "CourseInformation", "PRIMARY KEY")) {
        LogInfo("legacyMigration", "CourseInformation has no PRIMARY KEY; parent key must be rebuilt");
        return true;
    }
    return false;
}

/** 读取旧 CourseInformation 内联的考试信息（ExamPlace / ExamDate），供生成 Exams 行 */
bool ReadLegacyExamRows(OH_Rdb_Store *store, std::vector<std::vector<std::string>> *out)
{
    if (!TableHasColumn(store, "CourseInformation", "ExamPlace")) {
        return true; // 已无内联列，无需拆
    }
    return ReadAllRows(store, "SELECT TableId, ClassId, ExamPlace, ExamDate FROM CourseInformation", out);
}

/**
 * 旧课程表数据搬运：把旧结构的三张表转成新结构，保留用户数据。
 *
 * 为什么必须有这一步：新结构把 WeekDay 从中文改为整数、把 WeekRanges
 * 逗号串拆进 CourseWeek 关联表、并给 CourseInformation 加了复合主键。
 * 若只是"检出漂移就重建表"，用户的课程表会被清空 —— 不可接受。
 *
 * 步骤（全部在一个事务内，失败则回滚）：
 *   1. ScheduleTableInformation: TableId 改名 ScheduleId（SQLite 3.25+ 支持 RENAME COLUMN）
 *   2. CourseSchedule 旧表改名留档 -> 按新 DDL 建表 -> 搬运并转换 -> 删除留档
 *   3. 由搬运后的 WeekRanges 串生成 CourseWeek 行
 *   4. CourseInformation: 把内联的 ExamPlace/ExamDate 拆到 Exams 表
 *
 * 返回 true 表示搬运成功或无需搬运。
 */
bool MigrateLegacySchedule(OH_Rdb_Store *store, int *errOut)
{
    // 旧结构特征：
    //   - ScheduleTableInformation 的主键列叫 TableId（新结构叫 ScheduleId）
    //   - CourseSchedule 有 WeekRanges 逗号串（新结构拆进 CourseWeek）
    //   - CourseInformation 的 (TableId, ClassId) 不是主键（新结构的子表外键依赖它）
    bool legacyScheduleTable = LegacyHasColumn(store, "ScheduleTableInformation", "TableId");
    bool legacyCourseSchedule = LegacyHasColumn(store, "CourseSchedule", "WeekRanges");
    bool infoNeedsRebuild = CourseInfoNeedsRebuild(store);
    if (!legacyScheduleTable && !legacyCourseSchedule && !infoNeedsRebuild) {
        return true; // 已是新结构
    }
    LogInfo("legacyMigration", "legacy schedule schema detected; migrating data");

    /*
     * 搬运的总原则（都由真机实测倒逼出来，别改顺序）：
     *
     * 1) 所有"读"必须在任何"写"之前完成。
     * 2) 整段搬运不开显式事务。
     *    实测：OH_Rdb_BeginTransaction 与 DDL 不能混用 —— 事务内由 OH_Rdb_Execute
     *    执行的 DROP/CREATE 对 OH_Rdb_Insert / OH_Rdb_ExecuteQuery 不可见，
     *    于是 Insert 仍按旧表结构校验（旧表 CourseName NOT NULL -> 恒返 -1），
     *    父表 SELECT COUNT(*) 也会给出错误的 0。
     * 3) 不依赖任何"重命名/派生"类语句（ALTER ... RENAME COLUMN / RENAME TO /
     *    CREATE TABLE AS SELECT / INSERT ... SELECT）：实测要么返错、要么返回成功却不生效。
     *    因此凡是形态要变的表，一律"读 -> 删 -> 按新 DDL 建 -> 逐行 Insert 回灌"。
     * 4) 删表按"先子后父"，建表按"先父后子"，避免外键级联把数据带走。
     * 5) 回灌前先把旧行写进 *_legacy 备份表，中途崩溃也留得下原样数据。
     */

    // ---- A. 读：把三张旧表的数据全部读进内存 ----
    std::vector<std::vector<std::string>> schedRows;   // ScheduleTableInformation
    std::vector<std::vector<std::string>> infoRows;    // CourseInformation（全部列）
    std::vector<std::vector<std::string>> csRows;      // CourseSchedule
    std::vector<std::vector<std::string>> examRows;    // 旧 CourseInformation 内联的考试信息

    bool hasLegacyExamColumns = TableHasColumn(store, "CourseInformation", "ExamPlace");

    if (legacyScheduleTable) {
        if (!ReadAllRows(store,
                         "SELECT TableId, TableName, StartDate FROM ScheduleTableInformation",
                         &schedRows)) {
            LogErr("legacyMigration", "read legacy ScheduleTableInformation failed", -1);
            *errOut = -1;
            return false;
        }
        LogInfo("legacyMigration", "legacy ScheduleTableInformation rows=" +
                                       std::to_string(schedRows.size()));
    }

    // CourseInformation 的列集合在不同历史版本里不一样，因此按"实际存在哪些列"动态取
    std::vector<std::string> infoPresent;
    std::string infoSelect;
    for (const char *col : whutdb::COURSE_INFO_COLUMNS) {
        if (TableHasColumn(store, "CourseInformation", col)) {
            if (!infoSelect.empty()) {
                infoSelect += ", ";
            }
            infoSelect += col;
            infoPresent.push_back(col);
        }
    }
    bool infoTableExists = TableExists(store, "CourseInformation");
    if (infoTableExists && !infoPresent.empty()) {
        if (!ReadAllRows(store, ("SELECT " + infoSelect + " FROM CourseInformation").c_str(),
                         &infoRows)) {
            LogErr("legacyMigration", "read legacy CourseInformation failed", -1);
            *errOut = -1;
            return false;
        }
        LogInfo("legacyMigration", "legacy CourseInformation rows=" + std::to_string(infoRows.size()) +
                                       " cols=" + std::to_string(infoPresent.size()));
    }
    if (hasLegacyExamColumns &&
        !ReadLegacyExamRows(store, &examRows)) {
        LogErr("legacyMigration", "read legacy exam columns failed", -1);
        *errOut = -1;
        return false;
    }

    if (legacyCourseSchedule) {
        int64_t preCount = -1;
        int preErr = 0;
        QueryScalarInt(store, "SELECT COUNT(*) FROM CourseSchedule", &preCount, &preErr);
        if (!ReadAllRows(store,
                         "SELECT TableId, ClassId, ScheduleId, WeekDay, StartSession, EndSession, "
                         "Place, WeekRanges FROM CourseSchedule",
                         &csRows)) {
            LogErr("legacyMigration", "read legacy CourseSchedule failed", -1);
            *errOut = -1;
            return false;
        }
        LogInfo("legacyMigration", "legacy CourseSchedule count=" + std::to_string(preCount) +
                                       " readRows=" + std::to_string(csRows.size()));
        if (preCount > 0 && csRows.empty()) {
            // 读到了不一致的快照：宁可中止也不能把用户数据擦掉
            LogErr("legacyMigration", "count/read mismatch; abort to protect user data", -1);
            *errOut = -1;
            return false;
        }
    }

    bool ok = true;

    // ---- B. 备份：把读到的旧行原样落到 *_legacy 表 ----
    // 先清掉早期版本中断搬运留下的中间表，否则本次备份会撞名
    for (const char *table : whutdb::STALE_MIGRATION_TABLES) {
        int se = 0;
        ExecSql(store, (std::string("DROP TABLE IF EXISTS ") + table).c_str(), &se);
    }

    if (ok && !schedRows.empty()) {
        ExecSql(store, "DROP TABLE IF EXISTS ScheduleTableInformation_legacy", errOut);
        if (!ExecSql(store, whutdb::SCHEDULE_TABLE_LEGACY_DDL, errOut)) {
            LogErr("legacyMigration", "create ScheduleTableInformation backup failed", *errOut);
            return false;
        }
        int64_t n = 0;
        for (const std::vector<std::string> &row : schedRows) {
            OH_VBucket *b = OH_Rdb_CreateValuesBucket();
            b->putText(b, "TableId", row.size() > 0 ? row[0].c_str() : "");
            b->putText(b, "TableName", row.size() > 1 ? row[1].c_str() : "");
            b->putText(b, "StartDate", row.size() > 2 ? row[2].c_str() : "");
            int ret = OH_Rdb_Insert(store, "ScheduleTableInformation_legacy", b);
            b->destroy(b);
            if (ret < 0) {
                LogErr("legacyMigration", "backup ScheduleTableInformation row failed", ret);
                return false;
            }
            n++;
        }
        if (!VerifyRowCount(store, "ScheduleTableInformation_legacy", schedRows.size())) {
            return false;
        }
        LogInfo("legacyMigration", "ScheduleTableInformation backup rows=" + std::to_string(n));
    }

    if (ok && infoTableExists && !infoPresent.empty()) {
        // 列名 -> 该行取值下标；备份表列序固定为 COURSE_INFO_COLUMNS
        std::vector<int> slotOf(whutdb::COURSE_INFO_COLUMN_COUNT, -1);
        for (size_t i = 0; i < infoPresent.size(); i++) {
            for (int c = 0; c < whutdb::COURSE_INFO_COLUMN_COUNT; c++) {
                if (infoPresent[i] == whutdb::COURSE_INFO_COLUMNS[c]) {
                    slotOf[c] = static_cast<int>(i);
                }
            }
        }
        ExecSql(store, "DROP TABLE IF EXISTS CourseInformation_legacy", errOut);
        if (!ExecSql(store, whutdb::COURSE_INFO_LEGACY_DDL, errOut)) {
            LogErr("legacyMigration", "create CourseInformation backup failed", *errOut);
            return false;
        }
        for (const std::vector<std::string> &row : infoRows) {
            OH_VBucket *b = OH_Rdb_CreateValuesBucket();
            for (int c = 0; c < whutdb::COURSE_INFO_COLUMN_COUNT; c++) {
                const char *col = whutdb::COURSE_INFO_COLUMNS[c];
                int idx = slotOf[c];
                if (idx < 0 || static_cast<size_t>(idx) >= row.size()) {
                    b->putNull(b, col);
                } else {
                    b->putText(b, col, row[static_cast<size_t>(idx)].c_str());
                }
            }
            int ret = OH_Rdb_Insert(store, "CourseInformation_legacy", b);
            b->destroy(b);
            if (ret < 0) {
                LogErr("legacyMigration", "backup CourseInformation row failed", ret);
                return false;
            }
        }
        if (!VerifyRowCount(store, "CourseInformation_legacy", infoRows.size())) {
            return false;
        }
        LogInfo("legacyMigration", "CourseInformation backup rows=" + std::to_string(infoRows.size()));
    }

    if (ok && !csRows.empty()) {
        ExecSql(store, "DROP TABLE IF EXISTS CourseSchedule_legacy", errOut);
        if (!ExecSql(store, whutdb::COURSE_SCHEDULE_LEGACY_DDL, errOut)) {
            LogErr("legacyMigration", "create CourseSchedule backup failed", *errOut);
            return false;
        }
        for (const std::vector<std::string> &row : csRows) {
            if (row.size() < 8) {
                continue;
            }
            OH_VBucket *b = OH_Rdb_CreateValuesBucket();
            b->putText(b, "TableId", row[0].c_str());
            b->putText(b, "ClassId", row[1].c_str());
            b->putText(b, "ScheduleId", row[2].c_str());
            b->putText(b, "WeekDay", row[3].c_str());
            b->putText(b, "StartSession", row[4].c_str());
            b->putText(b, "EndSession", row[5].c_str());
            b->putText(b, "Place", row[6].c_str());
            b->putText(b, "WeekRanges", row[7].c_str());
            int ret = OH_Rdb_Insert(store, "CourseSchedule_legacy", b);
            b->destroy(b);
            if (ret < 0) {
                LogErr("legacyMigration", "backup CourseSchedule row failed", ret);
                return false;
            }
        }
        if (!VerifyRowCount(store, "CourseSchedule_legacy", csRows.size())) {
            return false;
        }
        LogInfo("legacyMigration", "CourseSchedule backup rows=" + std::to_string(csRows.size()));
    }

    // ---- C. 删旧表（先子后父）----
    for (const char *table : whutdb::SCHEDULE_DROP_ORDER) {
        if (!ExecSql(store, (std::string("DROP TABLE IF EXISTS ") + table).c_str(), errOut)) {
            LogErr("legacyMigration", std::string("drop ") + table + " failed", *errOut);
            return false;
        }
    }

    // ---- D. 按新结构建表（先父后子）----
    for (const char *sql : whutdb::SCHEDULE_CREATE_ORDER) {
        if (!ExecSql(store, sql, errOut)) {
            LogErr("legacyMigration", "create business table failed", *errOut);
            return false;
        }
    }

    // ---- E. 回灌 1：ScheduleTableInformation（旧 TableId -> 新 ScheduleId）----
    for (const std::vector<std::string> &row : schedRows) {
        if (row.size() < 3) {
            continue;
        }
        OH_VBucket *b = OH_Rdb_CreateValuesBucket();
        // ScheduleId 是 INTEGER PRIMARY KEY AUTOINCREMENT，必须给整数
        b->putInt64(b, "ScheduleId", ToInt64(row[0], 0));
        b->putText(b, "TableName", row[1].c_str());
        b->putText(b, "StartDate", row[2].c_str());
        int ret = OH_Rdb_Insert(store, "ScheduleTableInformation", b);
        b->destroy(b);
        if (ret < 0) {
            LogErr("legacyMigration", "insert ScheduleTableInformation failed", ret);
            ok = false;
            break;
        }
    }
    if (ok && !VerifyRowCount(store, "ScheduleTableInformation", schedRows.size())) {
        ok = false;
    }

    // ---- F. 回灌 2：CourseInformation（父表先落，子表才有外键可依）----
    if (ok && !infoRows.empty()) {
        std::vector<int> slotOf(whutdb::COURSE_INFO_COLUMN_COUNT, -1);
        for (size_t i = 0; i < infoPresent.size(); i++) {
            for (int c = 0; c < whutdb::COURSE_INFO_COLUMN_COUNT; c++) {
                if (infoPresent[i] == whutdb::COURSE_INFO_COLUMNS[c]) {
                    slotOf[c] = static_cast<int>(i);
                }
            }
        }
        for (const std::vector<std::string> &row : infoRows) {
            OH_VBucket *b = OH_Rdb_CreateValuesBucket();
            for (int c = 0; c < whutdb::COURSE_INFO_COLUMN_COUNT; c++) {
                const char *col = whutdb::COURSE_INFO_COLUMNS[c];
                int idx = slotOf[c];
                std::string value;
                if (idx >= 0 && static_cast<size_t>(idx) < row.size()) {
                    value = row[static_cast<size_t>(idx)];
                }
                bool mustHave = (std::string(col) == "TableId") || (std::string(col) == "ClassId") ||
                                (std::string(col) == "CourseName") ||
                                (std::string(col) == "CourseNo") ||
                                (std::string(col) == "CourseSerialNum");
                if (mustHave) {
                    // 这几列在新结构里 NOT NULL 且参与主键：旧库缺列/缺值时补可用默认值
                    if (value.empty()) {
                        value = (std::string(col) == "TableId") ? "0" : "-";
                    }
                    if (std::string(col) == "TableId") {
                        b->putInt64(b, col, ToInt64(value, 0));
                    } else {
                        b->putText(b, col, value.c_str());
                    }
                } else if (value.empty()) {
                    b->putNull(b, col);
                } else {
                    b->putText(b, col, value.c_str());
                }
            }
            int ret = OH_Rdb_Insert(store, "CourseInformation", b);
            b->destroy(b);
            if (ret < 0) {
                LogErr("legacyMigration", "insert CourseInformation failed", ret);
                ok = false;
                break;
            }
        }
        if (ok && !VerifyRowCount(store, "CourseInformation", infoRows.size())) {
            ok = false;
        }
    }

    // ---- G. 回灌 3：CourseSchedule（WeekDay 中文 -> 整数，丢弃冗余 CourseName）----
    if (ok && legacyCourseSchedule) {
        int64_t migratedRows = 0;
        int64_t orphanRows = 0;
        std::vector<bool> rowKept(csRows.size(), false);
        for (size_t i = 0; i < csRows.size(); i++) {
            InsertRowResult r = InsertCourseScheduleRow(store, csRows[i]);
            if (r == InsertRowResult::kError) {
                ok = false;
                break;
            }
            if (r == InsertRowResult::kOrphan) {
                orphanRows++;
                continue; // 孤儿行不写入，也不为其展开周次（否则外键同样会拒绝）
            }
            rowKept[i] = true;
            migratedRows++;
        }
        if (ok) {
            int64_t finalRows = -1;
            int e = 0;
            QueryScalarInt(store, "SELECT COUNT(*) FROM CourseSchedule", &finalRows, &e);
            LogInfo("legacyMigration", "CourseSchedule migrated rows=" + std::to_string(migratedRows) +
                                           " orphan=" + std::to_string(orphanRows) +
                                           " final=" + std::to_string(finalRows));
            if (finalRows != migratedRows) {
                LogErr("legacyMigration", "row count lost during rebuild", -1);
                ok = false;
            }
        }
        if (ok) {
            // 由旧表的 WeekRanges 串生成 CourseWeek 行（逐个数字展开）
            for (size_t i = 0; i < csRows.size(); i++) {
                if (!rowKept[i]) {
                    continue;
                }
                const std::vector<std::string> &row = csRows[i];
                if (row.size() < 8) {
                    continue;
                }
                int64_t tableId = ToInt64(row[0], 0);
                std::vector<int64_t> weeks = ParseWeekRanges(row[7]);
                LogInfo("legacyMigration", "expand weeks classId=" + row[1] + " ranges=[" + row[7] +
                                               "] -> " + std::to_string(weeks.size()));
                for (int64_t week : weeks) {
                    OH_VBucket *bucket = OH_Rdb_CreateValuesBucket();
                    bucket->putInt64(bucket, "TableId", tableId);
                    bucket->putText(bucket, "ClassId", row[1].c_str());
                    bucket->putText(bucket, "ScheduleId", row[2].c_str());
                    bucket->putInt64(bucket, "Week", week);
                    int ret = OH_Rdb_Insert(store, "CourseWeek", bucket);
                    bucket->destroy(bucket);
                    if (ret < 0) {
                        LogErr("legacyMigration", "insert CourseWeek failed week=" + std::to_string(week),
                               ret);
                        ok = false;
                        break;
                    }
                }
                if (!ok) {
                    break;
                }
            }
        }
    }

    // ---- H. 回灌 4：旧 CourseInformation 内联的考试信息拆到 Exams ----
    if (ok && hasLegacyExamColumns) {
        // 同样不能用 INSERT OR IGNORE ... SELECT，改为读出来逐行 Insert
        for (const std::vector<std::string> &row : examRows) {
            if (row.size() < 4) {
                continue;
            }
            bool hasPlace = !row[2].empty();
            bool hasDate = !row[3].empty();
            if (!hasPlace && !hasDate) {
                continue; // 旧数据里考试信息为空，不生成空记录
            }
            OH_VBucket *bucket = OH_Rdb_CreateValuesBucket();
            bucket->putInt64(bucket, "TableId", ToInt64(row[0], 0));
            bucket->putText(bucket, "ClassId", row[1].c_str());
            bucket->putText(bucket, "ExamName", "考试");
            bucket->putText(bucket, "ExamPlace", row[2].c_str());
            bucket->putText(bucket, "ExamDate", row[3].c_str());
            int ret = OH_Rdb_Insert(store, "Exams", bucket);
            bucket->destroy(bucket);
            if (ret < 0) {
                LogErr("legacyMigration", "insert Exams failed", ret);
                ok = false;
                break;
            }
        }
    }

    if (!ok) {
        /*
         * 失败时不回滚（整段搬运本就没有显式事务），而是**保留备份表**：
         * CourseSchedule_legacy / CourseInformation_legacy 里是迁移前的原样数据，可人工恢复。
         * 这里刻意不自动"倒回去"，避免在未知的半成品状态下做二次破坏。
         */
        LogErr("legacyMigration",
               "migration failed; original rows preserved in *_legacy tables", *errOut);
        return false;
    }

    /*
     * 重建业务表会让挂在表上的索引一起消失（DROP TABLE 会删掉索引），
     * 因此这里把索引语句再跑一遍。都是 IF NOT EXISTS，幂等。
     */
    ApplyIndexes(store);

    // 成功：备份表已无用途，删掉（失败也无害，只是留了张多余的表）
    {
        int de = 0;
        ExecSql(store, "DROP TABLE IF EXISTS CourseSchedule_legacy", &de);
        ExecSql(store, "DROP TABLE IF EXISTS CourseInformation_legacy", &de);
    }
    LogInfo("legacyMigration", "legacy schedule data migrated successfully");
    return true;
}

/** 丢弃全部业务表（仅在检出结构漂移时调用，用于让新 schema 干净重建） */
bool DropAllBusinessTables(OH_Rdb_Store *store, int *errOut)
{
    // 顺序：先删子表再删父表，避免外键阻止删除
    static const char *DROP_SQL[] = {
        "DROP TABLE IF EXISTS CourseWeek",
        "DROP TABLE IF EXISTS Exams",
        "DROP TABLE IF EXISTS CourseSchedule",
        "DROP TABLE IF EXISTS CourseInformation",
        "DROP TABLE IF EXISTS ScheduleTableInformation",
        "DROP TABLE IF EXISTS DormitoryLocation",
        "DROP TABLE IF EXISTS Meters",
        "DROP TABLE IF EXISTS Rooms",
        "DROP TABLE IF EXISTS Floors",
        "DROP TABLE IF EXISTS Buildings",
        "DROP TABLE IF EXISTS Areas",
    };
    for (const char *sql : DROP_SQL) {
        if (!ExecSql(store, sql, errOut)) {
            return false;
        }
    }
    return true;
}

/** 应用幂等的结构修正语句。失败是正常情况（列已正确），故不视为错误。 */
void ApplySchemaPatches(OH_Rdb_Store *store)
{
    for (const char *sql : whutdb::SCHEMA_PATCH_SQL) {
        int ret = OH_Rdb_Execute(store, sql);
        if (ret != 0) {
            // 预期内的失败：说明该修正已应用过或列名本就正确
            LogInfo("schemaPatch", std::string("skipped (already applied): ") + sql);
        } else {
            LogInfo("schemaPatch", std::string("applied: ") + sql);
        }
    }
}

/**
 * 版本迁移。按 store 的 version 决定执行哪些 DDL。
 * 版本号由 OH_Rdb_SetVersion 持久化，是后续结构变更的唯一依据
 * （原实现靠手工注释掉 drop table，会直接丢用户数据）。
 */
bool Migrate(OH_Rdb_Store *store, int *errOut)
{
    int version = 0;
    int ret = OH_Rdb_GetVersion(store, &version);
    if (ret != 0) {
        LogErr("getVersion", "OH_Rdb_GetVersion", ret);
        *errOut = ret;
        return false;
    }
    LogInfo("migrate", "current schema version=" + std::to_string(version));

    bool needsBuild = false;

    /*
     * 优先尝试"保留数据的搬运"。
     * 旧结构（TableId / WeekRanges 逗号串）必须先搬数据再谈结构升级，
     * 否则下面的 DropAllBusinessTables 会直接清空用户的课程表。
     */
    if (!MigrateLegacySchedule(store, errOut)) {
        LogErr("migrate", "legacy schedule migration failed", *errOut);
        return false;
    }

    if (version >= whutdb::SCHEMA_VERSION) {
        // 版本号已是最新，但仍需确认结构真的对得上（防漂移）
        if (SchemaMatchesExpectation(store)) {
            // 结构基本一致：只跑幂等修正，保留用户数据
            ApplySchemaPatches(store);
            ApplyIndexes(store);
            return true;
        }
        LogInfo("migrate", "schema drift detected at current version; rebuilding tables");
        if (!DropAllBusinessTables(store, errOut)) {
            return false;
        }
        needsBuild = true;
    }

    // v0 -> v1：建立全部业务表
    if (needsBuild || version < 1) {
        for (const char *sql : whutdb::SCHEMA_V1_SQL) {
            if (!ExecSql(store, sql, errOut)) {
                return false;
            }
        }
    }
    // 后续版本在此追加：if (version < 2) { ... }

    // 索引统一在这里补一遍（建表、漂移重建、旧数据搬运之后都可能缺失）
    ApplyIndexes(store);

    ret = OH_Rdb_SetVersion(store, whutdb::SCHEMA_VERSION);
    if (ret != 0) {
        LogErr("setVersion", "OH_Rdb_SetVersion", ret);
        *errOut = ret;
        return false;
    }
    LogInfo("migrate", "schema upgraded to version=" + std::to_string(whutdb::SCHEMA_VERSION));
    return true;
}

/** 向 CourseWeek 插一批周次，用于验证关联表与复合外键 */
bool InsertCourseWeeks(OH_Rdb_Store *store, int64_t tableId, const char *classId,
                       const char *scheduleId, const std::vector<int64_t> &weeks)
{
    bool allOk = true;
    for (int64_t week : weeks) {
        OH_VBucket *bucket = OH_Rdb_CreateValuesBucket();
        if (bucket == nullptr) {
            return false;
        }
        bucket->putInt64(bucket, "TableId", tableId);
        bucket->putText(bucket, "ClassId", classId);
        bucket->putText(bucket, "ScheduleId", scheduleId);
        bucket->putInt64(bucket, "Week", week);
        int ret = OH_Rdb_Insert(store, "CourseWeek", bucket);
        bucket->destroy(bucket);
        // 逐条记录，便于定位是哪一条失败、错误码是什么
        LogInfo("insertCourseWeek", "week=" + std::to_string(week) +
                                        " ret=" + std::to_string(ret));
        if (ret < 0) {
            allOk = false;
        }
    }
    return allOk;
}

// ------------------------------------------------ 泛型查询/执行（消除游标泄漏）

/**
 * 读取一行中第 columnIndex 列的值并写入 JS 对象。
 *
 * 类型策略：以 getColumnType 的结果为准，避免依赖各 getter 的隐式转换。
 * - NULL      -> null
 * - INTEGER   -> number
 * - REAL      -> number
 * - TEXT      -> string
 * - BLOB/其他 -> string（以文本降级，避免向 JS 传二进制造成未定义行为）
 */
void ReadColumnToJs(napi_env env, OH_Cursor *cursor, int32_t columnIndex,
                    const std::string &name, napi_value row)
{
    bool isNull = false;
    if (cursor->isNull(cursor, columnIndex, &isNull) == 0 && isNull) {
        napi_value nullValue = nullptr;
        napi_get_null(env, &nullValue);
        napi_set_named_property(env, row, name.c_str(), nullValue);
        return;
    }

    OH_ColumnType type = TYPE_NULL;
    cursor->getColumnType(cursor, columnIndex, &type);

    napi_value value = nullptr;
    switch (type) {
        case TYPE_INT64: {
            int64_t intValue = 0;
            if (cursor->getInt64(cursor, columnIndex, &intValue) == 0) {
                napi_create_int64(env, intValue, &value);
            }
            break;
        }
        case TYPE_REAL: {
            double realValue = 0;
            if (cursor->getReal(cursor, columnIndex, &realValue) == 0) {
                napi_create_double(env, realValue, &value);
            }
            break;
        }
        case TYPE_TEXT:
        case TYPE_BLOB:
        default: {
            std::string text;
            if (ReadTextColumn(cursor, columnIndex, &text)) {
                napi_create_string_utf8(env, text.c_str(), text.length(), &value);
            }
            break;
        }
    }

    if (value == nullptr) {
        napi_get_null(env, &value);
    }
    napi_set_named_property(env, row, name.c_str(), value);
}

/**
 * 把游标整体读成 JS 对象数组。
 *
 * 这是消除游标泄漏的关键：ResultSet 不跨越 NAPI 边界，
 * 在原生侧一次性读完并 destroy，上层拿到的是普通 JS 数组。
 * 原实现把 ResultSet 返回给业务层且从不 close()，句柄必然泄漏。
 */
napi_value CursorToJsArray(napi_env env, OH_Cursor *cursor)
{
    napi_value array = nullptr;
    napi_create_array(env, &array);

    int columnCount = 0;
    if (cursor->getColumnCount(cursor, &columnCount) != 0 || columnCount <= 0) {
        return array;
    }

    // 列名只取一次，避免循环内反复分配
    std::vector<std::string> names;
    names.reserve(static_cast<size_t>(columnCount));
    for (int32_t i = 0; i < columnCount; i++) {
        char nameBuf[256] = {0};
        if (cursor->getColumnName(cursor, i, nameBuf, sizeof(nameBuf)) == 0) {
            names.emplace_back(nameBuf);
        } else {
            names.emplace_back("col" + std::to_string(i));
        }
    }

    uint32_t rowIndex = 0;
    while (cursor->goToNextRow(cursor) == 0) {
        napi_value row = nullptr;
        napi_create_object(env, &row);
        for (int32_t i = 0; i < columnCount; i++) {
            ReadColumnToJs(env, cursor, i, names[static_cast<size_t>(i)], row);
        }
        napi_set_element(env, array, rowIndex, row);
        rowIndex++;
    }
    return array;
}

/** 执行一条语句并返回受影响行数 */
int ExecScalar(OH_Rdb_Store *store, const char *sql)
{
    return OH_Rdb_Execute(store, sql);
}
} // namespace

// ================================================================ NAPI 导出

/**
 * 打开业务库并完成迁移。
 * dbOpen(databaseDir) => { storeOpened, schemaVersion, foreignKeyEnabled, lastError }
 */
static napi_value DbOpen(napi_env env, napi_callback_info info)
{
    std::string dbDir;
    bool argOk = GetStringArg(env, info, 0, &dbDir);

    bool storeOpened = false;
    bool foreignKeyEnabled = false;
    int64_t schemaVersion = -1;
    int lastError = 0;

    OH_Rdb_Store *store = nullptr;
    if (argOk) {
        store = OpenStore(dbDir, whutdb::BUSINESS_DB_NAME, &lastError);
        storeOpened = (store != nullptr);
    } else {
        lastError = -1;
    }

    if (storeOpened) {
        int err = 0;
        // PRAGMA 必须先于任何外键相关操作
        if (!ApplyPragmas(store, &err)) {
            lastError = err;
        }
        if (!Migrate(store, &err)) {
            lastError = err;
        }
        int64_t fk = 0;
        if (QueryScalarInt(store, "PRAGMA foreign_keys", &fk, &err)) {
            foreignKeyEnabled = (fk == 1);
        }
        int version = 0;
        if (OH_Rdb_GetVersion(store, &version) == 0) {
            schemaVersion = version;
        }
        // 保留 store 供后续查询/执行复用；重复调用则替换旧句柄。
        // 不再每次调用都关闭并重开 —— 重开意味着重复跑迁移与 PRAGMA。
        if (g_store != nullptr && g_store != store) {
            OH_Rdb_CloseStore(g_store);
        }
        g_store = store;
    } else if (argOk) {
        LogErr("dbOpen", "OH_Rdb_CreateOrOpen returned null; dbDir=" + dbDir, lastError);
    }

    napi_value result = nullptr;
    napi_create_object(env, &result);
    napi_set_named_property(env, result, "storeOpened", MakeBool(env, storeOpened));
    napi_set_named_property(env, result, "foreignKeyEnabled", MakeBool(env, foreignKeyEnabled));
    napi_set_named_property(env, result, "schemaVersion", MakeInt(env, schemaVersion));
    napi_set_named_property(env, result, "lastError", MakeInt(env, lastError));
    return result;
}

/**
 * 阶段 0 验证：schema 结构、周次等值查询、复合外键强制、NULL 边界。
 *
 * dbVerifyPhase0(databaseDir) => {
 *   tables, indexes, schemaVersion, foreignKeyEnabled,
 *   week1And11Separated, compositeFkEnforced,
 *   nullPrimaryKeyAccepted, compositeFkNullBypassed, lastError
 * }
 *
 * 关于 NULL 边界的说明：SQLite 复合外键含 NULL 时不强制（SQL 标准 MATCH SIMPLE
 * 语义）。本函数把这个行为显式验证并上报，避免团队误以为"外键已开"就覆盖了
 * 所有脏数据场景——非空组合才是被约束的部分。
 */
static napi_value DbVerifyPhase0(napi_env env, napi_callback_info info)
{
    std::string dbDir;
    bool argOk = GetStringArg(env, info, 0, &dbDir);

    int64_t tables = -1;
    int64_t indexes = -1;
    int64_t schemaVersion = -1;
    bool foreignKeyEnabled = false;
    bool week1And11Separated = false;
    bool compositeFkEnforced = false;
    bool nullKeyRejectedByNotNull = false;
    bool compositeFkNullBypassed = false;
    int lastError = 0;

    OH_Rdb_Store *store = nullptr;
    if (argOk) {
        // 每次运行用全新库，彻底排除历史残留数据导致假通过
        std::string verifyDbName = "phase0_verify_" + std::to_string(static_cast<long long>(time(nullptr))) + ".db";
        store = OpenStore(dbDir, verifyDbName.c_str(), &lastError);
        LogInfo("dbVerifyPhase0", "verify db=" + verifyDbName);
    } else {
        lastError = -1;
    }

    if (store != nullptr) {
        int err = 0;

        // 1) 先读一次默认值（新连接应为 0，证明该设置确实是连接级）
        int64_t fkBefore = -1;
        QueryScalarInt(store, "PRAGMA foreign_keys", &fkBefore, &err);

        // 2) 设置后立刻读；并在后续不同操作后复读，确认是否稳定
        ApplyPragmas(store, &err);
        int64_t fkAfter = -1;
        QueryScalarInt(store, "PRAGMA foreign_keys", &fkAfter, &err);
        LogInfo("verify", "PRAGMA foreign_keys: before=" + std::to_string(fkBefore) +
                              " afterSet=" + std::to_string(fkAfter));

        Migrate(store, &err);

        int64_t fkLater = -1;
        QueryScalarInt(store, "PRAGMA foreign_keys", &fkLater, &err);
        // 注意：本读数在 HarmonyOS RDB 上恒为 0，且具有误导性 ——
        // RDB 内部在连接池/独立连接上维护该设置，OH_Rdb_ExecuteQuery 读到的
        // 并非执行约束的那个连接。真实结论只以"孤儿插入是否被拒"为准
        // （见下方 compositeFkEnforced 的行为证据）。
        foreignKeyEnabled = (fkLater == 1);
        LogInfo("verify", "PRAGMA foreign_keys after migrate=" + std::to_string(fkLater) +
                              " (读数不可作准，仅记录)");

        int version = 0;
        if (OH_Rdb_GetVersion(store, &version) == 0) {
            schemaVersion = version;
        }

        QueryScalarInt(store,
                       "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
                       &tables, &err);
        QueryScalarInt(store,
                       "SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'",
                       &indexes, &err);

        // ---- 准备测试数据：一门课，第 1 周与第 11 周 ----
        const int64_t tableId = 1;
        const char *classId = "C1";

        OH_VBucket *schBucket = OH_Rdb_CreateValuesBucket();
        schBucket->putText(schBucket, "TableName", "verify");
        schBucket->putText(schBucket, "StartDate", "2026-02-23");
        OH_Rdb_Insert(store, "ScheduleTableInformation", schBucket);
        schBucket->destroy(schBucket);

        OH_VBucket *cInfo = OH_Rdb_CreateValuesBucket();
        cInfo->putInt64(cInfo, "TableId", tableId);
        cInfo->putText(cInfo, "ClassId", classId);
        cInfo->putText(cInfo, "CourseName", "verify-course");
        cInfo->putText(cInfo, "CourseNo", "N1");
        cInfo->putText(cInfo, "CourseSerialNum", "1");
        OH_Rdb_Insert(store, "CourseInformation", cInfo);
        cInfo->destroy(cInfo);

        OH_VBucket *cSch = OH_Rdb_CreateValuesBucket();
        cSch->putInt64(cSch, "TableId", tableId);
        cSch->putText(cSch, "ClassId", classId);
        cSch->putText(cSch, "ScheduleId", "0");
        cSch->putInt64(cSch, "WeekDay", 4);
        cSch->putInt64(cSch, "StartSession", 1);
        cSch->putInt64(cSch, "EndSession", 2);
        cSch->putText(cSch, "Place", "教1-101");
        OH_Rdb_Insert(store, "CourseSchedule", cSch);
        cSch->destroy(cSch);

        // 关键：只给第 1 周和第 11 周。旧实现查第 1 周会误命中第 11 周。
        InsertCourseWeeks(store, tableId, classId, "0", {1, 11});

        int64_t week1Count = 0;
        int64_t week11Count = 0;
        int64_t weekTotalBefore = 0;
        QueryScalarInt(store, "SELECT COUNT(*) FROM CourseWeek WHERE TableId=1 AND Week=1",
                       &week1Count, &err);
        QueryScalarInt(store, "SELECT COUNT(*) FROM CourseWeek WHERE TableId=1 AND Week=11",
                       &week11Count, &err);
        QueryScalarInt(store, "SELECT COUNT(*) FROM CourseWeek", &weekTotalBefore, &err);
        // 严格断言：初始恰好 2 行，且各自命中 1 行 —— 避免历史残留造成假通过
        week1And11Separated = (week1Count == 1 && week11Count == 1 && weekTotalBefore == 2);
        LogInfo("verify", "week1=" + std::to_string(week1Count) +
                              " week11=" + std::to_string(week11Count) +
                              " total=" + std::to_string(weekTotalBefore));

        // ---- 外键是否真正生效：决定性实验 ----
        // 不依赖 PRAGMA 读数，直接尝试插入父行不存在的孤儿行。
        // 被拒绝 => 外键生效；被接受 => 外键未生效。
        // 用 OH_Rdb_Insert（已验证可用）而非裸 SQL，避免受 OH_Rdb_Execute 限制干扰。
        {
            OH_VBucket *orphan = OH_Rdb_CreateValuesBucket();
            orphan->putInt64(orphan, "TableId", 999);
            orphan->putText(orphan, "ClassId", "orphan");
            orphan->putText(orphan, "ScheduleId", "nope");
            orphan->putInt64(orphan, "Week", 7);
            int ret = OH_Rdb_Insert(store, "CourseWeek", orphan);
            orphan->destroy(orphan);
            compositeFkEnforced = (ret < 0);
            LogInfo("verify", "orphan CourseWeek insert via ValueBucket returned " + std::to_string(ret));
        }

        // 对照：父行存在时必须能插入成功（排除"外键过严把合法数据也拦掉"）
        {
            OH_VBucket *valid = OH_Rdb_CreateValuesBucket();
            valid->putInt64(valid, "TableId", tableId);
            valid->putText(valid, "ClassId", classId);
            valid->putText(valid, "ScheduleId", "0");
            valid->putInt64(valid, "Week", 3);
            int ret = OH_Rdb_Insert(store, "CourseWeek", valid);
            valid->destroy(valid);
            LogInfo("verify", "valid CourseWeek insert returned " + std::to_string(ret));
        }

        // ---- 边界 A：主键组成列尝试写 NULL，应由列级 NOT NULL 直接拒绝 ----
        {
            OH_VBucket *nullPk = OH_Rdb_CreateValuesBucket();
            nullPk->putInt64(nullPk, "TableId", tableId);
            nullPk->putText(nullPk, "ClassId", "GHOST");
            nullPk->putNull(nullPk, "ScheduleId");
            nullPk->putInt64(nullPk, "WeekDay", 1);
            nullPk->putInt64(nullPk, "StartSession", 1);
            nullPk->putInt64(nullPk, "EndSession", 1);
            int ret = OH_Rdb_Insert(store, "CourseSchedule", nullPk);
            nullPk->destroy(nullPk);
            // 期望被拒绝：ScheduleId 声明了 NOT NULL（主键列在 SQLite 中亦可为 NULL，
            // 必须靠 NOT NULL 拦截，否则主键可被绕过）
            nullKeyRejectedByNotNull = (ret < 0);
            LogInfo("verify", "NULL pk component insert returned " + std::to_string(ret));
        }

        // ---- 边界 B：复合外键含 NULL 时是否绕过约束（SQL 标准 MATCH SIMPLE）----
        // 用 CourseWeek 的多列外键 (TableId, ClassId, ScheduleId) 演示：
        // ClassId 写 NULL 时，即使 TableId/ScheduleId 指向不存在的父行也可能不被拒。
        {
            OH_VBucket *nullFk = OH_Rdb_CreateValuesBucket();
            nullFk->putInt64(nullFk, "TableId", 999);
            nullFk->putNull(nullFk, "ClassId");
            nullFk->putText(nullFk, "ScheduleId", "nope");
            nullFk->putInt64(nullFk, "Week", 5);
            int ret = OH_Rdb_Insert(store, "CourseWeek", nullFk);
            nullFk->destroy(nullFk);
            compositeFkNullBypassed = (ret >= 0);
            LogInfo("verify", "CourseWeek insert with NULL ClassId returned " + std::to_string(ret));
        }

        OH_Rdb_CloseStore(store);
    } else if (argOk) {
        LogErr("dbVerifyPhase0", "open verify store failed; dbDir=" + dbDir, lastError);
    }

    napi_value result = nullptr;
    napi_create_object(env, &result);
    napi_set_named_property(env, result, "tables", MakeInt(env, tables));
    napi_set_named_property(env, result, "indexes", MakeInt(env, indexes));
    napi_set_named_property(env, result, "schemaVersion", MakeInt(env, schemaVersion));
    napi_set_named_property(env, result, "foreignKeyEnabled", MakeBool(env, foreignKeyEnabled));
    napi_set_named_property(env, result, "week1And11Separated", MakeBool(env, week1And11Separated));
    napi_set_named_property(env, result, "compositeFkEnforced", MakeBool(env, compositeFkEnforced));
    napi_set_named_property(env, result, "nullKeyRejectedByNotNull",
                            MakeBool(env, nullKeyRejectedByNotNull));
    napi_set_named_property(env, result, "compositeFkNullBypassed", MakeBool(env, compositeFkNullBypassed));
    napi_set_named_property(env, result, "lastError", MakeInt(env, lastError));
    return result;
}

/**
 * 泛型查询：dbQuery(sql) => Array<Record<string, unknown>>
 *
 * 必须在 dbOpen 成功之后调用。返回普通 JS 数组 —— 游标在原生侧读完即销毁，
 * 不跨越 NAPI 边界，从结构上杜绝原实现的 ResultSet 泄漏。
 */
static napi_value DbQuery(napi_env env, napi_callback_info info)
{
    std::string sql;
    if (!GetStringArg(env, info, 0, &sql)) {
        return nullptr;
    }
    if (g_store == nullptr) {
        LogErr("dbQuery", "store not opened; call dbOpen first", -1);
        napi_value empty = nullptr;
        napi_create_array(env, &empty);
        return empty;
    }

    OH_Cursor *cursor = OH_Rdb_ExecuteQuery(g_store, sql.c_str());
    if (cursor == nullptr) {
        LogErr("dbQuery", "OH_Rdb_ExecuteQuery returned null: " + sql, -1);
        napi_value empty = nullptr;
        napi_create_array(env, &empty);
        return empty;
    }
    napi_value array = CursorToJsArray(env, cursor);
    cursor->destroy(cursor);
    return array;
}

/**
 * 泛型执行：dbExec(sql) => 受影响行数，失败返回负数。
 */
static napi_value DbExec(napi_env env, napi_callback_info info)
{
    std::string sql;
    if (!GetStringArg(env, info, 0, &sql)) {
        return MakeInt(env, -1);
    }
    if (g_store == nullptr) {
        LogErr("dbExec", "store not opened; call dbOpen first", -1);
        return MakeInt(env, -1);
    }
    int ret = OH_Rdb_Execute(g_store, sql.c_str());
    if (ret < 0) {
        LogErr("dbExec", "OH_Rdb_Execute failed: " + sql, ret);
    }
    return MakeInt(env, ret);
}

/**
 * 事务控制：dbBeginTransaction / dbCommit / dbRollback => 0 表示成功。
 * 原实现完全没有跨语句事务，多表写入中途失败会留下半个课表。
 */
static napi_value DbBeginTransaction(napi_env env, napi_callback_info info)
{
    if (g_store == nullptr) {
        return MakeInt(env, -1);
    }
    int ret = OH_Rdb_BeginTransaction(g_store);
    if (ret != 0) {
        LogErr("dbBeginTransaction", "OH_Rdb_BeginTransaction", ret);
    }
    return MakeInt(env, ret);
}

static napi_value DbCommit(napi_env env, napi_callback_info info)
{
    if (g_store == nullptr) {
        return MakeInt(env, -1);
    }
    int ret = OH_Rdb_Commit(g_store);
    if (ret != 0) {
        LogErr("dbCommit", "OH_Rdb_Commit", ret);
    }
    return MakeInt(env, ret);
}

static napi_value DbRollback(napi_env env, napi_callback_info info)
{
    if (g_store == nullptr) {
        return MakeInt(env, -1);
    }
    int ret = OH_Rdb_RollBack(g_store);
    if (ret != 0) {
        LogErr("dbRollback", "OH_Rdb_RollBack", ret);
    }
    return MakeInt(env, ret);
}

/**
 * 漂移自愈探针（诊断用）：
 *  1. 把 CourseSchedule 改造成"旧结构"（缺 WeekRangesStr 列），模拟历史库；
 *  2. 重新走一次 Migrate，应检出漂移并重建；
 *  3. 复查 CourseWeek 是否恢复存在。
 * 返回 { driftDetected, healed, lastError }
 */
static napi_value DbDriftProbe(napi_env env, napi_callback_info info)
{
    std::string dbDir;
    bool argOk = GetStringArg(env, info, 0, &dbDir);

    bool driftDetected = false;
    bool healed = false;
    int lastError = 0;

    OH_Rdb_Store *store = nullptr;
    if (argOk) {
        store = OpenStore(dbDir, "drift_probe.db", &lastError);
    } else {
        lastError = -1;
    }

    if (store != nullptr) {
        int err = 0;
        ApplyPragmas(store, &err);
        Migrate(store, &err); // 先建立正常结构

        // 1) 人为制造漂移：删掉 WeekRangesStr 列（SQLite 3.35+ 支持 DROP COLUMN）
        if (!TableHasColumn(store, "CourseSchedule", "WeekRangesStr")) {
            LogErr("driftProbe", "precondition failed: WeekRangesStr already missing", -1);
            lastError = -1;
        } else {
            ExecSql(store, "ALTER TABLE CourseSchedule DROP COLUMN WeekRangesStr", &err);
            driftDetected = !TableHasColumn(store, "CourseSchedule", "WeekRangesStr");
            LogInfo("driftProbe", std::string("drift injected=") + (driftDetected ? "yes" : "no"));
        }

        // 2) 重跑迁移：应检出漂移并重建
        if (driftDetected) {
            int migrateErr = 0;
            bool migrateOk = Migrate(store, &migrateErr);
            bool haveWeekTable = false;
            int64_t count = 0;
            QueryScalarInt(store,
                           "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='CourseWeek'",
                           &count, &err);
            haveWeekTable = (count == 1);
            bool columnBack = TableHasColumn(store, "CourseSchedule", "WeekRangesStr");
            healed = migrateOk && haveWeekTable && columnBack;
            if (!healed) {
                lastError = migrateErr != 0 ? migrateErr : -1;
            }
            LogInfo("driftProbe", std::string("after migrate: migrateOk=") + (migrateOk ? "1" : "0") +
                                      " courseWeek=" + (haveWeekTable ? "1" : "0") +
                                      " columnRestored=" + (columnBack ? "1" : "0"));
        }

        OH_Rdb_CloseStore(store);
    }

    napi_value result = nullptr;
    napi_create_object(env, &result);
    napi_set_named_property(env, result, "driftDetected", MakeBool(env, driftDetected));
    napi_set_named_property(env, result, "healed", MakeBool(env, healed));
    napi_set_named_property(env, result, "lastError", MakeInt(env, lastError));
    return result;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"dbOpen", nullptr, DbOpen, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"dbVerifyPhase0", nullptr, DbVerifyPhase0, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"dbQuery", nullptr, DbQuery, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"dbExec", nullptr, DbExec, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"dbBeginTransaction", nullptr, DbBeginTransaction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"dbCommit", nullptr, DbCommit, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"dbRollback", nullptr, DbRollback, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"dbDriftProbe", nullptr, DbDriftProbe, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module whutdbModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "whutdb",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterWhutdbModule(void)
{
    napi_module_register(&whutdbModule);
}
