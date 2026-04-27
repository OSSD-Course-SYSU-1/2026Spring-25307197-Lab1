import { FormatUtil } from '@ohos_agcit/daily_schedule_common_lib';
import { curves } from '@kit.ArkUI';
import { UpdateTodoPlanTimeVM } from '../../mock/TodoInfoVM';

@ComponentV2
export struct DatePickerUpdater {
  vm: UpdateTodoPlanTimeVM = UpdateTodoPlanTimeVM.instance
  @Local isDatePickerFocus: boolean = true;
  @Local isTimePickerFocus: boolean = false;
  @Param selectedTime: Date = new Date();

  aboutToAppear(): void {
    this.vm.modifyPlanTime = this.selectedTime
  }

  build() {
    Column() {
      Row() {
        Text('时间').fontSize($r('sys.float.Title_S')).fontWeight(600)
        Blank()
        Button(FormatUtil.formatDate(this.selectedTime, FormatUtil.DATE_YYYY_MM_DD))
          .width(120)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.isDatePickerFocus ? $r('sys.color.multi_color_04') : $r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.background_secondary'))
          .onClick(() => {
            this.isDatePickerFocus = !this.isDatePickerFocus
            if (this.isTimePickerFocus) {
              this.isTimePickerFocus = false;
            }
          })
        Button(FormatUtil.formatDate(this.selectedTime, FormatUtil.DATE_24H_mm))
          .width(80)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.isTimePickerFocus ? $r('sys.color.multi_color_04') : $r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.background_secondary'))
          .onClick(() => {
            this.isTimePickerFocus = !this.isTimePickerFocus
            if (this.isDatePickerFocus) {
              this.isDatePickerFocus = false;
            }
          })
          .margin({ left: '1%' })
      }
      .margin({ bottom: '3%' })
      .width('100%')

      Divider()
        .strokeWidth('2vp')
        .width('95%')
        .color($r('sys.color.comp_divider'))
        .margin({ bottom: '2.5%' });

      if (this.isDatePickerFocus) {
        // 日期选择器
        DatePicker({
          start: new Date('1970-1-1'),
          end: new Date('2100-1-1'),
          selected: this.selectedTime
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
            this.vm.modifyPlanTime = value
            console.info('select current date is: ' + value.toString());
          })
      }
      if (this.isTimePickerFocus) {
        // 时间选择器
        TimePicker({
          selected: this.selectedTime
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
              this.vm.modifyPlanTime.setHours(value.hour, value.minute)
              console.info('select current time is: ' + JSON.stringify(value));
            }
          })
      }
    }
    .padding('5%')
    .height(270)
    .animation({ duration: 500, curve: curves.springMotion() })
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
  }
}