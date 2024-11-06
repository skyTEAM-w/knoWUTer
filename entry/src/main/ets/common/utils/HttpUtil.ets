import { FormEncoder, HttpClient, Request, RequestBody, Response, TimeUnit } from '@ohos/httpclient';
import { ArrayList, JSON, taskpool } from '@kit.ArkTS';
import { DormitoryLocation } from '../model/DormitoryLocation';
import {
    HttpAreaList,
    HttpBuildingList,
    HttpFloorList,
    HttpMeter,
    HttpReserve,
    HttpRoomList
} from '../model/HttpResponseImp';
import { Area } from '../model/Area';
import { DBUtil } from './DBUtil';
import { Building } from '../model/Building';
import { Floor } from '../model/Floor';
import { Room } from '../model/Room';
import { Meter } from '../model/Meter';

const TAG = '[HttpUtil]'

export enum ElectricityFeeActionType {
  AREA = 'getAreaInfo',
  BUILD = 'queryBuildList',
  FLOOR = 'queryFloorList',
  ROOM = 'getRoomInfo',
  ELECTRICITY = 'queryRoomElec',
  METER = 'queryReserve'
}

export class HttpUtil {
  private static instance: HttpUtil;

  public static getInstance(): HttpUtil {
    if (!HttpUtil.instance) {
      HttpUtil.instance = new HttpUtil();
    }
    return HttpUtil.instance;
  }

