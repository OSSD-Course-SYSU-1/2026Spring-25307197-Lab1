import { CardListComponent } from '../view/CardListComponent';
import { TodoItem } from '@ohos_agcit/daily_schedule_component_lib';

let storageLocal = new LocalStorage();

@Entry(storageLocal)
@Component
struct Calendar4x2Card {
  @LocalStorageProp('titles') titles: Array<string> = [];
  @State currentDate: string = '--';
  @State currentDay: string = '--';
  @State yearMonth: string = '--';
  readonly actionType = 'router';
  readonly abilityName = 'EntryAbility';
  readonly message = 'CalendarCard';

  aboutToAppear(): void {
    this.updateCalendarData();
  }

  updateCalendarData(): void {
    const now = new Date();
    const month = now.getMonth() + 1;
    const date = now.getDate();
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

    this.yearMonth = `${now.getFullYear()}年${month}月${date}日`;
    this.currentDay = weekdays[now.getDay()];
  }

  truncateText(text: string): string {
    if (!text) {
      return '';
    }
    if (text.length <= 20) {
      return text;
    }
    return text.substring(0, 20) + '...';
  }

  @Builder
  calendarContentBuilder() {
    Column() {
      // 日期信息 - 靠左展示
      Column() {
        // 第一行：年月日
        Text(this.yearMonth)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor('rgb(0,0,0,0.9)')
          .width('100%')
          .textAlign(TextAlign.Start)
          .height(19)

        // 第二行：星期 - 靠左展示
        Text(this.currentDay)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Normal)
          .fontColor('rgba(0,0,0,0.9)')
          .width('100%')
          .textAlign(TextAlign.Start)
          .height(16)
          .margin({ top: 2 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 待办事项区域 - 最多4行，每行20字符
      Column() {
        if (this.titles.length > 0) {
          // 显示最多4个待办事项，没有勾选框
          ForEach(this.titles.slice(0, 4), (item: string, index: number) => {
            Text(this.truncateText(item))
              .fontSize($r('sys.float.Body_S'))
              .fontColor('rgba(0,0,0,0.8)')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .textAlign(TextAlign.Start)
              .height(18)
              .margin({ bottom: 8 })
          }, (item: TodoItem) => JSON.stringify(item))
        } else {
          // 无待办事项显示
          Column() {
            Image($r('app.media.daiban'))
              .width(24)
              .height(24)
              .margin({ bottom: 6 })

            Text('暂无待办事项')
              .fontSize(11)
              .fontColor('rgba(0,0,0,0.4)')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 12 })
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
    .padding({ bottom: 16 })
    .justifyContent(FlexAlign.Start)
  }

  build() {
    Row() {
      CardListComponent() {
        this.calendarContentBuilder();
      }
    }
    .height('100%')
    .width('100%')
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          message: this.message,
          targetPage: 'CalendarPage'
        }
      });
    })
  }
}