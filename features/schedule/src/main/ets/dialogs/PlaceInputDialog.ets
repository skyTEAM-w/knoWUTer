@CustomDialog
@Component
export struct PlaceInputDialog {
  @Link coursePlace: string;
  @State campusName: string | null = null;
  @State buildingName: string | null = null;
  @State classroomName: string | null = null;
  controller?: CustomDialogController;
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  aboutToAppear(): void {
    const placeList = this.coursePlace.split('-');
    this.campusName = placeList[0] === 'undefined' ? null : placeList[0];
    this.buildingName = placeList[1] === 'undefined' ? null : placeList[1];
    this.classroomName = placeList[2] === 'undefined' ? null : placeList[2];
  }

  buildCoursePlace() {
    return [this.campusName ? this.campusName : 'undefined', this.buildingName ? this.buildingName : 'undefined',
      this.classroomName ? this.classroomName : 'undefined'].join('-');
  }

  build() {
    Column() {
      Text('上课地点')
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .margin({ top: 10, bottom: 10 })
      Column({ space: 10 }) {
        Row() {
          Text('校区: ')
          TextInput({
            placeholder: '校区',
            text: this.campusName
          })
            .cancelButton({
              style: CancelButtonStyle.INPUT,
              icon: {
                size: 24,
                src: $r('sys.symbol.xmark')
              }
            })
            .onChange((value: string) => {
              this.campusName = value;
            })
            .width('80%')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('教学楼: ')
          TextInput({
            placeholder: '教学楼',
            text: this.buildingName
          })
            .cancelButton({
              style: CancelButtonStyle.INPUT,
              icon: {
                size: 24,
                src: $r('sys.symbol.xmark')
              }
            })
            .onChange((value: string) => {
              this.buildingName = value;
            })
            .width('80%')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('教室: ')
          TextInput({
            placeholder: '教室',
            text: this.classroomName
          })
            .cancelButton({
              style: CancelButtonStyle.INPUT,
              icon: {
                size: 24,
                src: $r('sys.symbol.xmark')
              }
            })
            .onChange((value: string) => {
              this.classroomName = value;
            })
            .width('80%')
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
            this.coursePlace = this.buildCoursePlace()
            this.controller?.close()
          }).backgroundColor(Color.Transparent).fontColor($r('sys.color.brand_font'))
      }
      .margin({ bottom: 10, top: 10 })
      .justifyContent(FlexAlign.SpaceAround)
    }
  }
}