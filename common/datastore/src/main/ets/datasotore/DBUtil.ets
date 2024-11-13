import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

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

const SCHEDULE_TABLE_INFO_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS ScheduleTableInformation (' +
  '    TableId INTEGER PRIMARY KEY AUTOINCREMENT,' +
  '    TableName VARCHAR(255) NOT NULL,' +
  '    StartDate TEXT NOT NULL' +
  ');';

const COURSE_INFO_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS CourseInformation (' +
  '    TableId INTEGER NOT NULL,' +
  '    ClassId VARCHAR(255) NOT NULL,\n' +
  '    CourseName VARCHAR(255) NOT NULL,\n' +
  '    Credit VARCHAR(255) DEFAULT NULL,\n' +
  '    CreditHours VARCHAR(255) DEFAULT NULL,\n' +
  '    ExamPlace VARCHAR(255) DEFAULT NULL,\n' +
  '    ExamDate VARCHAR(255) DEFAULT NULL,\n' +
  '    TeachingProcess VARCHAR(255) DEFAULT NULL,\n' +
  '    ClassDateAndPlace TEXT DEFAULT NULL,\n' +
  '    CourseNo VARCHAR(255) NOT NULL,\n' +
  '    CourseSerialNum VARCHAR(255) NOT NULL,' +
  '    Color TEXT DEFAULT NULL,' +
  '    UNIQUE (TableId, ClassId),' +
  '    FOREIGN KEY (TableId) REFERENCES ScheduleTableInformation(TableId)' +
  ');';

const COURSE_SCHEDULE_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS CourseSchedule (' +
  '   TableId INTEGER NOT NULL,' +
  '   ClassId VARCHAR(255) NOT NULL,' +
  '   CourseName VARCHAR(255) NOT NULL,' +
  '   ScheduleId VARCHAR(255) NOT NULL,' +
  '   WeekRanges VARCHAR(255) NOT NULL,' +
  '   WeekRangesStr VARCHAR(255) NOT NULL,' +
  '   WeekDay TEXT NOT NULL,' +
  '   StartSession INTEGER NOT NULL,' +
  '   EndSession INTEGER NOT NULL,' +
  '   Place TEXT,' +
  '   UNIQUE(TableId, ClassId, ScheduleId),' +
  '   FOREIGN KEY (TableId) REFERENCES ScheduleTableInformation(TableId),' +
  '   FOREIGN KEY (ClassId) REFERENCES CourseInformation(ClassId)' +
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

  public getStore() {
    return this.store;
  }

  initDB(storeConfig: relationalStore.StoreConfig) {
    relationalStore.getRdbStore(this.context, storeConfig).then((store: relationalStore.RdbStore) => {
      this.store = store;
      try {
        // this.executeMySql('drop table CourseSchedule;');
        // this.executeMySql('drop table CourseInformation;')
        // ;this.executeMySql('drop table ScheduleTableInformation;')
        this.executeMySql(AREAS_TABLE_SQL);
        this.executeMySql(BUILDINGS_TABLE_SQL);
        this.executeMySql(FLOOR_TABLE_SQL);
        this.executeMySql(ROOM_TABLE_SQL);
        this.executeMySql(METER_TABLE_SQL);
        this.executeMySql(DORM_LOCATION_TABLE_SQL);
        this.executeMySql(SCHEDULE_TABLE_INFO_TABLE_SQL);
        this.executeMySql(COURSE_INFO_TABLE_SQL);
        this.executeMySql(COURSE_SCHEDULE_TABLE_SQL);
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

  queryMySql(sql: string) {
    try {
      let resultSet: relationalStore.ResultSet = (this.store as relationalStore.RdbStore).querySqlSync(sql);
      if (resultSet) {
        return resultSet;
      } else {
        return false;
      }
    } catch (error) {
      console.error(TAG, sql + `failed, code is ${error.code},message is ${error.message}`)
      return false;
    }
  }

  queryMyPredicates(predicates: relationalStore.RdbPredicates, columns?: string[] | undefined) {
    try {
      let resultSet: relationalStore.ResultSet =
        (this.store as relationalStore.RdbStore).querySync(predicates, columns);
      if (resultSet) {
        return resultSet;
      }
      return false;
    } catch (error) {
      console.error(TAG, 'queryMyPredicates', `failed, code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }

  insertMyValueBucket(valueBucket: ValuesBucket, tableName: string,
    conflictResolve: relationalStore.ConflictResolution) {
    try {
      let rows: number = (this.store as relationalStore.RdbStore).insertSync(tableName, valueBucket, conflictResolve);
      if (rows > 0) {
        console.info(TAG, 'insertMyValueBucket', `Insert row at: ${rows}`)
        return rows;
      } else {
        return -1;
      }
    } catch (error) {
      console.error(TAG, 'insertMyValueBucket', `failed, code is ${error.code},message is ${error.message}`)
      return -1;
    }
  }

  updateMyValueBucket(valueBucket: ValuesBucket, predicates: relationalStore.RdbPredicates,
    conflictResolve: relationalStore.ConflictResolution, columns?: string[]) {
    try {
      let rows: number = (this.store as relationalStore.RdbStore).updateSync(valueBucket, predicates, conflictResolve);
      if (rows && rows > 0) {
        console.info(TAG, 'updateMyValueBucket', `Update row at: ${rows}`);
        return true;
      }
      return false;
    } catch (error) {
      console.error(TAG, 'updateMyValueBucket', `Update failed, code is ${error.code},message is ${error.message}`)
      return false;
    }
  }

  deleteMyPredicate(predicates: relationalStore.RdbPredicates) {
    try {
      let rows: number = (this.store as relationalStore.RdbStore).deleteSync(predicates);
      if (rows && rows > 0) {
        console.info(TAG, 'deleteMyPredicate', `Delete row count: ${rows}`)
        return true;
      }
      return false;
    } catch (err) {
      console.error(TAG, 'deleteMyPredicate', `Delete failed, code is ${err.code},message is ${err.message}`);
      return false;
    }
  }
}