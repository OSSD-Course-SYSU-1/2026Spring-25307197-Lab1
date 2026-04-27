import { FormatUtil } from '@ohos_agcit/daily_schedule_common_lib';
import { curves } from '@kit.ArkUI';
import {AddTodoVM} from '../../mock/TodoInfoVM'

@ComponentV2
export struct DatePickerComponent {
  vm: AddTodoVM = AddTodoVM.instance
  @Local isDatePickerFocus: boolean = false;
  @Local isTimePickerFocus: boolean = false;

  build() {
    Column() {
      Row() {
        Text('时间').fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium)
        Blank()
        Button(FormatUtil.formatTimeToCN(this.vm.selectedTime))
          .height(28)
          .width(140)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.isDatePickerFocus ? $r('sys.color.multi_color_04') : $r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.background_secondary'))
          .onClick(() => {
            this.isDatePickerFocus = !this.isDatePickerFocus
            if (this.isTimePickerFocus) {
              this.isTimePickerFocus = false;
            }
          })
        Blank().width(5)
        Button(FormatUtil.formatDate(this.vm.selectedTime, FormatUtil.DATE_24H_mm))
          .height(28)
          .width(70)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.isTimePickerFocus ? $r('sys.color.multi_color_04') : $r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.background_secondary'))
          .onClick(() => {
            this.isTimePickerFocus = !this.isTimePickerFocus
            if (this.isDatePickerFocus) {
              this.isDatePickerFocus = false;
            }
          })
      }
      .margin({ bottom: '3%' })
      .height(48)
      .width('100%')

      if (this.isExpand()) {
        Divider()
          .strokeWidth('1px')
          .width('95%')
          .color($r('sys.color.comp_divider'))
          .margin({ bottom: '2.5%' });
      }
      if (this.isDatePickerFocus) {
        // 日期选择器
        DatePicker({
          start: new Date('1970-1-1'),
          end: new Date('2100-1-1'),
          selected: this.vm.selectedTime
        })
          .height(180)
          .expandSafeArea()
          .textStyle({
            font: {
              size: $r('sys.float.Subtitle_M'),
              weight: FontWeight.Normal
            },
            color: $r('sys.color.font_primary')
          })
          .selectedTextStyle({
            color: $r('sys.color.multi_color_04'),
            font: {
              size: $r('sys.float.Title_S'),
              weight: FontWeight.Bold
            }
          })
          .lunar(false)
          .onDateChange((value: Date) => {
            this.vm.selectedTime = value
            console.info('select current date is: ' + value.toString());
          })
      }
      if (this.isTimePickerFocus) {
        // 时间选择器
        TimePicker({
          selected: this.vm.selectedTime
        })
          .height(180)
          .textStyle({
            font: {
              size: $r('sys.float.Subtitle_M'),
              weight: FontWeight.Normal
            },
            color: $r('sys.color.font_primary')
          })
          .selectedTextStyle({
            color: $r('sys.color.multi_color_04'),
            font: {
              size: $r('sys.float.Subtitle_M'),
              weight: FontWeight.Bold
            }
          })
          .useMilitaryTime(true)
          .onChange((value: TimePickerResult) => {
            if (value.hour >= 0) {
              this.vm.selectedTime.setHours(value.hour, value.minute);
              console.info('select current time is: ' + JSON.stringify(value));
            }
          })
      }
    }
    .padding({left: 12, right: 12})
    .height(this.isExpand() ? 48 + 216 : 48)
    .width('100%')
    .animation({ duration: 500, curve: curves.springMotion() })
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
  }

  private isExpand(): boolean {
    return this.isDatePickerFocus || this.isTimePickerFocus;
  }
}