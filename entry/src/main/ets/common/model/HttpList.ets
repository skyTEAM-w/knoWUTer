import { HttpPostResponseBody } from "./HttpPostResponseBody";

export class HttpAreaList implements  HttpPostResponseBody{
  returncode: string = '';
  returnmsg: string = '';
  areaList: string[] = [];

}

export class HttpBuildingList implements HttpPostResponseBody {
  returncode: string = '';
  returnmsg: string = '';
  buildList: string[] = [];
}

export class HttpFloorList implements HttpPostResponseBody {
  returncode: string = '';
  returnmsg: string = '';
  floorList: string[] = [];
}