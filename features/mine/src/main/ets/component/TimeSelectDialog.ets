/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { promptAction } from '@kit.ArkUI';
import { BreakPointType, BreakPointTypeEnum, CommonConstants } from '@ohos/utils';

@Component
@CustomDialog
export struct TimeSelectDialog {
  controller: CustomDialogController;
  @Prop currentBreakpoint: string = BreakPointTypeEnum.MD;
  @Prop type: number;
  @Prop compareTime: Date = new Date();
  @Link selectedTime: Date;
  confirm?: () => void;

  build() {
    Row() {
      Column({ space: 12 }) {
        Row() {
          Text(this.type === 0 ? $r('app.string.start_time_des') : $r('app.string.end_time_des'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
        }
        .justifyContent(FlexAlign.Center)
        .height($r('app.float.button_height'))
        .width(CommonConstants.FULL_PERCENT)

        TimePicker({
          selected: this.selectedTime,
        })
          .disappearTextStyle({ color: $r('sys.color.ohos_id_color_text_secondary') })
          .textStyle({ color: $r('sys.color.ohos_id_color_text_primary') })
          .useMilitaryTime(false)
          .onChange((value: TimePickerResult) => {
            if (value.hour >= 0) {
              if (value.hour === this.compareTime.getHours() && value.minute === this.compareTime.getMinutes()) {
                promptAction.showToast({
                  message: $r('app.string.same_time_warning')
                });
                return;
              }
              this.selectedTime.setHours(value.hour, value.minute);
            }
          })
        Row() {
          Button($r('app.string.cancel'))
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .onClick((): void => {
              this.controller.close();
            })
            .layoutWeight(1)
          Divider()
            .margin($r('app.float.sm_padding_margin'))
            .vertical(true)
          Button($r('app.string.confirm'))
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .layoutWeight(1)
            .onClick((): void => {
              if (this.selectedTime === this.compareTime) {
                promptAction.showToast({
                  message: $r('app.string.same_time_warning')
                });
                return;
              }
              this.confirm?.();
              this.controller.close();
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.button_height'))
      }

      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
      .borderRadius($r('app.float.xxl_border_radius'))
      .padding({
        top: $r('app.float.lg_padding_margin'),
        left: $r('app.float.xxl_padding_margin'),
        bottom: $r('app.float.lg_padding_margin'),
        right: $r('app.float.xxl_padding_margin')
      })
    }
    .width(new BreakPointType<Length>({
      sm: CommonConstants.FULL_PERCENT,
      md: $r('app.float.lg_time_picker_dialog_width'),
      lg: $r('app.float.lg_time_picker_dialog_width'),
    }).getValue(this.currentBreakpoint))
    .padding($r('app.float.lg_padding_margin'))
  }
}