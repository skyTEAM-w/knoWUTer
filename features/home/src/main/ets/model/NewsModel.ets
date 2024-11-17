import { LazyDataSource } from "@ohos/utils";
import { News } from "./News";

export class NewsModel {
  private static instance: NewsModel;

  newsList: LazyDataSource<News> = new LazyDataSource();

  public static getInstance() {
    if (!NewsModel.instance) {
      NewsModel.instance = new NewsModel();
    }
    return NewsModel.instance;
  }

}