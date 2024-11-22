@Component
export struct UserHead {
  @StorageProp('isLogged') isLogged: boolean = false;
  @StorageProp('username') username: string | null = null;

  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
        .fontSize($r('app.float.user_item_image_height'))
        .fontColor([$r('app.color.whut_blue')])
        .margin($r('app.float.md_padding_margin'))
      Column() {
        Text(this.isLogged ? this.username : $r('app.string.default_user_name'))
          .fontSize($r('app.float.user_item_name_size'))
          .lineHeight($r('app.float.normal_text_line_height'))
        Text($r('app.string.user_default_description'))
          .fontSize($r('app.float.user_item_description_size'))
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight($r('app.float.light_text_line_height'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
  }
}