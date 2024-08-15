import { ServiceUrl } from './ServiceUrl';

export class ServiceBannerClass implements ServiceUrl {
  id: string = '';
  imageSrc: string = '';
  url: string = '';

  constructor(id: string, imageSrc: string, url: string) {
    this.id = id;
    this.imageSrc = imageSrc;
    this.url = url;
  }
}