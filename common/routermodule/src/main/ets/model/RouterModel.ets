import { RouterModule } from '../utils/RouterModule';

export class RouterModel {
  builderName: string = "";
  routerName: string = "";
  param?: object = new Object();
}

export function buildRouterModel(routerName: string, builderName: string, param?: object) {
  let router: RouterModel = new RouterModel();
  router.builderName = builderName;
  router.routerName = routerName;
  router.param = param;
  RouterModule.push(router);
}

