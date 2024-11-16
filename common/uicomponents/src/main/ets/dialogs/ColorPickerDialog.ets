@CustomDialog
@Component
export struct  ColorSelectDialog {
  @Link color: ResourceColor;
  @State selectedColor: ResourceColor = 'rgba(255, 255, 255, 0.5)';
  @State @Watch('changeColor') red: number = 0;
  @State @Watch('changeColor') green: number = 0;
  @State @Watch('changeColor') blue: number = 0;
  @State @Watch('changeColor') alpha: number = 0;
  controller?: CustomDialogController;
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  aboutToAppear(): void {
    this.selectedColor = this.color;
    console.debug(this.color.toString())
    this.hexToARGB(this.color.toString());
  }

  hexToARGB(hex: string) {
    if (!hex) {
      this.alpha = 0.5
      this.red = 255
      this.green = 0
      this.blue = 0
    } else {
      const color = hex.replace("#", "");
      this.alpha = parseInt(color.substring(0,2), 16) / 256.0;
      this.red = parseInt(color.substring(2,4), 16);
      this.green = parseInt(color.substring(4,6), 16);
      this.blue = parseInt(color.substring(6,8), 16);
    }
  }

  argbToHex() {
    const r = parseInt(this.red.toString());
    const g = parseInt(this.green.toString());
    const b = parseInt(this.blue.toString());
    const a = parseInt(Math.round(this.alpha * 255).toString());
    console.debug('', r, g, b, a)
    const hex = `#${a.toString(16).padStart(2, '0')}${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`
    return hex;
  }

  changeColor() {
    this.selectedColor = `rgba(${this.red}, ${this.green}, ${this.blue}, ${this.alpha})`;
  }

  build() {
    Column() {
      Text('颜色调整')
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .margin({ top: 10, bottom: 10 })
      Stack() {
        Rect()
          .width('90%')
          .height(33)
          .fill(this.selectedColor)
          .radius(8)
        Row() {
          Text('示例文本')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor(Color.White)
        }
        .justifyContent(FlexAlign.Center)
        .width('90%')
        .height(33)
      }
      .alignContent(Alignment.Center)
      Column(){
        Row() {
          Text('R')
          Slider({
            value: $$this.red,
            min: 0,
            max: 255,
            step: 1,
            style: SliderStyle.OutSet
          }).width('80%')
          Text(this.red.toString())
            .width(44)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text('G')
          Slider({
            value: $$this.green,
            min: 0,
            max: 255,
            step: 1,
            style: SliderStyle.OutSet
          }).width('80%')
          Text(this.green.toString())
            .width(44)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text('B')
          Slider({
            value: $$this.blue,
            min: 0,
            max: 255,
            step: 1,
            style: SliderStyle.OutSet
          }).width('80%')
          Text(this.blue.toString())
            .width(44)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text('A')
          Slider({
            value: $$this.alpha,
            min: 0,
            max: 1,
            step: 0.01,
            style: SliderStyle.OutSet
          })
            .width('80%')
          Text(this.alpha.toFixed(2))
            .width(44)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .margin({ left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin') })
      Row() {
        Button($r('app.string.cancel'))
          .width('40%')
          .onClick(() => {
            this.controller?.close()
          }).backgroundColor(Color.Transparent).fontColor($r('sys.color.brand_font'))
        Divider()
          .vertical(true)
          .height(33)
        Button($r('app.string.confirm'))
          .width('40%')
          .onClick(() => {
            this.color = this.argbToHex()
            this.controller?.close()
          }).backgroundColor(Color.Transparent).fontColor($r('sys.color.brand_font'))
      }
      .width("100%")
      .margin({ bottom: 10, top: 10 })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .margin({ bottom: 10, top: 10 })
  }
}