import {ServiceUrl} from './ServiceUrl';
import {ServiceType} from '../common/constants/CommonEnums';

export class ServiceListClass implements ServiceUrl {
  serviceName: string = '';
  url: string = '';
  serviceType:ServiceType = ServiceType.NULL;
  imageUrl:string = '';
  inMainPage: boolean = false;

  constructor(serviceName: string, url: string, serviceType: ServiceType, imageUrl: string, inMainPage: boolean) {
    this.serviceName = serviceName;
    this.url = url;
    this.serviceType = serviceType;
    this.imageUrl = imageUrl;
    this.inMainPage = inMainPage;
  }
}