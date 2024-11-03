import { webview } from '@kit.ArkWeb';
import { DormitoryLocation } from '../../model/DormitoryLocation';
import { BusinessError } from '@kit.BasicServicesKit';
import { DBUtil } from './DBUtil';

export function getElectricCharge(webviewController: webview.WebviewController, dormitoryLocation: DormitoryLocation): Promise<string> {
  let myDormitory = new DormitoryLocation();
  let remainPower: string = '';
  let remainMoney: string = '';

  myDormitory = dormitoryLocation;

  const updateSelection = async (elementId: string, value: string) => {
    try {
      const result = await webviewController.runJavaScript(`
        var selectElement = document.getElementById("${elementId}");
        selectElement.value = "${value}"; // 修改选项
        var event = new Event('change');
        selectElement.dispatchEvent(event);
      `);
      console.info(`The ${elementId} return value is: ${result}`);
      return result;
    } catch (error) {
      console.error(`run JavaScript error for ${elementId}, Error: ${error.message}`);
      return '';
    }
  };

  const getTextContentWithRetry = async (elementId: string, retries: number = 1000) => {
    for (let i = 0; i < retries; i++) {
      const result = await webviewController.runJavaScript(`document.getElementById("${elementId}").outerText`);
      if (result && result.trim() !== "") {
        return result;
      }
    }
    return "";
  };

  const fetchElectricCharge = async () => {
    try {
      await updateSelection("areaid", dormitoryLocation.AreaId);
      await updateSelection("building", dormitoryLocation.BuildingId);
      await updateSelection("floorid", dormitoryLocation.FloorId);
      await updateSelection("roomid", dormitoryLocation.RoomId);

      do {
        remainPower = await getTextContentWithRetry("RemainPower");
        remainMoney = await getTextContentWithRetry("MeterOverdue");
      }while (remainMoney.trim() === "")


      let insertQuery = `INSERT INTO DormitoryLocation (Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId, ElectricFee, RemainingElectric)
                         VALUES ('${myDormitory.Area}', '${myDormitory.AreaId}', '${myDormitory.Building}', '${myDormitory.BuildingId}',
                                 '${myDormitory.Floor}', '${myDormitory.FloorId}', '${myDormitory.Room}', '${myDormitory.RoomId}',
                                 '${remainMoney.trim()}', '${remainPower.trim()}')
                         ON CONFLICT (AreaId, BuildingId, FloorId, RoomId)
                         DO UPDATE SET ElectricFee = excluded.ElectricFee, RemainingElectric = excluded.RemainingElectric;`;

      console.info(insertQuery);
      console.info(remainMoney.trim())

      DBUtil.getInstance().executeSql(insertQuery);

      return remainMoney.replace(/^"+|"+$/g, '');

    } catch (error) {
      console.error("Error fetching electric charge:", error);
      return '';
    }
  };

  return fetchElectricCharge();
}



async function getSelectValue(selectId: string, webviewController: webview.WebviewController): Promise<string[]> {
  const result: string = await webviewController.runJavaScript(`var selectElement = document.getElementById("${selectId}"); [selectElement.value, selectElement.options[selectElement.selectedIndex].text];`);
  if (result) {
    console.info(`The ${selectId} return value is: ${result}`);
    return JSON.parse(result);
  }
  return [];
}

export async function importElectricity(webviewController: webview.WebviewController): Promise<boolean> {
  let myDormitory = new DormitoryLocation();

  const areaIdArray = await getSelectValue("areaid", webviewController);
  myDormitory.AreaId = areaIdArray[0]?.toString() || '';
  myDormitory.Area = areaIdArray[1]?.toString() || '';

  const buildingIdArray = await getSelectValue("building", webviewController);
  myDormitory.BuildingId = buildingIdArray[0]?.toString() || '';
  myDormitory.Building = buildingIdArray[1]?.toString() || '';

  const roomIdArray = await getSelectValue("roomid", webviewController);
  myDormitory.RoomId = roomIdArray[0]?.toString() || '';
  myDormitory.Room = roomIdArray[1]?.toString() || '';

  const floorIdArray = await getSelectValue("floorid", webviewController);
  myDormitory.FloorId = floorIdArray[0]?.toString() || '';
  myDormitory.Floor = floorIdArray[1]?.toString() || '';

  const remainPower = await webviewController.runJavaScript('document.getElementById("RemainPower").outerText');

  const remainMoney = await webviewController.runJavaScript('document.getElementById("MeterOverdue").outerText')

  if (remainPower) {
    console.info(`Remaining Power: ${remainPower}`);
  }
  if (remainMoney) {
    console.info(`Remaining Money: ${remainMoney}`);
  }

  if (JSON.stringify(myDormitory).includes('请选择')) {
    return false;
  }

  let insertQuery = `INSERT INTO DormitoryLocation (Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId, ElectricFee, RemainingElectric)
                         VALUES ('${myDormitory.Area}', '${myDormitory.AreaId}', '${myDormitory.Building}', '${myDormitory.BuildingId}',
                                 '${myDormitory.Floor}', '${myDormitory.FloorId}', '${myDormitory.Room}', '${myDormitory.RoomId}',
                                 '${remainMoney.trim()}', '${remainPower.trim()}')
                         ON CONFLICT (AreaId, BuildingId, FloorId, RoomId)
                         DO UPDATE SET ElectricFee = excluded.ElectricFee, RemainingElectric = excluded.RemainingElectric;`;

  console.info(insertQuery)
  DBUtil.getInstance().executeSql(insertQuery);

  return true;
}
