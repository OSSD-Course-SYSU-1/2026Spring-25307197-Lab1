import { CustomIcon } from '@ohos_agcit/daily_schedule_component_lib';


@Builder
export function leftSwipeButtonBuilder(onClickDelete?: () => void, onClickModify?: () => void) {
  LeftSwipeButtonBuilder({ onClickDelete: onClickDelete, onClickModify: onClickModify });
}

@ComponentV2
struct LeftSwipeButtonBuilder {
  @Event onClickModify: () => void;
  @Event onClickDelete: () => void;

  build() {
    Row() {
      CustomIcon({
        resource: $r('sys.symbol.calendar_fill'),
        backgroundColor: $r('sys.color.multi_color_02'),
        size: 40,
        fontSize: 25,
        onClick: this.onClickModify
      })
      Blank().width(5)
      CustomIcon({
        resource: $r('sys.symbol.trash_fill'),
        backgroundColor: $r('sys.color.warning'),
        size: 40,
        fontSize: 25,
        onClick: this.onClickDelete
      })
    }
    .padding({ left: 5 })
    .justifyContent(FlexAlign.Start)
    .width(100)
  }
}