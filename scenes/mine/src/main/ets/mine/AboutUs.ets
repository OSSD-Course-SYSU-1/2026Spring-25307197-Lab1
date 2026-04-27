import { AppUtil, BreakpointType, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';
import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import { checkUpdateFunc } from './Setting';
import { AppStorageV2 } from '@kit.ArkUI';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';

/**
 * 关于我们
 */
@Builder
export function AboutUsBuilder() {
  AboutUs();
}

@ComponentV2
export struct AboutUs {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local openPhoneSheet: boolean = false;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

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
        Row(){
          Image($r('sys.symbol.phone'))
            .width(14)
            .height(14)
          Text('一键拨号')
            .fontSize($r('sys.float.Body_L'))
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
        .fontColor($r('sys.color.font_primary'))
        .height(40)
        .width('94%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.openPhoneSheet = false;
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

  build() {
    NavDestination(){
      Column(){
        Scroll(){
          Column() {
            this.appIconAndName();
            this.mainContent();
            Blank()
              .layoutWeight(1)
            this.bottomContent();
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .padding(new BreakpointType<Padding>({
        sm: {
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
        },
        md: {
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
        },
        lg: {
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
        },
      }).getValue(this.globalInfo.currentBreakpoint))
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: px2vp(this.avoidArea.topRectHeight)  })
    .title('关于')
  }

  @Builder
  appIconAndName(){
    Row(){
      Image($r('app.media.app_icon'))
        .width(72)
        .height(72)
        .borderRadius(16)
    }
    .padding({
      top: 80
    })

    Text('日历日程模板')
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Medium)
      .padding({
        top: 10,
        bottom: 77
      })
  }

  @Builder
  mainContent(){
    Column() {
      Row() {
        Column() {
          Row({ space: 8 }) {
            Text('版本信息')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            if (true) {
              Row()
                .width(6)
                .height(6)
                .borderRadius(100)
                .backgroundColor('#E84026');
            }
          }
          .padding({
            top: 10
          })

          Text(AppUtil.getVersionName())
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .alignSelf(ItemAlign.Start)
            .padding({ top: 2 });
        }
        Blank();
        Row({ space: 7 }) {
          Text('新版本')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'));
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.font_secondary')]);
        };
      }
      .width('100%')
      .height(74)
      .padding({ top: 16, left: 12, right: 12, bottom: 10 })
      .onClick(() => {
        checkUpdateFunc()
      })

      Divider()
        .width('90%');

      Row(){
        Column() {
          Text('客服电话')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'));
          Text('000000')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .alignSelf(ItemAlign.Start)
            .padding({ top: 5 });
        }
      }
      .width('100%')
      .height(64)
      .padding({ top: 10, bottom: 10, left: 12 })
      .onClick(() => {
        this.openPhoneSheet = !this.openPhoneSheet
      })
      .bindSheet($$this.openPhoneSheet, this.contactBuilder(), {
        title: {title: '联系客服' },
        height: '35%',
        width: '100%'
      })

      Divider()
        .width('90%');
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .height(160)
    .borderRadius(32);

  }

  @Builder
  bottomContent(){
    Column(){
      Text('苏ICP备xxxxxxxx号-xxxA')
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Medium)
      Text('华为xx 版权所有 © 2019-2025')
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'))
      Text('技术支持：xxxxxxxx')
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'))
    }
    .margin({
      top: 30,
      bottom: 30
    })
    .padding({
      bottom: 20
    })
  }
}