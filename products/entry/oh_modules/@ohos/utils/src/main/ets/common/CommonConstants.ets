import { curves } from '@kit.ArkUI';

export class CommonConstants {
  static readonly SWIPER_DEFAULT_WIDTH: string = '66%';
  static readonly FULL_PERCENT: string = '100%';
  static readonly HALF_PERCENT: string = '50%';
  static readonly IMAGE_CONTAINER_HEIGHT: string = '42%';
  static readonly FULL_SIZE: string = '100%';
  static readonly ICON_SIZE: string = '40%';
  static readonly BAR_WEIGHT: string = '25%';
  static readonly BAR_HEIGHT: string = '10%';
  static readonly CONTENT_WIDTH_PERCENT: string = '87%';
  static readonly SEARCHBAR_WIDTH: string = '91.1%'
  static readonly IMAGE_HEIGHT_MIN: string = '78%';
  static readonly DEVICE_DPI: number = 160;
  static readonly VERY_SHORT_ANIMATION_DURATION: number = 200;
  static readonly SHORT_ANIMATION_DURATION: number = 250;
  static readonly NORMAL_ANIMATION_DURATION: number = 300;
  static readonly MEDIUM_ANIMATION_DURATION: number = 350;
  static readonly NORMAL_ANIMATION_DELAY: number = 30;
  static readonly SHORT_ANIMATION_DELAY: number = 20;
  static readonly NORMAL_SPRING_CURVE: ICurve = curves.springMotion(0.35, 0.55)
  static readonly MEDIUM_SPRING_CURVE: ICurve = curves.springMotion(0.30, 0.45)
  static readonly FULL_SCALE: ScaleOptions = { x: 1, y: 1 };
  static readonly SCHEDULE_BOTTOM_INDEX = 0;
  static readonly HOME_BOTTOM_INDEX = 2;
  static readonly TOOL_BOTTOM_INDEX = 3;
  static readonly USER_BOTTOM_INDEX = 4;
}

