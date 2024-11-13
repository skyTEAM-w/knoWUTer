import { Area, Building, DormitoryLocation, Floor, Meter, Room } from '../model/DormitoryLocation';
import { FormEncoder, Response } from '@ohos/httpclient';
import { ElectricityFeeActionType, HttpUtil } from '@ohos/network/src/main/ets/network/HttpUtil';
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
  dormitoryLocation: DormitoryLocation = new DormitoryLocation(), meterId: string = '') {

  switch (action) {
    case ElectricityFeeActionType.AREA: {
      let formEncoder = new FormEncoder.Builder().add("factorycode", "E035").build();
      console.info(TAG, "factorycode", "E035")
      let feBody = formEncoder.createRequestBody();
      return feBody;
    }
    case ElectricityFeeActionType.BUILD: {
      let formEncoder =
        new FormEncoder.Builder().add("factorycode", "E035").add("areaid", `${dormitoryLocation.AreaId}`).build();
      console.info(TAG, "areaid", `${dormitoryLocation.AreaId}`)
      let feBody = formEncoder.createRequestBody();
      return feBody;
    }
    case ElectricityFeeActionType.FLOOR: {
      let formEncoder = new FormEncoder.Builder().add("factorycode", "E035").add("areaid",
        `${dormitoryLocation.AreaId}`).add("buildid", `${dormitoryLocation.BuildingId}`).build();
      let feBody = formEncoder.createRequestBody();
      return feBody;
    }
    case ElectricityFeeActionType.ROOM: {
      let formEncoder = new FormEncoder.Builder().add("factorycode", "E035").add("buildid",
        `${dormitoryLocation.BuildingId}`).add("floorid", `${dormitoryLocation.FloorId}`).build();
      let feBody = formEncoder.createRequestBody();
      return feBody;
    }
    case ElectricityFeeActionType.ELECTRICITY: {
      let formEncoder =
        new FormEncoder.Builder().add("factorycode", "E035").add("roomid", `${dormitoryLocation.RoomId}`).build();
      let feBody = formEncoder.createRequestBody();
      return feBody;
    }
    case ElectricityFeeActionType.METER: {
      let formEncoder =
        new FormEncoder.Builder().add("factorycode", "E035").add("meterId", `${dormitoryLocation.MeterId}`).build();
      let feBody = formEncoder.createRequestBody();
      return feBody;
    }
    default: {
      let formEncoder = new FormEncoder.Builder().add("factorycode", "E035").build();
      console.info(TAG, "factorycode", "E035")
      let feBody = formEncoder.createRequestBody();
      return feBody;
    }
  }

}

export async function checkLoginStatusForCWSF(cookie: string): Promise<boolean> {
  let response = await whutElectricityFeeAction(ElectricityFeeActionType.AREA, cookie);
  if (response) {
    let jsonObject = JSON.parse(response.getBody().toString());
    if (JSON.has(jsonObject, 'areaList')) {
      return true;
    } else {
      return false;
    }
  }
  return false;
}

export async function whutElectricityFeeAction(action: string | ElectricityFeeActionType, cookie: string,
  dormitoryLocation: DormitoryLocation = new DormitoryLocation()): Promise<Response | undefined> {
  let body = buildElectricityFeeRequestBody(action, dormitoryLocation)
  return await HttpUtil.getInstance().HttpPost(`http://cwsf.whut.edu.cn/${action}`, cookie, body)
}

export async function getAreaListHttp(cookie: string): Promise<ArrayList<Area> | undefined> {
  let response = await whutElectricityFeeAction(ElectricityFeeActionType.AREA, cookie);
  console.debug(TAG, 'getAreaList', response?.getBody())
  if (response) {
    console.info(TAG, 'Response: 200')
    let body = response.getBody().toString();
    let jsonObject = JSON.parse(body);
    let areaList = JSON.parse(body) as HttpAreaList;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'areaList'));
    console.debug(TAG, areaList.areaList);
    let dbAreaList = parseResponseBodyToAreaList(areaList);
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
  let dormitoryLocation = new DormitoryLocation();
  dormitoryLocation.Area = area.area;
  dormitoryLocation.AreaId = area.areaId;
  let response = await whutElectricityFeeAction(ElectricityFeeActionType.BUILD, cookie, dormitoryLocation);
  console.debug(TAG, 'getBuildingListHttp', response?.getBody())
  if (response) {
    console.info(TAG, 'Response: 200')
    let body = response.getBody().toString();
    let jsonObject = JSON.parse(body);
    let buildingList = JSON.parse(body) as HttpBuildingList;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'buildList'));
    console.debug(TAG, buildingList.buildList);
    let dbBuildList = parseResponseBodyToBuildList(buildingList);
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
  let dormitoryLocation = new DormitoryLocation();
  dormitoryLocation.Area = area.area;
  dormitoryLocation.AreaId = area.areaId;
  dormitoryLocation.Building = building.Building;
  dormitoryLocation.BuildingId = building.BuildingId;
  let response = await whutElectricityFeeAction(ElectricityFeeActionType.FLOOR, cookie, dormitoryLocation);
  console.debug(TAG, 'getFloorListHttp', response?.getBody());
  if (response) {
    console.info(TAG, 'Response: 200')
    let body = response.getBody().toString();
    let jsonObject = JSON.parse(body);
    let floorList = JSON.parse(body) as HttpFloorList;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'floorList'));
    console.debug(TAG, floorList.floorList);
    let dbFloorList = parseResponseBodyToFloorList(floorList);
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
  let response: Response =
    await whutElectricityFeeAction(ElectricityFeeActionType.ROOM, cookie, dormitoryLocation) as Response;
  console.debug(TAG, 'getRoomListHttp', response?.getBody());
  if (response) {
    console.info(TAG, 'Response: 200')
    let body = response.getBody().toString();
    let jsonObject = JSON.parse(body);
    let roomList = JSON.parse(body) as HttpRoomList;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'roomList'));
    console.debug(TAG, roomList.roomList);
    let dbFloorList = parseResponseBodyToRoomList(roomList);
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
  let response: Response =
    await whutElectricityFeeAction(ElectricityFeeActionType.ELECTRICITY, cookie, dormitoryLocation) as Response;
  console.debug(TAG, 'getMeterIdHttp', response.getBody())
  if (response) {
    let body = response.getBody().toString();
    let jsonObject = JSON.parse(body);
    let httpMeter = JSON.parse(body) as HttpMeter;
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
  let response: Response =
    await whutElectricityFeeAction(ElectricityFeeActionType.METER, cookie, dormitoryLocation) as Response;
  console.debug(TAG, 'getElectricityFeeHttp', response.getBody())
  if (response) {
    let body = response.getBody().toString();
    let jsonObject = JSON.parse(body);
    let httpReserve = JSON.parse(body) as HttpReserve;
    console.info(TAG, JSON.parse(body));
    console.info(TAG, JSON.has(jsonObject, 'remainPower'));
    console.debug(TAG, JSON.stringify(httpReserve));
    return httpReserve;
  }
  return undefined
}

function parseResponseBodyToAreaList(responseBody: HttpAreaList): ArrayList<Area> {
  let res = new ArrayList<Area>();
  responseBody.areaList.forEach((item: string) => {
    let splitString: string[] = item.split('@');
    res.add(new Area(splitString[0], splitString[1]))
  })
  return res;
}

function parseResponseBodyToBuildList(responseBody: HttpBuildingList): ArrayList<Building> {
  let res = new ArrayList<Building>();
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