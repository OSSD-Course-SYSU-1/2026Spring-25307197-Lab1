import { SheetCallbacks } from '../../types/Types';
import { DatePickerComponent } from '../components/DateTimePicker';
import { menuBuilder } from '../builder/MenuBuilder';
import { CustomIcon } from '@ohos_agcit/daily_schedule_component_lib';
import { AddTodoVM } from '../../mock/TodoInfoVM'

@Builder
export function addTodoTaskBuilder(callbacks: SheetCallbacks) {
  AddTodoTaskSheet({
    onConfirm: callbacks.onConfirm,
    onClose: callbacks.onClose
  });
}

@ComponentV2
export struct AddTodoTaskSheet {
  vm: AddTodoVM = AddTodoVM.instance
  @Param showRemind: boolean = false
  @Param onConfirm: () => void = () => {
  };
  @Param onClose: () => void = () => {
  };
  @Local
  repetitionMenuItems: string[] =
    ['不重复', '每天', '工作日', '自定义'];
  customRepeatData: string[] = [
    '周一', '周二', '周三', '周四', '周五', '周六', '周日'
  ]
  remindMenuItems: string[] =
    ['不提醒', '当天（09：00）', '提前一天（09：00）', '提前两天（09：00）', '提前三天（09：00）', '提前一周（09：00）']
  priorityMenuItems: string[] = ['无', '低优先级', '中优先级', '高优先级']
  @Local showRepeat: boolean = false;
  @Local repeatDay: string = ''

  @Builder
  customRepeat() {
    Column() {
      Row() {
        Text('重复频率：周')
          .fontColor('rgba(0, 0, 0, 0.9)')
          .fontSize($r('sys.float.Body_L'))
        Text('可多选')
          .fontColor('rgba(0, 0, 0, 0.4)')
          .fontSize($r('sys.float.Body_S'))
          .margin({
            left: 12
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({
        bottom: 12
      })

      GridRow({ columns: 3, gutter: 8 }) {
        ForEach(this.customRepeatData, (item: string, index: number) => {
          GridCol({ span: 1 }) {
            Button(item)
              .height(28)
              .width('100%')
              .backgroundColor(this.vm.repetitionMultiType.indexOf(index) !== -1 ? 'rgb(100, 187, 92)' :
                'rgba(0, 0, 0, 0.05)')
              .fontColor(this.vm.repetitionMultiType.indexOf(index) !== -1 ? 'rgb(255, 255, 255)' : 'rgba(0, 0, 0, 0.9)')
              .onClick(() => {
                const num = this.vm.repetitionMultiType.indexOf(index);
                if (num !== -1) {
                  this.vm.repetitionMultiType.splice(num, 1)
                } else {
                  this.vm.repetitionMultiType.push(index);
                }
                const dayArr = this.vm.repetitionMultiType.map((item: number) => this.customRepeatData[item])
                this.repeatDay = dayArr.join('、')
                this.vm.repetitionType = 4;
              })
          }

        }, (item: string) => item)
      }
    }
    .margin({
      left: 16,
      right: 16,
      top: 20
    })
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Row() {
        CustomIcon({
          resource: $r('sys.symbol.xmark'),
          size: 40,
          fontSize: 20,
          fontColor: $r('sys.color.font_primary'),
          onClick: this.onClose
        })
        Text('添加待办')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .margin({ left: '2.5%' })
        Blank()
        CustomIcon({
          resource: $r('sys.symbol.checkmark'),
          size: 45,
          fontSize: 25,
          fontColor: $r('sys.color.font_primary'),
          onClick: this.onConfirm
        })
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .width('100%')
      .height('12%')
      .padding({ left: '5%', right: '5%' })

      Column() {
        TextArea({ placeholder: '请输入待办内容' })
          .backgroundColor(Color.Transparent)
          .placeholderFont({ weight: 600 })
          .width('100%')
          .height('100%')
          .maxLength(50)
          .showCounter(true, { thresholdPercentage: 1, highlightBorder: true })
          .onChange((value: string) => {
            this.vm.title = value;
          })
      }
      .borderRadius(16)
      .width('90%')
      .height('15%')
      .backgroundColor($r('sys.color.background_primary'))

      DatePickerComponent()
        .margin({ top: '5%' })
        .width('90%')

      Column() {
        Row() {
          Text('重复').fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium)
          Blank()
          Row() {
            Row() {
              Text(this.repetitionMenuItems[this.vm.repetitionType] || this.repeatDay)
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ right: 5 })
              Image($r("app.media.icon_arrow_bottom")).height(6).width(8)
            }
            .bindMenu(menuBuilder(this.repetitionMenuItems, (newIndex: number) => {
              if (newIndex === 3) {
                this.showRepeat = true;
                return;
              }
              this.vm.repetitionType = newIndex;
            }))
          }.layoutWeight(1)
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .height('8%')
        .bindSheet($$this.showRepeat, this.customRepeat(), {
          height: 300,
          title: {
            title: '重复'
          }
        })

        if (this.showRemind) {
          Divider().strokeWidth('1px')
          Row() {
            Text('提醒').fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium)
            Blank()
            Row() {
              Text(this.remindMenuItems[this.vm.reminderType])
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ right: 5 })
              Image($r("app.media.icon_arrow_bottom")).height(6).width(8)
            }
            .bindMenu(menuBuilder(this.remindMenuItems, (newIndex: number) => {
              this.vm.reminderType = newIndex
            }))
          }
          .height('8%')
          .width('100%')
        }
      }
      .borderRadius(16)
      .width('90%')
      .margin({ top: '5%' })
      .padding({ left: 12, right: 12 })
      .backgroundColor($r('sys.color.background_primary'))
      .justifyContent(FlexAlign.SpaceEvenly)

      Row() {
        Text('优先级').fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium)
        Blank()
        Row() {
          Text(this.priorityMenuItems[this.vm.priorityType])
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ right: 5 })
          Image($r("app.media.icon_arrow_bottom")).height(6).width(8)
        }
        .bindMenu(menuBuilder(this.priorityMenuItems, (newIndex: number) => {
          this.vm.priorityType = newIndex
        }))
      }
      .width('90%')
      .height('8%')
      .margin({ top: '2.5%' })
      .padding({ left: 12, right: 12 })
      .borderRadius(16)
      .backgroundColor($r('sys.color.background_primary'))

    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%')
  }
}