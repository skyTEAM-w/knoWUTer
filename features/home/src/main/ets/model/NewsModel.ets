import { LazyDataSource, LoadingStatus } from '@ohos/utils';
import { NewsNetFunc } from '../service/NewsNetFunc';
import { GrabNews, News, NewsType } from './News';
import { JSON } from '@kit.ArkTS';
import { PreferencesUtil } from '@ohos/datastore/src/main/ets/datasotore/PreferencesUtil';

const TAG = '[NewsModel]'

const ZHLGD_COOKIE = 'zhlgd_cookie';

@Observed
export class NewsModel {
  private static instance: NewsModel;
  newsList: LazyDataSource<News> = new LazyDataSource();
  comprehensiveNews: LazyDataSource<News> = new LazyDataSource();
  schoolAnnouncements: LazyDataSource<News> = new LazyDataSource();
  departmentNews: LazyDataSource<News> = new LazyDataSource();
  collegeAnnouncements: LazyDataSource<News> = new LazyDataSource();
  academicLectures: LazyDataSource<News> = new LazyDataSource();
  collegeNews: LazyDataSource<News> = new LazyDataSource();
  loadingStatus: LoadingStatus = LoadingStatus.OFF
  private networkFun: NewsNetFunc;

  private constructor() {
    this.networkFun = new NewsNetFunc();
  }

  public static getInstance() {
    if (!NewsModel.instance) {
      NewsModel.instance = new NewsModel();
    }
    return NewsModel.instance;
  }

  getNewsResources(cookie: string): Promise<void> {
    this.loadingStatus = LoadingStatus.LOADING;
    return new Promise((resolve, reject) => {
      this.networkFun.getGrabNews(cookie).then((data: GrabNews[]) => {
        data.forEach((value: GrabNews) => {
          switch (value.type) {
            case NewsType.COMPREHENSIVE_NEWS: {
              this.comprehensiveNews.pushArrayData(value.news);
              break;
            }
              ;
            case NewsType.SCHOOL_ANNOUNCEMENTS: {
              this.schoolAnnouncements.pushArrayData(value.news);
              break;
            }
              ;
            case NewsType.DEPARTMENT_NEWS: {
              this.departmentNews.pushArrayData(value.news);
              break;
            }
              ;
            case NewsType.COLLEGE_ANNOUNCEMENTS: {
              this.collegeAnnouncements.pushArrayData(value.news);
              break;
            }
            case NewsType.ACADEMIC_LECTURES: {
              this.academicLectures.pushArrayData(value.news);
              break;
            }
              ;
            case NewsType.COLLEGE_NEWS: {
              this.collegeNews.pushArrayData(value.news);
              break;
            }
          }
        })
        console.debug(TAG, JSON.stringify(this.comprehensiveNews))
        this.loadingStatus = LoadingStatus.SUCCESS;
        resolve();
      }).catch((err: Error) => {
        this.loadingStatus = LoadingStatus.FAILED;
        reject();
      });
    });
  }

  checkZHLGDCookie(): Promise<string | null> {
    return PreferencesUtil.getInstance().getValue<string>(ZHLGD_COOKIE)
  }
}