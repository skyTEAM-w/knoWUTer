import { ServiceUrl } from '@ohos/utils/src/main/ets/model/ServiceUrl';
import { ServiceShowType, ServiceType } from '@ohos/utils';

export class ServiceListClass implements ServiceUrl {
  serviceName: string = '';
  url: string = '';
  serviceType: ServiceType = ServiceType.NULL;
  imageUrl: string = '';
  inMainPage: ServiceShowType = ServiceShowType.FALSE;

  constructor(serviceName: string, url: string, serviceType: ServiceType, imageUrl: string,
    inMainPage: ServiceShowType) {
    this.serviceName = serviceName;
    this.url = url;
    this.serviceType = serviceType;
    this.imageUrl = imageUrl;
    this.inMainPage = inMainPage;
  }
}