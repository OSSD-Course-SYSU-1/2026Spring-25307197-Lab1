import { AppUtil, NotificationBasicOptions, NotificationUtil, WantUtil } from '@ohos_agcit/daily_schedule_utils';
import { SettingController } from '../controller/SettingController';
import { BusinessError } from '@kit.BasicServicesKit';
import { setAutoColorMode, setDarkColorMode, setLightColorMode, ThemeController } from '../controller/ThemeController';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { rightArrow } from 'aggregated_login';

@ComponentV2
export struct SingleArrow {
  @Param @Once @Require text: string;
  build() {
    Row() {
      Text(this.text)
        .textExtend()
        .fontColor($r('sys.color.font_primary'));
      Blank();
      rightArrow()
    }
    .borderRadius(16)
    .height(56)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .padding({
      left: 12,
      right: 12
    })
  }
}


@ComponentV2
export struct SingleToggle {
  @Param @Once @Require text: string;
  @Param @Require toggleSwitch: boolean;
  @Param @Once @Require toggleClick: VoidCallback;

  build() {
    Row() {
      Text(this.text)
        .textExtend()
        .fontColor($r('sys.color.font_primary'));
      Blank();
      Toggle({
        type: ToggleType.Switch,
        isOn: this.toggleSwitch,
      })
        .onClick(() => {
          this.toggleClick();
        });
    }
    .borderRadius(16)
    .height(56)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .padding({
      left: 12,
      right: 12
    })
  }
}

/**
 * 通知开关
 */
@ComponentV2
export struct NoticeToggle {
  settingController: SettingController = SettingController.instance
  @Param @Once @Require text: string;

  build() {
    Row() {
      Text(this.text)
        .textExtend()
        .fontColor($r('sys.color.font_primary'));
      Blank();
      if (this.settingController.isNoticeGrant === false){
        Text('已关闭')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_tertiary'))
          .onClick(() => {
            // 清空桌面角标
            NotificationUtil.clearBadge();
            // 未授权点击，跳转到通知设置页面
            WantUtil.toSetting('application_info_entry');
          })
      } else {
        Toggle({
          type: ToggleType.Switch,
          isOn: this.settingController.noticeToggle,
        })
          .onClick(() => {
            this.settingController.noticeToggle = !this.settingController.noticeToggle;
            if (this.settingController.noticeToggle === true) {
              this.settingController.noticeToggle = true;
              this.send();
            }
          });
      }

    }
    .borderRadius(16)
    .height(56)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .padding({
      left: 12,
      right: 12
    })
  }

  send(){
    NotificationUtil.getDefaultWantAgent().then(wantAgent => {
      let id = NotificationUtil.generateNotificationId(); //通知id
      let basicOptions: NotificationBasicOptions = {
        id: id,
        title: '日历日程模板',
        text: '日历日程模板发送了一条消息',
        wantAgent: wantAgent
      }
      NotificationUtil.publishBasic(basicOptions).then((id) => {
      }).catch((err: BusinessError) => {
        this.getUIContext().getPromptAction().showToast({
          message: `通知发送失败，${err.message}`
        })
      });
    })


  }
}


@ComponentV2
export struct DarkModeToggle {
  private themeController: ThemeController = ThemeController.instance;
  build() {
    Column(){
      Row() {
        Text('跟随系统')
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        Toggle({
          type: ToggleType.Switch,
          isOn: this.themeController.isFollowSystemSetting
        })
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.themeController.isFollowSystemSetting = true;
              this.themeController.enableDarkMode = false;
              setAutoColorMode(AppUtil.getContext());
            } else {
              this.themeController.isFollowSystemSetting = false;
              if (this.themeController.enableDarkMode) {
                setDarkColorMode(AppUtil.getContext());
              } else {
                setLightColorMode(AppUtil.getContext());
              }
            }
          })
      }
      .width('100%')
      .height(56);

      Divider()
        .height(0.5)
        .width('100%')
        .color($r('sys.color.comp_divider'))

      Row() {
        Text('夜间模式')
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        Toggle({
          type: ToggleType.Switch,
          isOn: this.themeController.enableDarkMode
        })
          .onChange((isOn: boolean) => {
            this.themeController.enableDarkMode = isOn;
            if (isOn) {
              this.themeController.isFollowSystemSetting = false;
              this.themeController.currentColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
              setDarkColorMode(AppUtil.getContext());
            } else if (!this.themeController.isFollowSystemSetting) {
              setLightColorMode(AppUtil.getContext());
              this.themeController.currentColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
            }
          })
      }
      .width('100%')
      .height(56);
    }
    .padding({
      left: 12,
      right: 12
    })
    .borderRadius(16)
    .height(112.5)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
  }
}

@ComponentV2
export struct MergeArrow {
  @Param @Once @Require text1: string;
  @Param @Once @Require text1Click: VoidCallback;
  @Param @Once @Require text2: string;
  @Param @Once @Require text2Click: VoidCallback;

  build() {
    Column(){
      Row() {
        Text(this.text1)
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        rightArrow()
      }
      .width('100%')
      .height(56)
      .onClick(() => {
        this.text1Click();
      })
      Divider()
        .height(0.5)
        .width('100%')
        .color($r('sys.color.comp_divider'))
      Row(){
        Text(this.text2)
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        rightArrow()
      }
      .width('100%')
      .height(56)
      .onClick(() => {
        this.text2Click();
      })
    }
    .padding({
      left: 12,
      right: 12
    })
    .borderRadius(16)
    .height(112.5)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
  }
}

@ComponentV2
export struct ThreeMergeArrow {
  @Param @Once @Require text1: string;
  @Param @Once @Require text1Click: VoidCallback;
  @Param @Once @Require text2: string;
  @Param @Once @Require text2Click: VoidCallback;
  @Param @Once @Require text3: string;
  @Param @Once @Require text3Click: VoidCallback;
  @Param   extraText2: string='';

  build() {
    Column(){
      Row() {
        Text(this.text1)
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        rightArrow()
      }
      .width('100%')
      .height(56)
      .onClick(() => {
        this.text1Click();
      })
      Divider()
        .height(0.5)
        .width('100%')
        .color($r('sys.color.comp_divider'))
      Row(){
        Text(this.text2)
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        if (this.extraText2 !== '') {
          Text(this.extraText2)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ right: 8 })
        }
        rightArrow()
      }
      .width('100%')
      .height(56)
      .onClick(() => {
        this.text2Click();
      })
      Row(){
        Text(this.text3)
          .textExtend()
          .fontColor($r('sys.color.font_primary'));
        Blank();
        rightArrow()
      }
      .width('100%')
      .height(56)
      .onClick(() => {
        this.text3Click();
      })
    }
    .padding({
      left: 12,
      right: 12
    })
    .borderRadius(16)
    .height(168.5)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
  }
}
@Extend(Text)
function textExtend() {
  .fontSize($r('sys.float.Body_L'))
  .fontWeight(FontWeight.Medium)
  .opacity(0.9)
}