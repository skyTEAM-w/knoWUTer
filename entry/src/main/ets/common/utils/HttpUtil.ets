import { FormEncoder, HttpClient, Logger, Mime, Request, RequestBody, Response, TimeUnit } from '@ohos/httpclient';
import MediaType from '@ohos/httpclient/src/main/ets/cache/MediaType';
import { ArrayList, JSON } from '@kit.ArkTS';
import { when } from '@ohos/hypium';
import { DormitoryLocation } from '../model/DormitoryLocation';
import { HttpAreaList, HttpBuildingList, HttpFloorList } from '../model/HttpList';
import { HttpPostResponseBody } from '../model/HttpPostResponseBody';
import { Area } from '../model/Area';
import { DBUtil } from './DBUtil';
import { Building } from '../model/Building';

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

  buildElectricityFeeRequestBody(action: string | ElectricityFeeActionType = 'getAreaInfo', dormitoryLocation: DormitoryLocation = new DormitoryLocation(), meterId: string = '') {

    switch (action) {
      case ElectricityFeeActionType.AREA: {
        let formEncoder = new FormEncoder.Builder().add("factorycode","E035").build();
        console.info(TAG, "factorycode","E035")
        let feBody = formEncoder.createRequestBody();
        return feBody;
      }
      case ElectricityFeeActionType.BUILD: {
        let formEncoder = new FormEncoder.Builder().add("factorycode","E035").add("areaid", `${dormitoryLocation.AreaId}`).build();
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
        let formEncoder = new FormEncoder.Builder().add("factorycode", "E035").add("meterId", `${meterId}`).build();
        let feBody = formEncoder.createRequestBody();
        return feBody;
      }
      default : {
        let formEncoder = new FormEncoder.Builder().add("factorycode","E035").build();
        console.info(TAG, "factorycode","E035")
        let feBody = formEncoder.createRequestBody();
        return feBody;
      }
    }

  }

  async whutElectricityFeeAction(action: string | ElectricityFeeActionType, cookie: string, dormitoryLocation: DormitoryLocation = new DormitoryLocation()): Promise<Response | undefined>{
    let body = this.buildElectricityFeeRequestBody(action, dormitoryLocation)
    return await this.HttpPost(`http://cwsf.whut.edu.cn/${action}`,cookie, body)
  }

  async getAreaListHttp(cookie: string): Promise<ArrayList<Area>> {
    let response = await this.whutElectricityFeeAction(ElectricityFeeActionType.AREA, cookie);
    console.debug(TAG, 'getAreaList', response?.getBody())
    if (response) {
      console.info(TAG, 'Response: 200')
      let body = response.getBody().toString();
      let jsonObjet = JSON.parse(body);
      let areaList = JSON.parse(body) as HttpAreaList;
      console.info(TAG, JSON.parse(body));
      console.info(TAG, JSON.has(jsonObjet, 'areaList'));
      console.debug(TAG, areaList.areaList);
      let dbAreaList = this.parseResponseBodyToAreaList(areaList);
      if (JSON.has(jsonObjet, 'areaList')) {
        dbAreaList.forEach((item: Area) => {
          DBUtil.getInstance().insertArea(item);
        })
      }
      return dbAreaList;
    }
    return new ArrayList<Area>()
  }

  async getBuildingListHttp(cookie: string, area: Area) {
    let dormitoryLocation= new DormitoryLocation();
    dormitoryLocation.Area = area.area; dormitoryLocation.AreaId = area.areaId;
    let response = await this.whutElectricityFeeAction(ElectricityFeeActionType.BUILD, cookie, dormitoryLocation);
    console.debug(TAG, 'getBuildingListHttp', response?.getBody())
    if (response) {
      console.info(TAG, 'Response: 200')
      let body = response.getBody().toString();
      let jsonObjet = JSON.parse(body);
      let buildingList = JSON.parse(body) as HttpBuildingList;
      console.info(TAG, JSON.parse(body));
      console.info(TAG, JSON.has(jsonObjet, 'buildList'));
      console.debug(TAG, buildingList.buildList);
      let dbAreaList = this.parseResponseBodyToBuildList(buildingList);
      console.debug(TAG, JSON.stringify(dbAreaList))
      if (JSON.has(jsonObjet, 'buildList')) {
        dbAreaList.forEach((item: Building) => {
          DBUtil.getInstance().insertBuilding(item, area);
        })
      }
      return dbAreaList;
    }
    return new ArrayList<Building>();
  }

  async getFloorListHttp(cookie: string, area: Area, building: Building) {
    let dormitoryLocation= new DormitoryLocation();
    dormitoryLocation.Area = area.area; dormitoryLocation.AreaId = area.areaId;
    dormitoryLocation.Building = building.Building; dormitoryLocation.BuildingId = building.BuildingId;
    let response = await this.whutElectricityFeeAction(ElectricityFeeActionType.FLOOR, cookie, dormitoryLocation);
    console.debug(TAG, 'getFloorListHttp', response?.getBody());
    if (response) {
      console.info(TAG, 'Response: 200')
      let body = response.getBody().toString();
      let jsonObjet = JSON.parse(body);
      let buildingList = JSON.parse(body) as HttpFloorList;
      console.info(TAG, JSON.parse(body));
      console.info(TAG, JSON.has(jsonObjet, 'floorList'));
      console.debug(TAG, buildingList.floorList);
      // let dbAreaList = this.parseResponseBodyToBuildList(buildingList);
      // console.debug(TAG, JSON.stringify(dbAreaList))
      // if (JSON.has(jsonObjet, 'floorList')) {
      //   dbAreaList.forEach((item: Building) => {
      //     // DBUtil.getInstance().insertBuilding(item, area);
      //   })
      // }
      // return dbAreaList;
    }

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

}