  async HttpPost(url: string, cookies: string, body: RequestBody): Promise<Response | undefined> {
    let client = new HttpClient.Builder().setConnectTimeout(30, TimeUnit.SECONDS)
      .setReadTimeout(30, TimeUnit.SECONDS).setWriteTimeout(30, TimeUnit.SECONDS).build();
    let request = new Request.Builder().url(url)
      .post(body)
      .addHeader("Accept",
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7")
      .addHeader("Accept-Encoding", "gzip, deflate")
      .addHeader("Accept-Language", "zh-CN,zh;q=0.9,en-GB;q=0.8,en-US;q=0.7,en;q=0.6")
      .addHeader("Cache-Control", "no-cache")
      .addHeader("Connection", "keep-alive")
      .addHeader("Cookie", cookies)
      .addHeader("Pragma", "no-cache")
      .addHeader("Upgrade-Insecure-Requests", "1")
      .addHeader("User-Agent",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76")
      .addHeader("Content-Type", "application/x-www-form-urlencoded")
      .build()
    return await client.newCall(request).execute();
  }

  buildElectricityFeeRequestBody(action: string | ElectricityFeeActionType = 'getAreaInfo',
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

  async checkLoginStatusForCWSF(cookie: string): Promise<boolean> {
    let response = await this.whutElectricityFeeAction(ElectricityFeeActionType.AREA, cookie);
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

  async whutElectricityFeeAction(action: string | ElectricityFeeActionType, cookie: string,
    dormitoryLocation: DormitoryLocation = new DormitoryLocation()): Promise<Response | undefined> {
    let body = this.buildElectricityFeeRequestBody(action, dormitoryLocation)
    return await this.HttpPost(`http://cwsf.whut.edu.cn/${action}`, cookie, body)
  }

  async getAreaListHttp(cookie: string): Promise<ArrayList<Area> | undefined> {
    let response = await this.whutElectricityFeeAction(ElectricityFeeActionType.AREA, cookie);
    console.debug(TAG, 'getAreaList', response?.getBody())
    if (response) {
      console.info(TAG, 'Response: 200')
      let body = response.getBody().toString();
      let jsonObject = JSON.parse(body);
      let areaList = JSON.parse(body) as HttpAreaList;
      console.info(TAG, JSON.parse(body));
      console.info(TAG, JSON.has(jsonObject, 'areaList'));
      console.debug(TAG, areaList.areaList);
      let dbAreaList = this.parseResponseBodyToAreaList(areaList);
      if (JSON.has(jsonObject, 'areaList')) {
        dbAreaList.forEach((item: Area) => {
          DBUtil.getInstance().insertArea(item);
        })
      }
      return dbAreaList;
    }
    return undefined;
  }

  async getBuildingListHttp(cookie: string, area: Area): Promise<ArrayList<Building> | undefined> {
    let dormitoryLocation = new DormitoryLocation();
    dormitoryLocation.Area = area.area;
    dormitoryLocation.AreaId = area.areaId;
    let response = await this.whutElectricityFeeAction(ElectricityFeeActionType.BUILD, cookie, dormitoryLocation);
    console.debug(TAG, 'getBuildingListHttp', response?.getBody())
    if (response) {
      console.info(TAG, 'Response: 200')
      let body = response.getBody().toString();
      let jsonObject = JSON.parse(body);
      let buildingList = JSON.parse(body) as HttpBuildingList;
      console.info(TAG, JSON.parse(body));
      console.info(TAG, JSON.has(jsonObject, 'buildList'));
      console.debug(TAG, buildingList.buildList);
      let dbBuildList = this.parseResponseBodyToBuildList(buildingList);
      console.debug(TAG, JSON.stringify(dbBuildList))
      if (JSON.has(jsonObject, 'buildList')) {
        dbBuildList.forEach((item: Building) => {
          DBUtil.getInstance().insertBuilding(item, area);
        })
      }
      return dbBuildList;
    }
    return undefined;
  }

  async getFloorListHttp(cookie: string, area: Area, building: Building): Promise<ArrayList<Floor> | undefined> {
    let dormitoryLocation = new DormitoryLocation();
    dormitoryLocation.Area = area.area;
    dormitoryLocation.AreaId = area.areaId;
    dormitoryLocation.Building = building.Building;
    dormitoryLocation.BuildingId = building.BuildingId;
    let response = await this.whutElectricityFeeAction(ElectricityFeeActionType.FLOOR, cookie, dormitoryLocation);
    console.debug(TAG, 'getFloorListHttp', response?.getBody());
    if (response) {
      console.info(TAG, 'Response: 200')
      let body = response.getBody().toString();
      let jsonObject = JSON.parse(body);
      let floorList = JSON.parse(body) as HttpFloorList;
      console.info(TAG, JSON.parse(body));
      console.info(TAG, JSON.has(jsonObject, 'floorList'));
      console.debug(TAG, floorList.floorList);
      let dbFloorList = this.parseResponseBodyToFloorList(floorList);
      console.debug(TAG, JSON.stringify(dbFloorList))
      if (JSON.has(jsonObject, 'floorList')) {
        dbFloorList.forEach((item: Floor) => {
          DBUtil.getInstance().insertFloor(item, building);
        })
      }
      return dbFloorList;
    }
    return undefined;

  }

  async getRoomListHttp(cookie: string, building: Building, floor: Floor): Promise<ArrayList<Room> | undefined> {
    let dormitoryLocation: DormitoryLocation = new DormitoryLocation();
    dormitoryLocation.Building = building.Building;
    dormitoryLocation.BuildingId = building.BuildingId;
    dormitoryLocation.Floor = floor.Floor;
    dormitoryLocation.FloorId = floor.FloorId;
    let response: Response =
      await this.whutElectricityFeeAction(ElectricityFeeActionType.ROOM, cookie, dormitoryLocation) as Response;
    console.debug(TAG, 'getRoomListHttp', response?.getBody());
    if (response) {
      console.info(TAG, 'Response: 200')
      let body = response.getBody().toString();
      let jsonObject = JSON.parse(body);
      let roomList = JSON.parse(body) as HttpRoomList;
      console.info(TAG, JSON.parse(body));
      console.info(TAG, JSON.has(jsonObject, 'roomList'));
      console.debug(TAG, roomList.roomList);
      let dbFloorList = this.parseResponseBodyToRoomList(roomList);
      console.debug(TAG, JSON.stringify(dbFloorList))
      if (JSON.has(jsonObject, 'roomList')) {
        dbFloorList.forEach((item: Room) => {
          DBUtil.getInstance().insertRoom(item, building, floor);
        })
      }
      return dbFloorList;
    }
    return undefined;

  }

  async getMeterIdHttp(cookie: string, room: Room): Promise<Meter | undefined> {
    let dormitoryLocation: DormitoryLocation = new DormitoryLocation();
    dormitoryLocation.RoomId = room.RoomId;
    dormitoryLocation.Room = room.Room;
    let response: Response =
      await this.whutElectricityFeeAction(ElectricityFeeActionType.ELECTRICITY, cookie, dormitoryLocation) as Response;
    console.debug(TAG, 'getMeterIdHttp', response.getBody())
    if (response) {
      let body = response.getBody().toString();
      let jsonObject = JSON.parse(body);
      let httpMeter = JSON.parse(body) as HttpMeter;
      console.info(TAG, JSON.parse(body));
      console.info(TAG, JSON.has(jsonObject, 'meterId'));
      console.debug(TAG, JSON.stringify(httpMeter));
      if (JSON.has(jsonObject, 'meterId')) {
        DBUtil.getInstance().insertMeter(new Meter(httpMeter.meterId), room);
      }
      return new Meter(httpMeter.meterId)
    }
    return undefined;
  }

  async getElectricityFeeHttp(cookie: string, meter: Meter): Promise<HttpReserve | undefined> {
    let dormitoryLocation: DormitoryLocation = new DormitoryLocation();
    dormitoryLocation.MeterId = meter.MeterId
    let response: Response =
      await this.whutElectricityFeeAction(ElectricityFeeActionType.METER, cookie, dormitoryLocation) as Response;
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

  parseResponseBodyToAreaList(responseBody: HttpAreaList): ArrayList<Area> {
    let res = new ArrayList<Area>();
    responseBody.areaList.forEach((item: string) => {
      let splitString: string[] = item.split('@');
      res.add(new Area(splitString[0], splitString[1]))
    })
    return res;
  }

  parseResponseBodyToBuildList(responseBody: HttpBuildingList): ArrayList<Building> {
    let res = new ArrayList<Building>();
    responseBody.buildList.forEach((item: string) => {
      let splitString: string[] = item.split('@');
      res.add(new Building(splitString[1], splitString[0]))
    })
    return res;
  }

  parseResponseBodyToFloorList(responseBody: HttpFloorList): ArrayList<Floor> {
    let res: ArrayList<Floor> = new ArrayList();
    responseBody.floorList.forEach((item: string) => {
      res.add(new Floor(item.toString(), item.toString()));
    })
    return res;
  }

  parseResponseBodyToRoomList(responseBody: HttpRoomList): ArrayList<Room> {
    let res: ArrayList<Room> = new ArrayList();
    responseBody.roomList.forEach((item: string) => {
      let splitString: string[] = item.split('@');
      res.add(new Room(splitString[1], splitString[0]))
    })
    return res;
  }
}

@Concurrent
export async function checkCWSFLoginStatus(cookie: string) {
  let client = new HttpClient.Builder().setConnectTimeout(30, TimeUnit.SECONDS)
    .setReadTimeout(30, TimeUnit.SECONDS).setWriteTimeout(30, TimeUnit.SECONDS).build();
  let formEncoder = new FormEncoder.Builder().add("factorycode", "E035").build();
  console.info('checkCWSFLoginStatus', "factorycode", "E035")
  let feBody = formEncoder.createRequestBody();
  let request = new Request.Builder().url('http://cwsf.whut.edu.cn/getAreaInfo')
    .post(feBody)
    .addHeader("Accept",
      "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7")
    .addHeader("Accept-Encoding", "gzip, deflate")
    .addHeader("Accept-Language", "zh-CN,zh;q=0.9,en-GB;q=0.8,en-US;q=0.7,en;q=0.6")
    .addHeader("Cache-Control", "no-cache")
    .addHeader("Connection", "keep-alive")
    .addHeader("Cookie", cookie)
    .addHeader("Pragma", "no-cache")
    .addHeader("Upgrade-Insecure-Requests", "1")
    .addHeader("User-Agent",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76")
    .addHeader("Content-Type", "application/x-www-form-urlencoded")
    .build()
  let response = await client.newCall(request).execute();
  if (response?.getBody().toString().match('登录')?.length as number > 0) {
    taskpool.Task.sendData(false);
    return false;
  } else {
    taskpool.Task.sendData(true);
    return true;
  }
}

