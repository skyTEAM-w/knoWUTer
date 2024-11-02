import { relationalStore } from "@kit.ArkData";
import { common } from "@kit.AbilityKit";
import LazyDataSource from "../model/LazyDataSource";
import { DormitoryLocation } from "../../model/DormitoryLocation";

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'ApplicationDB.db',
  securityLevel: relationalStore.SecurityLevel.S3
};

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
  '    UNIQUE (AreaId, BuildingId, FloorId, RoomId)' +
  ');'

export class DBUtil {
  private store?: relationalStore.RdbStore;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  public static instance: DBUtil;

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
      this.store?.executeSql(DORM_LOCATION_TABLE_SQL);
    })

    console.info('DB Init');
  }

  creatTable(sql: string) {
    this.store?.executeSql(sql);
  }

  queryDormitoryHistory(): LazyDataSource<DormitoryLocation> {
    let res: LazyDataSource<DormitoryLocation> = new LazyDataSource();
    this.store?.querySql('select Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId from DormitoryLocation ORDER BY id DESC;', (err, resultSet) => {
      if (err) {
        console.error(`Query failed, code is ${err.code},message is ${err.message}`);
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
        res.pushData(dormLocation);
      }
      resultSet.close();
    })
    return res;
  }

  queryDormitoryElectricityFee(dormitoryLocation: DormitoryLocation): string | void {
    let predicates = new relationalStore.RdbPredicates('DormitoryLocation');
    let res: string = '';
    predicates.equalTo('AreaId', dormitoryLocation.AreaId).and().equalTo('BuildingId', dormitoryLocation.BuildingId)
      .and().equalTo('FloorId', dormitoryLocation.FloorId).and().equalTo('RoomId', dormitoryLocation.RoomId)

    try {
      let resultSet: relationalStore.ResultSet = (this.store as relationalStore.RdbStore).querySync(predicates, ['ElectricFee'])
      console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
      while (resultSet.goToLastRow()) {
        res = resultSet.getString(resultSet.getColumnIndex('ElectricFee'));
        console.info(res);
        break;
      }
      resultSet.close();
      return res.replace(/^"+|"+$/g, '');
    } catch (err) {
      console.error(`Query failed, code is ${err.code},message is ${err.message}`);
      return;
    }

  }

}