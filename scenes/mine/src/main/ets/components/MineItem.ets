import { MinePageCommonService } from '../constants/MineUiConstants';
import {  MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct MineItem {
  @Param @Require commonService: MinePageCommonService;
  @Param @Require appPathStack: NavPathStack
  vm: MainEntryVM = MainEntryVM.instance;


  build() {
    Row() {
      Image($r(this.commonService.icon))
        .width(24)
        .height(24)
        .margin({ left: 12 })
      Text(this.commonService.label)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 16 })
      Blank()
      Image($r('app.media.ic_right_arrow_lined'))
        .width(7)
        .height(14)
        .fillColor($r('sys.color.icon_secondary'))
        .margin({ right: 12 })
    }
    .width('100%')
    .height(46)
    .borderRadius(16)
    .justifyContent(FlexAlign.Start)
    .margin({ top: 12 })
    .onClick(() => {
      this.vm.navStack.pushPathByName(this.commonService.nextPage, undefined);
    })
  }
}


@ComponentV2
export struct ContactItem {
  @Param @Require commonService: MinePageCommonService;
  @Param @Require appPathStack: NavPathStack

  @Local openSheet: boolean = false;
  build() {
    Row() {
      Image($r(this.commonService.icon))
        .width(24)
        .height(24)
        .margin({ left: 12 })
      Text(this.commonService.label)
        .fontSize('sys.float.Body_L')
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 16 })
      Blank()
      Image($r('app.media.ic_right_arrow_lined'))
        .width(7)
        .height(14)
        .fillColor($r('sys.color.icon_secondary'))
        .margin({ right: 12 })
    }
    .width('100%')
    .height(46)
    .borderRadius(16)
    .justifyContent(FlexAlign.Start)
    .margin({ top: 12 })
    .onClick(() => {
      this.openSheet = !this.openSheet
    })
    .bindSheet($$this.openSheet, this.contactBuilder(), {
      title: {title: '联系客服' },
      height: 280,
      width: '100%'
    })
  }

  @Builder
  contactBuilder(){
    Column({ space: 12 }){
      Text('000000')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .padding({
          top: 16
        })

      Button(){
        Row({ space: 4 }){
          Image($r('sys.symbol.phone'))
            .width(14)
            .height(14)
          Text('一键拨号')
            .fontSize('sys.float.Body_L')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
        }
      }
      .backgroundColor('#387BF1')
      .height(40)
      .width('94%')
      .onClick(() => {
        // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
        call.makeCall('000000', (err: BusinessError) => {
          if (!err) {
            console.log('make call success.');
          } else {
            console.log('make call fail, err is:' + JSON.stringify(err));
          }
        });
      })

      Button('取消')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .height(40)
        .width('94%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.openSheet = false;
        })
    }
    .margin({
      top: 10
    })
    .height(156)
    .width('92%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
  }
}