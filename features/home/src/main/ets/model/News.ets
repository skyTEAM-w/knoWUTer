import { ObservedArray, WebUrl } from '@ohos/utils';

@Observed
export class News {
  DATE: string = '';
  TITLE: string = '';
  HREF: string = '';
}

export class NewsUrl implements WebUrl {
  url: string = '';

  constructor(url: string) {
    this.url = url;
  }
}

@Observed
export class GrabNews {
  type: string = '';
  news: ObservedArray<News> = new ObservedArray();
}

export const NewsTypeRecord: Record<string, string> = {
  '0010012017': '学院新闻',
  '0010012014': '部门新闻',
  '0010012015': '学术讲座·报告·论坛',
  '0010012016': '学院·所·中心通知公告',
  '0010012012': '学校通知·公告',
  '0010012013': '综合新闻'
}

export enum NewsType {
  COMPREHENSIVE_NEWS = '综合新闻',
  SCHOOL_ANNOUNCEMENTS = '学校通知·公告',
  DEPARTMENT_NEWS = '部门新闻',
  COLLEGE_ANNOUNCEMENTS = '学院·所·中心通知公告',
  ACADEMIC_LECTURES = '学术讲座·报告·论坛',
  COLLEGE_NEWS = '学院新闻'
}