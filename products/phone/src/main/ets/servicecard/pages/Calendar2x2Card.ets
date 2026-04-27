import { CardListComponent } from '../view/CardListComponent';

let storageLocal = new LocalStorage();

@Entry(storageLocal)
@Component
struct Calendar2x2Card {
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
    if (text.length <= 8) {
      return text;
    }
    return text.substring(0, 8) + '...';
  }

  @Builder
  calendarContentBuilder() {
    Column() {
      Column() {
        Text(this.yearMonth)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor('rgb(0,0,0,0.9)')
          .width('100%')
          .textAlign(TextAlign.Start)
          .height(19)

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
      .margin({ bottom: 12 })

      // 待办事项
      Column() {
        if (this.titles.length > 0) {
          ForEach(this.titles.slice(0, 4), (item: string, index: number) => {
            Text(this.truncateText(item))
              .fontSize(11)
              .fontColor('rgba(0,0,0,0.8)')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .textAlign(TextAlign.Start)
              .height(16)
              .margin({ bottom: 6 })
          }, (item: string) => JSON.stringify(item))
        } else {
          Column() {
            Image($r('app.media.daiban'))
              .width(20)
              .height(20)
              .margin({ bottom: 4 })

            Text('暂无待办事项')
              .fontSize(10)
              .fontColor('rgba(0,0,0,0.4)')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 8 })
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
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