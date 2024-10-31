import { webview } from '@kit.ArkWeb';
import { DormitoryLocation } from '../../model/DormitoryLocation';
import { BusinessError } from '@kit.BasicServicesKit';
import { DBUtil } from './DBUtil';

let myDormitory = new DormitoryLocation();
let remainPower: string = '';
let remainMoney: string = '';

export function getElectricCharge(webviewController: webview.WebviewController, dormitoryLocation: DormitoryLocation) {
  webviewController.loadUrl('http://cwsf.whut.edu.cn/nyyPayElecPages51274E035');
  webviewController.runJavaScript('var selectElement = document.getElementById("areaid");\n' +
    '            selectElement.value = "0001"; // 修改选项\n' +
    '\n' +
    '            // 创建一个新的事件\n' +
    '            var event = new Event(\'change\');\n' +
    '            // 手动触发 onchange 事件\n' +
    '            selectElement.dispatchEvent(event);', (error, result) => {
    if (error) {
      console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
      return;
    }
    if (result) {
      let webResult = result;
      console.info(`The test() return value is: ${webResult}`);
      AlertDialog.show({
        message: webResult + webviewController.getUrl()
      })
    }
  })
  webviewController.runJavaScript('var selectElement = document.getElementById("building");\n' +
    '            selectElement.value = "000004"; // 修改选项\n' +
    '\n' +
    '            // 创建一个新的事件\n' +
    '            var event = new Event(\'change\');\n' +
    '            // 手动触发 onchange 事件\n' +
    '            selectElement.dispatchEvent(event);', (error, result) => {
    if (error) {
      console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
      return;
    }
    if (result) {
      let webResult = result;
      console.info(`The test() return value is: ${webResult}`);
      AlertDialog.show({
        message: webResult + webviewController.getUrl()
      })
    }
  })
  webviewController.runJavaScript('var selectElement = document.getElementById("floorid");\n' +
    '            selectElement.value = "1"; // 修改选项\n' +
    '\n' +
    '            // 创建一个新的事件\n' +
    '            var event = new Event(\'change\');\n' +
    '            // 手动触发 onchange 事件\n' +
    '            selectElement.dispatchEvent(event);', (error, result) => {
    if (error) {
      console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
      return;
    }
    if (result) {
      let webResult = result;
      console.info(`The test() return value is: ${webResult}`);
      AlertDialog.show({
        message: webResult + webviewController.getUrl()
      })
    }
  })
  webviewController.runJavaScript('var selectElement = document.getElementById("roomid");\n' +
    '            selectElement.value = "00000397"; // 修改选项\n' +
    '\n' +
    '            // 创建一个新的事件\n' +
    '            var event = new Event(\'change\');\n' +
    '            // 手动触发 onchange 事件\n' +
    '            selectElement.dispatchEvent(event);', (error, result) => {
    if (error) {
      console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
      return;
    }
    if (result) {
      let webResult = result;
      console.info(`The test() return value is: ${webResult}`);
      AlertDialog.show({
        message: webResult + webviewController.getUrl()
      })
    }
  })
  webviewController.runJavaScript('document.documentElement.outerText', (error, result) => {
    if (error) {
      console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
      return;
    }
    if (result) {
      let webResult = result;
      console.info(`The test() return value is: ${webResult}`);
      AlertDialog.show({
        message: webResult + webviewController.getUrl()
      })
    }
  })
  webviewController.runJavaScript('document.getElementById("RemainPower").outerText', (error, result) => {
    if (result) {
      let webResult = result;
      console.info(`The test() return value is: ${webResult}`);
      AlertDialog.show({
        message: webResult
      })
    }
  })
}

