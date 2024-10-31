export class DormitoryLocation {
  private _Area: string = '';

  public set Area(value: string) {
    this._Area = value;
  }

  public get Area(): string {
    return this._Area;
  }

  private _AreaId: string = '';

  public set AreaId(value: string) {
    this._AreaId = value;
  }

  public get AreaId(): string {
    return this._AreaId;
  }

  private _Building: string = '';

  public set Building(value: string) {
    this._Building = value;
  }

  public get Building(): string {
    return this._Building;
  }

  private _BuildingId: string = '';

  public set BuildingId(value: string) {
    this._BuildingId = value;
  }

  public get BuildingId(): string {
    return this._BuildingId;
  }

  private _Floor: string = '';

  public set Floor(value: string) {
    this._Floor = value;
  }

  public get Floor(): string {
    return this._Floor;
  }

  private _FloorId: string = '';

  public set FloorId(value: string) {
    this._FloorId = value;
  }

  public get FloorId(): string {
    return this._FloorId;
  }

  private _Room: string = '';

  public set Room(value: string) {
    this._Room = value;
  }

  public get Room(): string {
    return this._Room;
  }

  private _RoomId: string = '';

  public set RoomId(value: string) {
    this._RoomId = value;
  }

  public get RoomId(): string {
    return this._RoomId;
  }

}