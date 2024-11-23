import { WebUrl } from '@ohos/utils';

export class WorkHallUrl implements WebUrl {
  url: string;

  constructor(url: string) {
    this.url = url;
  }
}