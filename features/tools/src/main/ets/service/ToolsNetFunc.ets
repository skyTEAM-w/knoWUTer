import { Area, Building, DormitoryLocation, Floor, Meter, Room } from '../model/DormitoryLocation';
import { ElectricityFeeActionType, HttpUtil, buildFormBody, HttpUtilResponse } from '@ohos/network/src/main/ets/network/HttpUtil';
import { ArrayList, JSON } from '@kit.ArkTS';
import {
  HttpAreaList,
  HttpBuildingList,
  HttpFloorList,
  HttpMeter,
  HttpReserve,
  HttpRoomList
} from '../model/HttpPostResponse';
import { insertArea, insertBuilding, insertFloor, insertMeter, insertRoom } from './ToolsDatabaseFunc';


const TAG = '[ToolsNetFunc]'

export function buildElectricityFeeRequestBody(action: string | ElectricityFeeActionType = 'getAreaInfo',
  dormitoryLocation: DormitoryLocation = new DormitoryLocation(), meterId: string = ''): string {

  switch (action) {
    case ElectricityFeeActionType.AREA: {
      let feBody: string = buildFormBody({ "factorycode": "E035" });
      console.info(TAG, "factorycode", "E035")
      return feBody;
    }
    case ElectricityFeeActionType.BUILD: {
      let feBody: string = buildFormBody({ "factorycode": "E035", "areaid": `${dormitoryLocation.AreaId}` });
      console.info(TAG, "areaid", `${dormitoryLocation.AreaId}`)
      return feBody;
    }
    case ElectricityFeeActionType.FLOOR: {
      let feBody: string = buildFormBody({ "factorycode": "E035", "areaid": `${dormitoryLocation.AreaId}`,
        "buildid": `${dormitoryLocation.BuildingId}` });
      return feBody;
    }
    case ElectricityFeeActionType.ROOM: {
      let feBody: string = buildFormBody({ "factorycode": "E035", "buildid": `${dormitoryLocation.BuildingId}`,
        "floorid": `${dormitoryLocation.FloorId}` });
      return feBody;
    }
    case ElectricityFeeActionType.ELECTRICITY: {
      let feBody: string = buildFormBody({ "factorycode": "E035", "roomid": `${dormitoryLocation.RoomId}` });
      return feBody;
    }
    case ElectricityFeeActionType.METER: {
      let feBody: string = buildFormBody({ "factorycode": "E035", "meterId": `${dormitoryLocation.MeterId}` });
      return feBody;
    }
    default: {
      let feBody: string = buildFormBody({ "factorycode": "E035" });
      console.info(TAG, "factorycode", "E035")
      return feBody;
    }
  }

}

export async function checkLoginStatusForCWSF(cookie: string): Promise<boolean> {
  let response: HttpUtilResponse | undefined = await whutElectricityFeeAction(ElectricityFeeActionType.AREA, cookie);
  if (response) {
    let jsonObject: Object | null = JSON.parse(response.getBody().toString());
    if (JSON.has(jsonObject, 'areaList')) {
      return true;
    } else {
      return false;
    }
  }
  return false;
}

export async function whutElectricityFeeAction(action: string | ElectricityFeeActionType, cookie: string,
  dormitoryLocation: DormitoryLocation = new DormitoryLocation()): Promise<HttpUtilResponse | undefined> {
  let body: string = buildElectricityFeeRequestBody(action, dormitoryLocation)
  return await HttpUtil.getInstance().HttpPost(`http://cwsf.whut.edu.cn/${action}`, cookie, body)
}

export async function getAreaListHttp(cookie: string): Promise<ArrayList<Area> | undefined> {
  let response: HttpUtilResponse | undefined = await whutElectricityFeeAction(ElectricityFeeActionType.AREA, cookie);
  console.debug(TAG, 'getAreaList', response?.getBody())
  if (response) {
    console.info(TAG, 'Response: 200')
    let body: string = response.getBody().toString();
    let jsonObject = JSON.parse(body) as object;
    let areaList: HttpAreaList = JSON.parse(body) as HttpAreaList;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'areaList'));
    console.debug(TAG, areaList.areaList);
    let dbAreaList: ArrayList<Area> = parseResponseBodyToAreaList(areaList);
    if (JSON.has(jsonObject, 'areaList')) {
      dbAreaList.forEach((item: Area) => {
        insertArea(item);
      })
    }
    return dbAreaList;
  }
  return undefined;
}

export async function getBuildingListHttp(cookie: string, area: Area): Promise<ArrayList<Building> | undefined> {
  let dormitoryLocation: DormitoryLocation = new DormitoryLocation();
  dormitoryLocation.Area = area.area;
  dormitoryLocation.AreaId = area.areaId;
  let response: HttpUtilResponse | undefined = await whutElectricityFeeAction(ElectricityFeeActionType.BUILD, cookie, dormitoryLocation);
  console.debug(TAG, 'getBuildingListHttp', response?.getBody())
  if (response) {
    console.info(TAG, 'Response: 200')
    let body: string = response.getBody().toString();
    let jsonObject = JSON.parse(body) as object;
    let buildingList: HttpBuildingList = JSON.parse(body) as HttpBuildingList;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'buildList'));
    console.debug(TAG, buildingList.buildList);
    let dbBuildList: ArrayList<Building> = parseResponseBodyToBuildList(buildingList);
    console.debug(TAG, JSON.stringify(dbBuildList))
    if (JSON.has(jsonObject, 'buildList')) {
      dbBuildList.forEach((item: Building) => {
        insertBuilding(item, area);
      })
    }
    return dbBuildList;
  }
  return undefined;
}

