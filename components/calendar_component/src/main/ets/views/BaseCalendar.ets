import { DateModel } from '../models/DateModel';
import { CommonConstants } from '../constants/CommonContants';
import { CalendarUtil } from '../utils/CalendarUtil';
import { TodoItem } from '@ohos_agcit/daily_schedule_component_lib';

@ComponentV2
export struct BaseCalendar {
  @Param index: number = 0
  @Param @Require dataList: DateModel[]
  @Param todoData: Map<string, TodoItem[]> = new Map()

  chooseTextColor(item: DateModel): ResourceColor {
    const dateKey = CalendarUtil.buildKeyByDateModel(item);
    return this.todoData.has(dateKey) ? $r('sys.color.multi_color_04') : $r('sys.color.font_primary');
  }

  build() {
    Column() {
      Text((this.index + 1) + '月')
        .fontSize($r('sys.float.Body_S'))
        .height(16)
        .fontWeight(FontWeight.Bold)
      Blank().height(8)
      
      Grid() {
        ForEach(CommonConstants.weekListFromSunday, (item: string) => {
          GridItem() {
            Text(item)
              .fontColor($r('sys.color.font_primary'))
              .fontSize(8)
              .width(13.14)
              .lineHeight(10)
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Center);
          }
        }, (item: string) => item);
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .columnsGap(2)
      .width('100%')
      .margin({ bottom: 4 })

      Grid() {
        ForEach(this.dataList, (item: DateModel) => {
          GridItem() {
            Column() {
              Text(item.day.toString())
                .textAlign(TextAlign.Center)
                .fontSize(8)
                .fontWeight(FontWeight.Regular)
                .opacity(1)
                .height(10)
                .lineHeight(11)
                .width(10.57)
                .fontColor($r('sys.color.font_primary'))
                .fontColor(this.chooseTextColor(item))
                .opacity(item.isCurrentMonth ? 1 : 0)
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Start)
          }
        })
      }
      .height(80)
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .columnsGap(5)
      .rowsGap(4)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}