import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import  LazyDataSource  from './LazyDataSource';
import { DormitoryLocation, Area, Building, Floor, Meter, Room } from '@ohos/datastore/src/main/ets/model/DormitoryLocation';
import { ArrayList, JSON } from '@kit.ArkTS';

const TAG = '[DBUtil]'

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'ApplicationDB.db',
  securityLevel: relationalStore.SecurityLevel.S3
};

const AREAS_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS Areas (' +
  'AreaId VARCHAR(255) PRIMARY KEY, ' +
  'Area VARCHAR(255) NOT NULL);';

const BUILDINGS_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS Buildings (\n' +
  '    BuildingId VARCHAR(255) PRIMARY KEY,\n' +
  '    Building VARCHAR(255) NOT NULL,\n' +
  '    AreaId VARCHAR(255),\n' +
  '    FOREIGN KEY (AreaId) REFERENCES Areas(AreaId)\n' +
  ');';

const FLOOR_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS Floors (\n' +
  '    FloorId VARCHAR(255) NOT NULL,\n' +
  '    Floor VARCHAR(255) NOT NULL,\n' +
  '    BuildingId VARCHAR(255),' +
  '    UNIQUE(FloorId, BuildingId),\n' +
  '    FOREIGN KEY (BuildingId) REFERENCES Buildings(BuildingId)\n' +
  ');';

const ROOM_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS Rooms (\n' +
  '    RoomId VARCHAR(255) PRIMARY KEY,\n' +
  '    Room VARCHAR(255) NOT NULL,\n' +
  '    BuildingId VARCHAR(255),' +
  '    FloorId VARCHAR(255),' +
  '    UNIQUE(RoomId, FloorId, BuildingId),\n' +
  '    FOREIGN KEY (BuildingId) REFERENCES Buildings(BuildingId)\n' +
  ');'

const METER_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS Meters (' +
  '    MeterId VARCHAR(255) NOT NULL, ' +
  '    RoomId VARCHAR(255) PRIMARY KEY,' +
  '    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId)' +
  ');'

const DORM_LOCATION_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS DormitoryLocation (\n' +
  '    id INTEGER PRIMARY KEY AUTOINCREMENT,\n' +
  '    Area VARCHAR(255) NOT NULL,\n' +
  '    AreaId VARCHAR(255) NOT NULL,\n' +
  '    Building VARCHAR(255) NOT NULL,\n' +
  '    BuildingId VARCHAR(255) NOT NULL,\n' +
  '    Floor VARCHAR(255) NOT NULL,\n' +
  '    FloorId VARCHAR(255) NOT NULL,\n' +
  '    Room VARCHAR(255) NOT NULL,\n' +
  '    RoomId VARCHAR(255) NOT NULL,\n' +
  '    ElectricFee VARCHAR(255) NOT NULL,\n' +
  '    RemainingElectric VARCHAR(255) NOT NULL,' +
  '    isStar INTEGER DEFAULT 0,' +
  '    MeterId VARCHAR(255),' +
  '    UNIQUE (AreaId, BuildingId, FloorId, RoomId),' +
  '    FOREIGN KEY (AreaId) REFERENCES Areas(AreaId),\n' +
  '    FOREIGN KEY (BuildingId) REFERENCES Buildings(BuildingId),\n' +
  '    FOREIGN KEY (FloorId) REFERENCES Floors(FloorId),\n' +
  '    FOREIGN KEY (RoomId) REFERENCES Rooms(RoomId)' +
  ');'

export class DBUtil {
  public static instance: DBUtil;
  private store?: relationalStore.RdbStore;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  constructor() {
    this.initDB(STORE_CONFIG);
  }

  public static getInstance() {
    if (!DBUtil.instance) {
      DBUtil.instance = new DBUtil();
    }
    return DBUtil.instance;
  }

  initDB(storeConfig: relationalStore.StoreConfig) {
    relationalStore.getRdbStore(this.context, storeConfig).then((store: relationalStore.RdbStore) => {
      this.store = store;
      try {
        // this.executeMySql('drop table DormitoryLocation;')
        this.executeMySql(AREAS_TABLE_SQL);
        this.executeMySql(BUILDINGS_TABLE_SQL);
        this.executeMySql(FLOOR_TABLE_SQL);
        this.executeMySql(ROOM_TABLE_SQL);
        this.executeMySql(METER_TABLE_SQL);
        this.executeMySql(DORM_LOCATION_TABLE_SQL);
      } catch (err) {
        console.error(TAG, `Init failed, code is ${err.code},message is ${err.message}`)
      }
    })

    console.info(TAG, 'DB Init');
  }

  executeMySql(sql: string) {
    try {
      this.store?.executeSync(sql);
    } catch (err) {
      console.error(TAG, sql + `failed, code is ${err.code},message is ${err.message}`)
    }

  }

  queryDormitoryHistory(): LazyDataSource<DormitoryLocation> {
    let res: LazyDataSource<DormitoryLocation> = new LazyDataSource();
    this.store?.querySql('select Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId, isStar from DormitoryLocation ORDER BY isStar DESC, id DESC;',
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

  queryDormitoryElectricityFeeAndRemainPower(dormitoryLocation: DormitoryLocation): string[] | void {
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
        (this.store as relationalStore.RdbStore).querySync(predicates, ['ElectricFee', 'RemainingElectric'])
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

  updateDormitoryStarStatus(dormitoryLocation: DormitoryLocation): void {
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
      let rows: number = (this.store as relationalStore.RdbStore).updateSync(valueBucket, predicates,
        relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
      console.info(TAG, `Updated row count: ${rows}`);
    } catch (err) {
      console.error(TAG, `Update failed, code is ${err.code},message is ${err.message}`)
    }
  }

  deleteDormitory(dormitoryLocation: DormitoryLocation): void {
    let predicates = new relationalStore.RdbPredicates('DormitoryLocation');
    predicates.equalTo('AreaId', dormitoryLocation.AreaId)
      .and()
      .equalTo('BuildingId', dormitoryLocation.BuildingId)
      .and()
      .equalTo('FloorId', dormitoryLocation.FloorId)
      .and()
      .equalTo('RoomId', dormitoryLocation.RoomId)
    try {
      let rows: Number = (this.store as relationalStore.RdbStore).deleteSync(predicates)
      console.info(TAG, `Delete row count: ${rows}`);
    } catch (err) {
      console.error(TAG, `Delete failed, code is ${err.code},message is ${err.message}`)
    }
  }

  insertArea(area: Area) {
    let valueBucket: ValuesBucket = {
      'Area': area.area,
      'AreaId': area.areaId
    }
    try {
      let rows: number = (this.store as relationalStore.RdbStore).insertSync('Areas', valueBucket,
        relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
      console.info(TAG, `Insert row at: ${rows}`)
    } catch (err) {
      console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
    }
  }

  insertBuilding(building: Building, area: Area) {
    let valueBucket: ValuesBucket = {
      'Building': building.Building,
      'BuildingId': building.BuildingId,
      'AreaId': area.areaId
    }
    try {
      let rows: number = (this.store as relationalStore.RdbStore).insertSync('Buildings', valueBucket,
        relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
      console.info(TAG, `Insert row at: ${rows}`)
    } catch (err) {
      console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
    }
  }

  insertFloor(floor: Floor, building: Building) {
    let valueBucket: ValuesBucket = {
      'Floor': floor.Floor,
      'FloorId': floor.FloorId,
      'BuildingId': building.BuildingId
    }
    try {
      let rows: number = (this.store as relationalStore.RdbStore).insertSync('Floors', valueBucket,
        relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
      console.info(TAG, `Insert row at: ${rows}`)
    } catch (err) {
      console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
    }
  }

  insertRoom(room: Room, building: Building, floor: Floor) {
    let valueBucket: ValuesBucket = {
      'Room': room.Room,
      'RoomId': room.RoomId,
      'BuildingId': building.BuildingId,
      'FloorId': floor.FloorId
    }
    try {
      let rows: number = (this.store as relationalStore.RdbStore).insertSync('Rooms', valueBucket,
        relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
      console.info(TAG, `Insert row at: ${rows}`)
    } catch (err) {
      console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
    }
  }

  insertMeter(meter: Meter, room: Room) {
    let valueBucket: ValuesBucket = {
      'MeterId': meter.MeterId,
      'RoomId': room.RoomId
    };
    console.debug(TAG, JSON.stringify(valueBucket))
    try {
      let rows: number = (this.store as relationalStore.RdbStore).insertSync('Meters', valueBucket,
        relationalStore.ConflictResolution.ON_CONFLICT_ABORT);
      console.info(TAG, `Insert row at: ${rows}`)
    } catch (err) {
      console.error(TAG, `Insert failed, code is ${err.code},message is ${err.message}`)
    }
  }

  insertOrUpdateDormitory(dormitoryLocation: DormitoryLocation, electricFee: string, remainPower: string) {
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
      let rows: number = (this.store as relationalStore.RdbStore).updateSync(valueBucket, predicates,
        relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
      console.info(TAG, `Update row at: ${rows}`)
      if (rows <= 0) {
        try {
          let rows: number = (this.store as relationalStore.RdbStore).insertSync('DormitoryLocation', valueBucket,
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

  queryAreaListDataBase(): ArrayList<Area> | undefined {
    try {
      let resultSet = this.store?.querySqlSync('select * from Areas;');
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

  queryBuildingListDataBase(area: Area): ArrayList<Building> | undefined {
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('Buildings');
      predicates.equalTo('AreaId', area.areaId);
      let resultSet = this.store?.querySync(predicates, ['Building', 'BuildingId'])
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

  queryFloorListDataBase(building: Building): ArrayList<Floor> | undefined {
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('Floors');
      predicates.equalTo('BuildingId', building.BuildingId);
      let resultSet = this.store?.querySync(predicates, ['Floor', 'FloorId']);
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

  queryRoomListDataBase(building: Building, floor: Floor): ArrayList<Room> | undefined {
    try {
      let predication: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('Rooms');
      predication.equalTo('BuildingId', building.BuildingId).and().equalTo('FloorId', floor.FloorId);
      let resultSet = this.store?.querySync(predication, ['Room', 'RoomId']);
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
}