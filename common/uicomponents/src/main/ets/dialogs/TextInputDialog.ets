@CustomDialog
@Component
export struct TextInputDialog {
  @Link textValue: string;
  @Link inputValue: string;
  @Prop changeText: string;
  controller?: CustomDialogController;
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text(this.changeText).fontSize(18).margin({ top: 10, bottom: 10 })
      TextInput({ placeholder: this.textValue, text: this.textValue }).height(55).width('90%')
        .onChange((value: string) => {
          this.textValue = value
        })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button($r('app.string.cancel'))
          .width('40%')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
              this.cancel()
            }
          }).backgroundColor(Color.Transparent).fontColor(Color.Red)
        Button($r('app.string.confirm'))
          .width('40%')
          .onClick(() => {
            if (this.controller != undefined) {
              this.inputValue = this.textValue
              this.controller.close()
              this.confirm()
            }
          }).backgroundColor(Color.Transparent).fontColor(Color.Blue)
      }.margin({ top: 5, bottom: 10 })
    }
  }
}