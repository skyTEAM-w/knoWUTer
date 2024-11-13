import { HttpPostResponseBody } from '@ohos/network';

export class HttpAreaList implements HttpPostResponseBody {
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

export class HttpRoomList implements HttpPostResponseBody {
  returncode: string = '';
  returnmsg: string = '';
  roomList: string[] = [];
}

export class HttpMeter implements HttpPostResponseBody {
  returncode: string = '';
  returnmsg: string = '';
  oweFee: string = '';
  meterId: string = '';
}

export class HttpReserve implements HttpPostResponseBody {
  returncode: string = '';
  returnmsg: string = '';
  ZVlaue: string = '';
  meterOverdue: string = '';
  remainName: string = '';
  remainPower: string = '';
  unit: string = '';
  valve: string = '';
}