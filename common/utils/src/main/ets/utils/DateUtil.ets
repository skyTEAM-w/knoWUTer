export class  DateUtil extends Date {
  public getWeeksBetweenDates(startDate: string, endDate: string): number {
    let start = new Date(startDate);
    let end = new Date(endDate);

    let differenceInMilliseconds = end.getTime() - start.getTime();
    let differenceInDays = Math.ceil(differenceInMilliseconds / (1000 * 60 * 60 * 24));
    let differenceInWeeks = differenceInDays / 7;

    return Math.ceil(differenceInWeeks);
  }

  public getToday() {
    return this.getFullYear().toString() + '/' + (this.getMonth() + 1).toString() + '/' + this.getDate().toString();
  }

}