export async function getFloorListHttp(cookie: string, area: Area,
  building: Building): Promise<ArrayList<Floor> | undefined> {
  let dormitoryLocation: DormitoryLocation = new DormitoryLocation();
  dormitoryLocation.Area = area.area;
  dormitoryLocation.AreaId = area.areaId;
  dormitoryLocation.Building = building.Building;
  dormitoryLocation.BuildingId = building.BuildingId;
  let response: HttpUtilResponse | undefined = await whutElectricityFeeAction(ElectricityFeeActionType.FLOOR, cookie, dormitoryLocation);
  console.debug(TAG, 'getFloorListHttp', response?.getBody());
  if (response) {
    console.info(TAG, 'Response: 200')
    let body: string = response.getBody().toString();
    let jsonObject = JSON.parse(body) as object;
    let floorList: HttpFloorList = JSON.parse(body) as HttpFloorList;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'floorList'));
    console.debug(TAG, floorList.floorList);
    let dbFloorList: ArrayList<Floor> = parseResponseBodyToFloorList(floorList);
    console.debug(TAG, JSON.stringify(dbFloorList))
    if (JSON.has(jsonObject, 'floorList')) {
      dbFloorList.forEach((item: Floor) => {
        insertFloor(item, building);
      })
    }
    return dbFloorList;
  }
  return undefined;

}

export async function getRoomListHttp(cookie: string, building: Building,
  floor: Floor): Promise<ArrayList<Room> | undefined> {
  let dormitoryLocation: DormitoryLocation = new DormitoryLocation();
  dormitoryLocation.Building = building.Building;
  dormitoryLocation.BuildingId = building.BuildingId;
  dormitoryLocation.Floor = floor.Floor;
  dormitoryLocation.FloorId = floor.FloorId;
  let response: HttpUtilResponse | undefined =
    await whutElectricityFeeAction(ElectricityFeeActionType.ROOM, cookie, dormitoryLocation);
  console.debug(TAG, 'getRoomListHttp', response?.getBody());
  if (response) {
    console.info(TAG, 'Response: 200')
    let body: string = response.getBody().toString();
    let jsonObject = JSON.parse(body) as object;
    let roomList: HttpRoomList = JSON.parse(body) as HttpRoomList;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'roomList'));
    console.debug(TAG, roomList.roomList);
    let dbFloorList: ArrayList<Room> = parseResponseBodyToRoomList(roomList);
    console.debug(TAG, JSON.stringify(dbFloorList))
    if (JSON.has(jsonObject, 'roomList')) {
      dbFloorList.forEach((item: Room) => {
        insertRoom(item, building, floor);
      })
    }
    return dbFloorList;
  }
  return undefined;

}

export async function getMeterIdHttp(cookie: string, room: Room): Promise<Meter | undefined> {
  let dormitoryLocation: DormitoryLocation = new DormitoryLocation();
  dormitoryLocation.RoomId = room.RoomId;
  dormitoryLocation.Room = room.Room;
  let response: HttpUtilResponse | undefined =
    await whutElectricityFeeAction(ElectricityFeeActionType.ELECTRICITY, cookie, dormitoryLocation);
  console.debug(TAG, 'getMeterIdHttp', response?.getBody())
  if (response) {
    let body: string = response.getBody().toString();
    let jsonObject = JSON.parse(body) as object;
    let httpMeter: HttpMeter = JSON.parse(body) as HttpMeter;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'meterId'));
    console.debug(TAG, JSON.stringify(httpMeter));
    if (JSON.has(jsonObject, 'meterId')) {
      insertMeter(new Meter(httpMeter.meterId), room);
    }
    return new Meter(httpMeter.meterId)
  }
  return undefined;
}

export async function getElectricityFeeHttp(cookie: string, meter: Meter): Promise<HttpReserve | undefined> {
  let dormitoryLocation: DormitoryLocation = new DormitoryLocation();
  dormitoryLocation.MeterId = meter.MeterId
  let response: HttpUtilResponse | undefined =
    await whutElectricityFeeAction(ElectricityFeeActionType.METER, cookie, dormitoryLocation);
  console.debug(TAG, 'getElectricityFeeHttp', response?.getBody())
  if (response) {
    let body: string = response.getBody().toString();
    let jsonObject = JSON.parse(body) as object;
    let httpReserve: HttpReserve = JSON.parse(body) as HttpReserve;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'remainPower'));
    console.debug(TAG, JSON.stringify(httpReserve));
    return httpReserve;
  }
  return undefined
}

function parseResponseBodyToAreaList(responseBody: HttpAreaList): ArrayList<Area> {
  let res: ArrayList<Area> = new ArrayList<Area>();
  responseBody.areaList.forEach((item: string) => {
    let splitString: string[] = item.split('@');
    res.add(new Area(splitString[0], splitString[1]))
  })
  return res;
}

function parseResponseBodyToBuildList(responseBody: HttpBuildingList): ArrayList<Building> {
  let res: ArrayList<Building> = new ArrayList<Building>();
  responseBody.buildList.forEach((item: string) => {
    let splitString: string[] = item.split('@');
    res.add(new Building(splitString[1], splitString[0]))
  })
  return res;
}

function parseResponseBodyToFloorList(responseBody: HttpFloorList): ArrayList<Floor> {
  let res: ArrayList<Floor> = new ArrayList();
  responseBody.floorList.forEach((item: string) => {
    res.add(new Floor(item.toString(), item.toString()));
  })
  return res;
}

function parseResponseBodyToRoomList(responseBody: HttpRoomList): ArrayList<Room> {
  let res: ArrayList<Room> = new ArrayList();
  responseBody.roomList.forEach((item: string) => {
    let splitString: string[] = item.split('@');
    res.add(new Room(splitString[1], splitString[0]))
  })
  return res;
}
