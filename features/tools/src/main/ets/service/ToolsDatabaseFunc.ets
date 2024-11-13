import { Area, Building, DormitoryLocation, Floor, Meter, Room } from '../model/DormitoryLocation';
import { LazyDataSource } from '@ohos/utils';
import { DBUtil } from '@ohos/datastore';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { ArrayList } from '@kit.ArkTS';

const TAG = '[ToolsDatabaseFunc]'

export function queryDormitoryHistory(): LazyDataSource<DormitoryLocation> {
  let res: LazyDataSource<DormitoryLocation> = new LazyDataSource();
  DBUtil.getInstance()
    .getStore()?.querySql('select Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId, isStar from DormitoryLocation ORDER BY isStar DESC, id DESC;',
    (err, resultSet) => {
      if (err) {
        console.error(TAG, `Query failed, code is ${err.code},message is ${err.message}`);
        return;
      }
      console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
      while (resultSet.goToNextRow()) {
        let dormLocation: DormitoryLocation = new DormitoryLocation();
        dormLocation.Area = resultSet.getString(resultSet.getColumnIndex('Area'));
        dormLocation.AreaId = resultSet.getString(resultSet.getColumnIndex('AreaId'));
        dormLocation.Building = resultSet.getString(resultSet.getColumnIndex('Building'));
        dormLocation.BuildingId = resultSet.getString(resultSet.getColumnIndex('BuildingId'));
        dormLocation.Floor = resultSet.getString(resultSet.getColumnIndex('Floor'));
        dormLocation.FloorId = resultSet.getString(resultSet.getColumnIndex('FloorId'));
        dormLocation.Room = resultSet.getString(resultSet.getColumnIndex('Room'));
        dormLocation.RoomId = resultSet.getString(resultSet.getColumnIndex('RoomId'));
        dormLocation.isStar = resultSet.getLong(resultSet.getColumnIndex('isStar')) === 0 ? false : true;
        res.pushData(dormLocation);
      }
      resultSet.close();
    })
  return res;
}