// export function importElectricity(webviewController: webview.WebviewController) {
//
//   webviewController.runJavaScript('var selectElement = document.getElementById("areaid"); ' +
//     '[selectElement.value, selectElement.options[selectElement.selectedIndex].text];').then((result) => {
//     if (result) {
//       console.info(`The test() return value is: ${result}`);
//       let resultArray: string[] = JSON.parse(result);
//       myDormitory.AreaId = resultArray[0].toString();
//       myDormitory.Area = resultArray[1].toString();
//       webviewController.runJavaScript('var selectElement = document.getElementById("building"); ' +
//         '[selectElement.value, selectElement.options[selectElement.selectedIndex].text];').then((result) => {
//         if (result) {
//           console.info(`The test() return value is: ${result}`);
//           let resultArray: string[] = JSON.parse(result);
//           myDormitory.BuildingId = resultArray[0].toString();
//           myDormitory.Building = resultArray[1].toString();
//           webviewController.runJavaScript('var selectElement = document.getElementById("roomid"); ' +
//             '[selectElement.value, selectElement.options[selectElement.selectedIndex].text];').then((result) => {
//             if (result) {
//               console.info(`The test() return value is: ${result}`);
//               let resultArray: string[] = JSON.parse(result);
//               myDormitory.RoomId = resultArray[0].toString();
//               myDormitory.Room = resultArray[1].toString();
//               webviewController.runJavaScript('var selectElement = document.getElementById("floorid"); ' +
//                 '[selectElement.value, selectElement.options[selectElement.selectedIndex].text];').then((result) => {
//                 if (result) {
//                   console.info(`The test() return value is: ${result}`);
//                   let resultArray: string[] = JSON.parse(result);
//                   myDormitory.FloorId = resultArray[0].toString();
//                   myDormitory.Floor = resultArray[1].toString();
//                   webviewController.runJavaScript('document.getElementById("RemainPower").outerText').then((result) => {
//                     if (result) {
//                       remainPower = result;
//                       webviewController.runJavaScript('document.getElementById("MeterOverdue").outerText')
//                         .then((result) => {
//                           if (result) {
//                             remainMoney = result;
//                             console.info(JSON.stringify(myDormitory))
//                             console.info('INSERT INTO DormitoryLocation (Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId, ElectricFee, RemainingElectric)\n' +
//                               'VALUES (' + myDormitory.Area + ',' +
//                               '' + myDormitory.AreaId + ',' +
//                               '' + myDormitory.Building + ',' +
//                               '' + myDormitory.BuildingId + ',' +
//                               '' + myDormitory.Floor + ',' +
//                               '' + myDormitory.FloorId + ',' +
//                               '' + myDormitory.Room + ',' +
//                               '' + myDormitory.RoomId + ',' +
//                               '' + remainMoney + ',' +
//                               '' + remainPower + ');')
//                             DBUtil.getInstance().creatTable('INSERT INTO DormitoryLocation (Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId, ElectricFee, RemainingElectric)\n' +
//                               'VALUES ('+myDormitory.Area+ ',' +
//                               ''+myDormitory.AreaId+',' +
//                               ''+myDormitory.Building+',' +
//                               ''+myDormitory.BuildingId+',' +
//                               ''+myDormitory.Floor+',' +
//                               ''+myDormitory.FloorId+',' +
//                               ''+myDormitory.Room+',' +
//                               ''+myDormitory.RoomId+',' +
//                               ''+remainMoney+',' +
//                               ''+remainPower+');')
//                           }
//                         })
//                     }
//                   })
//                 }
//               })
//             }
//           })
//         }
//       })
//     }
//   })
//
// }

async function getSelectValue(selectId: string, webviewController: webview.WebviewController): Promise<string[]> {
  const result: string = await webviewController.runJavaScript(`var selectElement = document.getElementById("${selectId}"); [selectElement.value, selectElement.options[selectElement.selectedIndex].text];`);
  if (result) {
    console.info(`The ${selectId} return value is: ${result}`);
    return JSON.parse(result);
  }
  return [];
}

export async function importElectricity(webviewController: webview.WebviewController): Promise<boolean> {
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

  const insertQuery = `INSERT INTO DormitoryLocation (Area, AreaId, Building, BuildingId, Floor, FloorId, Room, RoomId, ElectricFee, RemainingElectric)
                         VALUES ('${myDormitory.Area}', '${myDormitory.AreaId}', '${myDormitory.Building}', '${myDormitory.BuildingId}',
                                 '${myDormitory.Floor}', '${myDormitory.FloorId}', '${myDormitory.Room}', '${myDormitory.RoomId}',
                                 '${remainMoney}', '${remainPower}');`;

  console.info(insertQuery)
  DBUtil.getInstance().creatTable(insertQuery);

  return true;
}
