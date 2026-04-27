@ComponentV2
export struct ButtonSelectComponent {
  @Param selectIndex: number = -1;
  @Param buttonLabel: string[] = ['全部', '无', '低优先级', '中优先级', '高优先级']
  @Param areaHeight: number = 200
  @Param changeIndex: (newIndex: number) => void = () => {
  };

  build() {
    GridRow({ columns: 6, gutter: { x: 10, y: 15 } }) {
      ForEach(this.buttonLabel, (item: string, index: number) => {
        GridCol({ span: 2 }) {
          Row() {
            Button(item)
              .width('100%')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor(this.selectIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
              .backgroundColor(this.selectIndex === index ?
              $r('sys.color.multi_color_04') : $r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                this.changeIndex(index)
              })
          }
        }
        .height(30)
      },(item: string)=>JSON.stringify(item))
    }
    .width('100%')
    .height(this.areaHeight)

  }
}