export function queryDormitoryElectricityFeeAndRemainPower(dormitoryLocation: DormitoryLocation): string[] | void {
  let predicates = new relationalStore.RdbPredicates('DormitoryLocation');
  let res: string[] = [];
  predicates.equalTo('AreaId', dormitoryLocation.AreaId)
    .and()
    .equalTo('BuildingId', dormitoryLocation.BuildingId)
    .and()
    .equalTo('FloorId', dormitoryLocation.FloorId)
    .and()
    .equalTo('RoomId', dormitoryLocation.RoomId)

  try {
    let resultSet: relationalStore.ResultSet =
      (DBUtil.getInstance().getStore() as relationalStore.RdbStore).querySync(predicates,
        ['ElectricFee', 'RemainingElectric'])
    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}, row count: ${resultSet.rowCount}}`);
    while (resultSet.goToLastRow()) {
      res.push(resultSet.getString(resultSet.getColumnIndex('ElectricFee')));
      res.push(resultSet.getString(resultSet.getColumnIndex('RemainingElectric')));
      console.info(TAG, res);
      break;
    }
    resultSet.close();
    return res
  } catch (err) {
    console.error(TAG, `Query failed, code is ${err.code},message is ${err.message}`);
    return;
  }

}

export function updateDormitoryStarStatus(dormitoryLocation: DormitoryLocation): void {
  let valueBucket: relationalStore.ValuesBucket = {
    'isStar': dormitoryLocation.isStar ? 1 : 0
  }
  let predicates = new relationalStore.RdbPredicates('DormitoryLocation');
  predicates.equalTo('AreaId', dormitoryLocation.AreaId)
    .and()
    .equalTo('BuildingId', dormitoryLocation.BuildingId)
    .and()
    .equalTo('FloorId', dormitoryLocation.FloorId)
    .and()
    .equalTo('RoomId', dormitoryLocation.RoomId)
  try {
    let rows: number = (DBUtil.getInstance().getStore() as relationalStore.RdbStore).updateSync(valueBucket, predicates,
      relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
    console.info(TAG, `Updated row count: ${rows}`);
  } catch (err) {
    console.error(TAG, `Update failed, code is ${err.code},message is ${err.message}`)
  }
}

export function deleteDormitory(dormitoryLocation: DormitoryLocation): void {
  let predicates = new relationalStore.RdbPredicates('DormitoryLocation');
  predicates.equalTo('AreaId', dormitoryLocation.AreaId)
    .and()
    .equalTo('BuildingId', dormitoryLocation.BuildingId)
    .and()
    .equalTo('FloorId', dormitoryLocation.FloorId)
    .and()
    .equalTo('RoomId', dormitoryLocation.RoomId)
  try {
    let rows: Number = (DBUtil.getInstance().getStore() as relationalStore.RdbStore).deleteSync(predicates)
    console.info(TAG, `Delete row count: ${rows}`);
  } catch (err) {
    console.error(TAG, `Delete failed, code is ${err.code},message is ${err.message}`)
  }
}

export function insertArea(area: Area) {
  let valueBucket: ValuesBucket = {
    'Area': area.area,
    'AreaId': area.areaId
  }
  try {
    let rows: number = (DBUtil.getInstance().getStore() as relationalStore.RdbStore).insertSync('Areas', valueBucket,
      relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
    console.info(TAG, `Insert row at: ${rows}`)
  } catch (err) {
    console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
  }
}

export function insertBuilding(building: Building, area: Area) {
  let valueBucket: ValuesBucket = {
    'Building': building.Building,
    'BuildingId': building.BuildingId,
    'AreaId': area.areaId
  }
  try {
    let rows: number =
      (DBUtil.getInstance().getStore() as relationalStore.RdbStore).insertSync('Buildings', valueBucket,
        relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
    console.info(TAG, `Insert row at: ${rows}`)
  } catch (err) {
    console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
  }
}

export function insertFloor(floor: Floor, building: Building) {
  let valueBucket: ValuesBucket = {
    'Floor': floor.Floor,
    'FloorId': floor.FloorId,
    'BuildingId': building.BuildingId
  }
  try {
    let rows: number = (DBUtil.getInstance().getStore() as relationalStore.RdbStore).insertSync('Floors', valueBucket,
      relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
    console.info(TAG, `Insert row at: ${rows}`)
  } catch (err) {
    console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
  }
}

export function insertRoom(room: Room, building: Building, floor: Floor) {
  let valueBucket: ValuesBucket = {
    'Room': room.Room,
    'RoomId': room.RoomId,
    'BuildingId': building.BuildingId,
    'FloorId': floor.FloorId
  }
  try {
    let rows: number = (DBUtil.getInstance().getStore() as relationalStore.RdbStore).insertSync('Rooms', valueBucket,
      relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
    console.info(TAG, `Insert row at: ${rows}`)
  } catch (err) {
    console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
  }
}

export function insertMeter(meter: Meter, room: Room) {
  let valueBucket: ValuesBucket = {
    'MeterId': meter.MeterId,
    'RoomId': room.RoomId
  };
  console.debug(TAG, JSON.stringify(valueBucket))
  try {
    let rows: number = (DBUtil.getInstance().getStore() as relationalStore.RdbStore).insertSync('Meters', valueBucket,
      relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
    console.info(TAG, `Insert row at: ${rows}`)
  } catch (err) {
    console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
  }
}

export function insertOrUpdateDormitory(dormitoryLocation: DormitoryLocation, electricFee: string,
  remainPower: string) {
  let valueBucket: ValuesBucket = {
    'Area': dormitoryLocation.Area,
    'AreaId': dormitoryLocation.AreaId,
    'Building': dormitoryLocation.Building,
    'BuildingId': dormitoryLocation.BuildingId,
    'Floor': dormitoryLocation.Floor,
    'FloorId': dormitoryLocation.FloorId,
    'Room': dormitoryLocation.Room,
    'RoomId': dormitoryLocation.RoomId,
    'MeterId': dormitoryLocation.MeterId,
    'ElectricFee': electricFee,
    'RemainingElectric': remainPower
  }
  console.debug(TAG, JSON.stringify(valueBucket))
  let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('DormitoryLocation');
  predicates.equalTo('AreaId', dormitoryLocation.AreaId)
    .and()
    .equalTo('BuildingId', dormitoryLocation.BuildingId)
    .and()
    .equalTo('FloorId', dormitoryLocation.FloorId)
    .and()
    .equalTo('RoomId', dormitoryLocation.RoomId);
  try {
    let rows: number = (DBUtil.getInstance().getStore() as relationalStore.RdbStore).updateSync(valueBucket, predicates,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
    console.info(TAG, `Update row at: ${rows}`)
    if (rows <= 0) {
      try {
        let rows: number =
          (DBUtil.getInstance().getStore() as relationalStore.RdbStore).insertSync('DormitoryLocation', valueBucket,
            relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
        console.info(TAG, `Insert row at: ${rows}`)
      } catch (err) {
        console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
      }
    }
  } catch (err) {
    console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
  }

}

export function queryAreaListDataBase(): ArrayList<Area> | undefined {
  try {
    let resultSet = DBUtil.getInstance().getStore()?.querySqlSync('select * from Areas;');
    if (resultSet && resultSet.rowCount > 0) {
      console.info(TAG, `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
      let areaList: ArrayList<Area> = new ArrayList();
      while (resultSet.goToNextRow()) {
        areaList.add(new Area(resultSet.getString(resultSet.getColumnIndex('AreaId')),
          resultSet.getString(resultSet.getColumnIndex('Area'))))
      }
      console.info(TAG, JSON.stringify(areaList));
      resultSet.close();
      return areaList;
    }
    return undefined

  } catch (err) {
    console.error(TAG, `Query AreaList in DB failed, code is ${err.code},message is ${err.message}`);
    return undefined;
  }
}

