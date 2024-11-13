@Observed
export class DormitoryLocation {
  private _Area: string = '';

  public get Area(): string {
    return this._Area;
  }

  public set Area(value: string) {
    this._Area = value;
  }

  private _AreaId: string = '';

  public get AreaId(): string {
    return this._AreaId;
  }

  public set AreaId(value: string) {
    this._AreaId = value;
  }

  private _Building: string = '';

  public get Building(): string {
    return this._Building;
  }

  public set Building(value: string) {
    this._Building = value;
  }

  private _BuildingId: string = '';

  public get BuildingId(): string {
    return this._BuildingId;
  }

  public set BuildingId(value: string) {
    this._BuildingId = value;
  }

  private _Floor: string = '';

  public get Floor(): string {
    return this._Floor;
  }

  public set Floor(value: string) {
    this._Floor = value;
  }

  private _FloorId: string = '';

  public get FloorId(): string {
    return this._FloorId;
  }

  public set FloorId(value: string) {
    this._FloorId = value;
  }

  private _Room: string = '';

  public get Room(): string {
    return this._Room;
  }

  public set Room(value: string) {
    this._Room = value;
  }

  private _RoomId: string = '';

  public get RoomId(): string {
    return this._RoomId;
  }

  public set RoomId(value: string) {
    this._RoomId = value;
  }

  private _isStar: boolean = false;

  public get isStar(): boolean {
    return this._isStar;
  }

  public set isStar(value: boolean) {
    this._isStar = value;
  }

  private _MeterId: string = '';

  public get MeterId(): string {
    return this._MeterId;
  }

  public set MeterId(value: string) {
    this._MeterId = value;
  }
}

export class Area {
  areaId: string = '';
  area: string = '';

  constructor(areaId: string, area: string) {
    this.areaId = areaId;
    this.area = area;
  }
}

export class Building {
  Building: string = '';
  BuildingId: string = '';

  constructor(Building: string, BuildingId: string) {
    this.Building = Building;
    this.BuildingId = BuildingId;
  }
}

export class Floor {
  Floor: string = '';
  FloorId: string = '';

  constructor(Floor: string, FloorId: string) {
    this.Floor = Floor;
    this.FloorId = FloorId;
  }
}

export class Meter {
  MeterId: string = '';

  constructor(MeterId: string) {
    this.MeterId = MeterId;
  }
}

export class Room {
  Room: string = '';
  RoomId: string = '';

  constructor(Room: string, RoomId: string) {
    this.Room = Room;
    this.RoomId = RoomId;
  }
}