@Builder
export function menuBuilder(menuItems: string[], onIndexChange?: (newIndex: number) => void) {
  AddTodoMenu({ menuItems: menuItems, onIndexChange: onIndexChange });
}

@ComponentV2
struct AddTodoMenu {
  @Param menuItems: string[] =
    ['不重复', '当天（09：00）', '提前一天（09：00）', '提前两天（09：00）', '提前三天（09：00）', '提前一周（09：00）']
  @Local currentIndex: number = 0
  @Event onIndexChange: (newIndex: number) => void;

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      ForEach(this.menuItems, (item: string, index) => {
        Column() {
          // 文字
          Text(item)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
            .width('100%')
            .textAlign(TextAlign.Start)
          // 分隔线
          if (index != this.menuItems.length - 1) {
            Blank()
            Divider().strokeWidth('1px').width('90%').align(Alignment.Start).margin({ top: 15 })
          }
        }
        .onClick(() => {
          this.onIndexChange(index)
        })
        .borderColor(Color.Pink)
        .width('100%')
        .padding({
          left: 10,
          right: 10,
          top: 20,
          bottom: 10
        })
        .height(50)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      },(item: string)=>JSON.stringify(item))
    }
    .width(200)
  }
}