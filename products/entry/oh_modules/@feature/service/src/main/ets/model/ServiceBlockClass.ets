import { ServiceUrl } from '@ohos/utils';

export class ServiceBlockClass implements ServiceUrl {
  title: string = '';
  url: string = '';

  constructor(title: string, url: string) {
    this.title = title;
    this.url = url;
  }
}