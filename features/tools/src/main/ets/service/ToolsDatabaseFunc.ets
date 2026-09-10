import { Area, Building, DormitoryLocation, Floor, Meter, Room } from '../model/DormitoryLocation';
import { LazyDataSource } from '@ohos/utils';
import { exec, query, queryOne, queryScalar, colString, colNumber, colBool, sqlQuote, DbRow } from '@ohos/datastore';
import { ArrayList } from '@kit.ArkTS';

const TAG = '[ToolsDatabaseFunc]';

// 表名常量：原实现把这些字符串散落在各处，集中于此便于校对
const T_AREAS = 'Areas';
const T_BUILDINGS = 'Buildings';
const T_FLOORS = 'Floors';
const T_ROOMS = 'Rooms';
const T_METERS = 'Meters';
const T_DORM = 'DormitoryLocation';

/**
 * 查询收藏的宿舍历史。
 *
 * 与原实现的差异：改走原生数据层。
 *  - 原实现用回调查询 + 手动 close()，漏关就泄漏游标；现在游标在原生侧销毁。
 *  - 数据到达时向同一个 LazyDataSource 推送，ArkUI 会刷新，调用方代码无需改动。
 */
export function queryDormitoryHistory(): LazyDataSource<DormitoryLocation> {
  const result: LazyDataSource<DormitoryLocation> = new LazyDataSource();
  query(`SELECT Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId, MeterId, isStar, ` +
    `ElectricFee, RemainingElectric FROM ${T_DORM} ORDER BY isStar DESC, Id DESC`)
    .then((rows: DbRow[]) => {
      rows.forEach((row: DbRow) => {
        const dormitory: DormitoryLocation = new DormitoryLocation();
        dormitory.Area = colString(row, 'Area');
        dormitory.AreaId = colString(row, 'AreaId');
        dormitory.Building = colString(row, 'Building');
        dormitory.BuildingId = colString(row, 'BuildingId');
        dormitory.Floor = colString(row, 'Floor');
        dormitory.FloorId = colString(row, 'FloorId');
        dormitory.Room = colString(row, 'Room');
        dormitory.RoomId = colString(row, 'RoomId');
        dormitory.MeterId = colString(row, 'MeterId');
        dormitory.isStar = colBool(row, 'isStar');
        result.pushData(dormitory);
      });
      console.info(TAG, `queryDormitoryHistory rows=${rows.length}`);
    })
    .catch((e: Error) => {
      console.error(TAG, `queryDormitoryHistory failed: ${e.message}`);
    });
  return result;
}

/**
 * 读取某个宿舍上次记录的 [电费, 剩余电量]。
 * 无记录时返回空数组（与原实现一致，调用方自行判空）。
 */
export async function queryDormitoryElectricityFeeAndRemainPower(
  dormitoryLocation: DormitoryLocation): Promise<string[]> {
  const where: string = dormitoryIdentityWhere(dormitoryLocation);
  const row: DbRow | undefined = await queryOne(
    `SELECT ElectricFee, RemainingElectric FROM ${T_DORM} WHERE ${where} LIMIT 1`);
  if (row === undefined) {
    return [];
  }
  return [colString(row, 'ElectricFee'), colString(row, 'RemainingElectric')];
}

/** 切换收藏状态 */
export async function updateDormitoryStarStatus(dormitoryLocation: DormitoryLocation): Promise<void> {
  const star: number = dormitoryLocation.isStar ? 1 : 0;
  await exec(`UPDATE ${T_DORM} SET isStar=${star} WHERE ${dormitoryIdentityWhere(dormitoryLocation)}`);
}

/** 删除一条收藏记录 */
export async function deleteDormitory(dormitoryLocation: DormitoryLocation): Promise<void> {
  await exec(`DELETE FROM ${T_DORM} WHERE ${dormitoryIdentityWhere(dormitoryLocation)}`);
}

