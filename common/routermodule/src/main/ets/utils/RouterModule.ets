import { RouterModel } from '../model/RouterModel';

export class RouterModule {
  static builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>();
  static routerMap: Map<string, NavPathStack> = new Map<string, NavPathStack>();

  public static registerBuilder(builderName: string, builder: WrappedBuilder<[object]>): void {
    RouterModule.builderMap.set(builderName, builder);
  }

  public static getBuilder(builderName: string): WrappedBuilder<[object]> {
    const builder = RouterModule.builderMap.get(builderName);
    if (!builder) {
      console.info('not found builder ' + builderName);
    }
    return builder as WrappedBuilder<[object]>;
  }

  public static createRouter(routerName: string, router: NavPathStack): void {
    RouterModule.routerMap.set(routerName, router);
  }

  public static getRouter(routerName: string): NavPathStack {
    return RouterModule.routerMap.get(routerName) as NavPathStack;
  }

  public static async push(router: RouterModel): Promise<void> {
    const harName = router.builderName.split('_')[0];
    await import(harName).then((ns: ESObject): Promise<void> => ns.harInit(router.builderName));
    RouterModule.getRouter(router.routerName).pushPath({ name: router.builderName, param: router.param });
  }

  public static pop(routerName: string): void {
    RouterModule.getRouter(routerName).pop();
  }

  public static clear(routerName: string): void {
    RouterModule.getRouter(routerName).clear();
  }

  public static popToName(routerName: string, builderName: string): void {
    RouterModule.getRouter(routerName).popToName(builderName);
  }
}