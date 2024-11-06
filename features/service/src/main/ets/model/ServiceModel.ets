import LazyDataSource from '@ohos/utils/src/main/ets/utils/LazyDataSource';
import { ServiceBannerClass } from './ServiceBannerClass';
import { ServiceBlockClass } from './ServiceBlockClass';
import { ServiceListClass } from './ServiceListClass';

@Observed
export class ServiceModel {
  private static instance: ServiceModel;
  swiperData: ServiceBannerClass[] = [];
  blockData: LazyDataSource<ServiceBlockClass> = new LazyDataSource();
  listData: LazyDataSource<ServiceListClass> = new LazyDataSource();

  public static getInstance(): ServiceModel {
    if (!ServiceModel.instance) {
      ServiceModel.instance = new ServiceModel();
    }
    return ServiceModel.instance;
  }

  getServiceResource() {

  }
}