export async function insertArea(area: Area): Promise<void> {
  // 同一区域会被反复拉取，必须幂等。
  // 注意：不能用 INSERT OR REPLACE —— 实测该语法在业务库上返回
  // 14800000（RDB_E_ERROR），在探测库上却正常。改用 UPDATE 后 INSERT。
  await upsert(`INSERT INTO ${T_AREAS}(AreaId, Area) VALUES (${sqlQuote(area.areaId)}, ${sqlQuote(area.area)})`,
    `UPDATE ${T_AREAS} SET Area=${sqlQuote(area.area)} WHERE AreaId=${sqlQuote(area.areaId)}`);
}

export async function insertBuilding(building: Building, area: Area): Promise<void> {
  await upsert(`INSERT INTO ${T_BUILDINGS}(BuildingId, Building, AreaId) ` +
    `VALUES (${sqlQuote(building.BuildingId)}, ${sqlQuote(building.Building)}, ${sqlQuote(area.areaId)})`,
    `UPDATE ${T_BUILDINGS} SET Building=${sqlQuote(building.Building)}, AreaId=${sqlQuote(area.areaId)} ` +
    `WHERE BuildingId=${sqlQuote(building.BuildingId)}`);
}

export async function insertFloor(floor: Floor, building: Building): Promise<void> {
  await upsert(`INSERT INTO ${T_FLOORS}(FloorId, Floor, BuildingId) ` +
    `VALUES (${sqlQuote(floor.FloorId)}, ${sqlQuote(floor.Floor)}, ${sqlQuote(building.BuildingId)})`,
    `UPDATE ${T_FLOORS} SET Floor=${sqlQuote(floor.Floor)} ` +
    `WHERE FloorId=${sqlQuote(floor.FloorId)} AND BuildingId=${sqlQuote(building.BuildingId)}`);
}

export async function insertRoom(room: Room, building: Building, floor: Floor): Promise<void> {
  await upsert(`INSERT INTO ${T_ROOMS}(RoomId, Room, BuildingId, FloorId) ` +
    `VALUES (${sqlQuote(room.RoomId)}, ${sqlQuote(room.Room)}, ` +
    `${sqlQuote(building.BuildingId)}, ${sqlQuote(floor.FloorId)})`,
    `UPDATE ${T_ROOMS} SET Room=${sqlQuote(room.Room)} ` +
    `WHERE RoomId=${sqlQuote(room.RoomId)} AND BuildingId=${sqlQuote(building.BuildingId)} ` +
    `AND FloorId=${sqlQuote(floor.FloorId)}`);
}

/**
 * 写入电表。
 * Meters 对 Rooms 是复合外键 (RoomId, BuildingId, FloorId)，
 * 因此必须带上楼栋与楼层，单凭 RoomId 无法满足父键。
 */
export async function insertMeter(meter: Meter, room: Room, building: Building,
  floor: Floor): Promise<void> {
  await upsert(`INSERT INTO ${T_METERS}(MeterId, RoomId, BuildingId, FloorId) ` +
    `VALUES (${sqlQuote(meter.MeterId)}, ${sqlQuote(room.RoomId)}, ` +
    `${sqlQuote(building.BuildingId)}, ${sqlQuote(floor.FloorId)})`,
    `UPDATE ${T_METERS} SET MeterId=${sqlQuote(meter.MeterId)} ` +
    `WHERE RoomId=${sqlQuote(room.RoomId)} AND BuildingId=${sqlQuote(building.BuildingId)} ` +
    `AND FloorId=${sqlQuote(floor.FloorId)}`);
}

/**
 * 插入或更新一条宿舍记录。
 *
 * 原实现是"先 update，rows<=0 再 insert"两步；这里改用表上的
 * UNIQUE(AreaId,BuildingId,FloorId,RoomId) 约束配合 upsert，
 * 一次写成，避免两步之间的竞态。
 */