export function queryBuildingListDataBase(area: Area): ArrayList<Building> | undefined {
  try {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('Buildings');
    predicates.equalTo('AreaId', area.areaId);
    let resultSet = DBUtil.getInstance().getStore()?.querySync(predicates, ['Building', 'BuildingId'])
    if (resultSet && resultSet.rowCount != 0) {
      console.info(TAG, `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
      let buildingList: ArrayList<Building> = new ArrayList();
      while (resultSet.goToNextRow()) {
        buildingList.add(new Building(resultSet.getString(resultSet.getColumnIndex('Building')),
          resultSet.getString(resultSet.getColumnIndex('BuildingId'))));
      }
      console.info(TAG, JSON.stringify(buildingList));
      resultSet.close();
      return buildingList;
    }
    return undefined
  } catch (error) {
    console.error(TAG, `Query BuildingList in DB failed, code is ${error.code},message is ${error.message}`);
    return undefined;
  }
}

export function queryFloorListDataBase(building: Building): ArrayList<Floor> | undefined {
  try {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('Floors');
    predicates.equalTo('BuildingId', building.BuildingId);
    let resultSet = DBUtil.getInstance().getStore()?.querySync(predicates, ['Floor', 'FloorId']);
    if (resultSet && resultSet.rowCount != 0) {
      console.info(TAG, `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
      let floorList: ArrayList<Floor> = new ArrayList();
      while (resultSet.goToNextRow()) {
        floorList.add(new Floor(resultSet.getString(resultSet.getColumnIndex('Floor')),
          resultSet.getString(resultSet.getColumnIndex('FloorId'))))
      }
      console.info(TAG, JSON.stringify(floorList));
      resultSet.close();
      return floorList;
    }
    return undefined;
  } catch (error) {
    console.error(TAG, `Query FloorList in DB failed, code is ${error.code},message is ${error.message}`);
    return undefined;
  }
}

export function queryRoomListDataBase(building: Building, floor: Floor): ArrayList<Room> | undefined {
  try {
    let predication: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('Rooms');
    predication.equalTo('BuildingId', building.BuildingId).and().equalTo('FloorId', floor.FloorId);
    let resultSet = DBUtil.getInstance().getStore()?.querySync(predication, ['Room', 'RoomId']);
    if (resultSet && resultSet.rowCount != 0) {
      console.info(TAG, `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
      let roomList: ArrayList<Room> = new ArrayList();
      while (resultSet.goToNextRow()) {
        roomList.add(new Room(resultSet.getString(resultSet.getColumnIndex('Room')),
          resultSet.getString(resultSet.getColumnIndex('RoomId'))))
      }
      console.info(TAG, JSON.stringify(roomList));
      resultSet.close();
      return roomList;
    }
    return undefined;
  } catch (error) {
    console.error(TAG, `Query RoomList in DB failed, code is ${error.code},message is ${error.message}`);
    return undefined;
  }
}