import { mediaquery, window } from '@kit.ArkUI';
import { WindowUtil } from './WindowUtil';

export enum BreakPointTypeEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg'
}
;

export interface BreakPointTypes<T> {
  sm: T;
  md: T;
  lg: T;
}

export class BreakPointType<T> {
  sm: T;
  md: T;
  lg: T;

  constructor(param: BreakPointTypes<T>) {
    this.sm = param.sm;
    this.md = param.md;
    this.lg = param.lg;
  }

  getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === BreakPointTypeEnum.SM) {
      return this.sm;
    }
    if (currentBreakpoint === BreakPointTypeEnum.MD) {
      return this.md;
    }
    return this.lg;
  }
}

export class BreakPointSystem {
  private currenBreakPoint: string = BreakPointTypeEnum.MD;
  private smListener: mediaquery.MediaQueryListener | undefined;
  private mdListener: mediaquery.MediaQueryListener | undefined;
  private lgListener: mediaquery.MediaQueryListener | undefined;

  public register() {
    this.smListener = mediaquery.matchMediaSync('(320vp<=width<600vp)');
    if (this.smListener?.matches) {
      this.updateCurrentBreakPoint(BreakPointTypeEnum.SM);
    }
    this.smListener?.on('change', this.isSM);

    this.mdListener = mediaquery.matchMediaSync('(600vp<=width<840vp)');
    if (this.mdListener?.matches) {
      this.updateCurrentBreakPoint(BreakPointTypeEnum.MD);
    }
    this.mdListener?.on('change', this.isMD);

    this.lgListener = mediaquery.matchMediaSync('(840vp<=width)');
    if (this.lgListener?.matches) {
      this.updateCurrentBreakPoint(BreakPointTypeEnum.LG);
    }
    this.lgListener?.on('change', this.isLG);
  }

  public unregister() {
    this.smListener?.off('change', this.isSM);
    this.mdListener?.off('change', this.isMD);
    this.lgListener?.off('change', this.isLG);
  }

  private updateCurrentBreakPoint(breakPoint: BreakPointTypeEnum) {
    WindowUtil.getDeviceSize(getContext(this));
    if (this.currenBreakPoint !== breakPoint) {
      this.currenBreakPoint = breakPoint;
      console.debug(this.currenBreakPoint)
      AppStorage.setOrCreate<string>('currentBreakPoint', this.currenBreakPoint);
    }
  }

  private isSM = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakPoint(BreakPointTypeEnum.SM);
    }
  }
  private isMD = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakPoint(BreakPointTypeEnum.MD);
    }
  }
  private isLG = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakPoint(BreakPointTypeEnum.LG);
    }
  }
}


