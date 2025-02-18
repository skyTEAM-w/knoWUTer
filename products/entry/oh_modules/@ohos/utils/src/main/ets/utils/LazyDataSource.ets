class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return 0;
  }

  getData(index: number): T | undefined {
    return undefined;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}

@Observed
export default class LazyDataSource<T> extends BasicDataSource<T> {
  dataArray: T[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): T {
    return this.dataArray[index];
  }

  public addData(index: number, data: T): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: T): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public pushArrayData(newData: Array<T>): void {
    this.clear();
    this.dataArray.push(...newData);
    this.notifyDataReload();
  }

  public appendArrayData(addData: Array<T>): void {
    this.dataArray.push(...addData);
    this.notifyDataReload();
  }

  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  public changeData(index: number, data: T): void {
    this.dataArray.splice(index, 1, data);
    this.notifyDataChange(index);
  }

  public reloadData(): void {
    this.notifyDataReload();
  }

  public getDataList(): Array<T> {
    return this.dataArray;
  }

  public clear(): void {
    this.dataArray.splice(0, this.dataArray?.length);
  }

  public isEmpty(): boolean {
    return this.dataArray.length === 0;
  }
}
