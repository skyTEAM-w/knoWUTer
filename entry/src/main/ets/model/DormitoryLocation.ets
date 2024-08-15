export class DormitoryLocation {
  Area: string = '';
  Building: string = '';
  Floor: string = '';
  Room: string = '';

  constructor(Area: string, Building: string, Floor: string, Room: string) {
    this.Area = Area;
    this.Building = Building;
    this.Floor = Floor;
    this.Room = Room;
  }
}