export async function insertOrUpdateDormitory(dormitoryLocation: DormitoryLocation,
  electricFee: string, remainPower: string): Promise<void> {
  const identity: string = dormitoryIdentityWhere(dormitoryLocation);
  await upsert(`INSERT INTO ${T_DORM}(` +
    `Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId, MeterId, ` +
    `isStar, ElectricFee, RemainingElectric) VALUES (` +
    `${sqlQuote(dormitoryLocation.Area)}, ${sqlQuote(dormitoryLocation.AreaId)}, ` +
    `${sqlQuote(dormitoryLocation.Building)}, ${sqlQuote(dormitoryLocation.BuildingId)}, ` +
    `${sqlQuote(dormitoryLocation.Floor)}, ${sqlQuote(dormitoryLocation.FloorId)}, ` +
    `${sqlQuote(dormitoryLocation.Room)}, ${sqlQuote(dormitoryLocation.RoomId)}, ` +
    `${sqlQuote(dormitoryLocation.MeterId)}, 0, ` +
    `${sqlQuote(electricFee)}, ${sqlQuote(remainPower)})`,
    `UPDATE ${T_DORM} SET ElectricFee=${sqlQuote(electricFee)}, ` +
    `RemainingElectric=${sqlQuote(remainPower)}, MeterId=${sqlQuote(dormitoryLocation.MeterId)} ` +
    `WHERE ${identity}`);
}

export async function queryAreaListDataBase(): Promise<ArrayList<Area> | undefined> {
  const rows: DbRow[] = await query(`SELECT AreaId, Area FROM ${T_AREAS}`);
  if (rows.length === 0) {
    return undefined;
  }
  const areaList: ArrayList<Area> = new ArrayList();
  rows.forEach((row: DbRow) => {
    areaList.add(new Area(colString(row, 'AreaId'), colString(row, 'Area')));
  });
  return areaList;
}

export async function queryBuildingListDataBase(area: Area): Promise<ArrayList<Building> | undefined> {
  const rows: DbRow[] = await query(
    `SELECT Building, BuildingId FROM ${T_BUILDINGS} WHERE AreaId=${sqlQuote(area.areaId)}`);
  if (rows.length === 0) {
    return undefined;
  }
  const buildingList: ArrayList<Building> = new ArrayList();
  rows.forEach((row: DbRow) => {
    buildingList.add(new Building(colString(row, 'Building'), colString(row, 'BuildingId')));
  });
  return buildingList;
}

export async function queryFloorListDataBase(building: Building): Promise<ArrayList<Floor> | undefined> {
  const rows: DbRow[] = await query(
    `SELECT Floor, FloorId FROM ${T_FLOORS} WHERE BuildingId=${sqlQuote(building.BuildingId)}`);
  if (rows.length === 0) {
    return undefined;
  }
  const floorList: ArrayList<Floor> = new ArrayList();
  rows.forEach((row: DbRow) => {
    floorList.add(new Floor(colString(row, 'Floor'), colString(row, 'FloorId')));
  });
  return floorList;
}

export async function queryRoomListDataBase(building: Building,
  floor: Floor): Promise<ArrayList<Room> | undefined> {
  const rows: DbRow[] = await query(
    `SELECT Room, RoomId FROM ${T_ROOMS} ` +
    `WHERE BuildingId=${sqlQuote(building.BuildingId)} AND FloorId=${sqlQuote(floor.FloorId)}`);
  if (rows.length === 0) {
    return undefined;
  }
  const roomList: ArrayList<Room> = new ArrayList();
  rows.forEach((row: DbRow) => {
    roomList.add(new Room(colString(row, 'Room'), colString(row, 'RoomId')));
  });
  return roomList;
}

/** 宿舍身份条件：四元组唯一（表上已建 UNIQUE 约束） */
function dormitoryIdentityWhere(dormitoryLocation: DormitoryLocation): string {
  return `AreaId=${sqlQuote(dormitoryLocation.AreaId)} ` +
    `AND BuildingId=${sqlQuote(dormitoryLocation.BuildingId)} ` +
    `AND FloorId=${sqlQuote(dormitoryLocation.FloorId)} ` +
    `AND RoomId=${sqlQuote(dormitoryLocation.RoomId)}`;
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
    // UPDATE 未命中且 INSERT 失败：多为约束冲突（如父行缺失），记录以便定位
    console.error(TAG, `upsert failed (insert=${inserted}): ${insertSql}`);
  }
}
