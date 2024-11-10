import { JSON } from '@kit.ArkTS';
import { HttpUtil } from '@ohos/network';
import { FormEncoder } from '@ohos/httpclient';
import { Course, HttpResponseBody, Term } from '../model/Course';
import { LazyDataSource } from '@ohos/utils';

const TAG = '[ScheduleNetFunc]'

export class ScheduleNetFunc {
  public async getSchedule(cookie: string, termCode?: string) {
    let formEncoder = new FormEncoder.Builder().add("termCode", "2024-2025-1").build();
    let feBode = formEncoder.createRequestBody();
    let response = await HttpUtil.getInstance()
      .HttpPost('https://jwxt.whut.edu.cn/jwapp/sys/homeapp/api/home/student/courses.do', cookie, feBode);
    console.debug(TAG, response?.result)
    if (response) {
      let httpCourse: HttpResponseBody = JSON.parse(response.result) as HttpResponseBody;
      let courseList: LazyDataSource<Course> = new LazyDataSource();
      httpCourse.datas.forEach((value: object) => {
        courseList.pushData(value as Course);
      })
      console.debug(TAG, 'getSchedule', JSON.stringify(courseList));
      return courseList;
    }
    return undefined;
  }

  public async getTermCode(cookie: string) {
    let response = await HttpUtil.getInstance()
      .HttpGet('https://jwxt.whut.edu.cn/jwapp/sys/homeapp/api/home/kb/xnxq.do', cookie);
    console.debug(TAG, response?.result)
    if (response) {
      let httpTerm: HttpResponseBody = JSON.parse(response.result) as HttpResponseBody;
      let term: Term | undefined = undefined;
      for (let index = 0; index < httpTerm.datas.length; index++) {
        if ((httpTerm.datas[index] as Term).selected === 'true') {
          term = (httpTerm.datas[index] as Term);
          break;
        }
      }
      return term;
    }
    return undefined;
  }

  public async checkJWXTLoginStatus() {
    let cookie = AppStorage.get<string>('schedule_cookie') || '';
    let response = await HttpUtil.getInstance()
      .HttpGet('https://jwxt.whut.edu.cn/jwapp/sys/homeapp/api/home/kb/xnxq.do', cookie);
    if (response && response.getBody().toString().search('登录') > 0) {
      return false;
    }
    return true;
  }
}