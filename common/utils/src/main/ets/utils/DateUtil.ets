export class  DateUtil extends Date {
  public getWeeksBetweenDates(startDate: string, endDate: string): number {
    const start = new Date(startDate);
    const end = new Date(endDate);
    const timeDifference = end.getTime() - start.getTime();
    const oneWeekInMs = 7 * 24 * 60 * 60 * 1000;
    const weeks = Math.ceil(timeDifference / oneWeekInMs)
    if (weeks === 0) {
      return weeks + 1;
    } else {
      return weeks;
    }
  }

  public getToday() {
    return this.getFullYear().toString() + '/' + (this.getMonth() + 1).toString() + '/' + this.getDate().toString();
  }

}


