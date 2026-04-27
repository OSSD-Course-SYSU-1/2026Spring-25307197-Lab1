import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { UserInfo } from '../model/UserInfo';
import { rightArrow } from '../components/RightArrow';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import {  MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';


@Builder
export function UserInfoBuilder() {
  UserInfoPage();
}

@ComponentV2
export struct UserInfoPage {
  vm: MainEntryVM = MainEntryVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local isShow: boolean = false;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  private userInfo : UserInfo = UserInfo.instance;
  @Local nickName: string = this.userInfo.userName;

  @Builder
  nickNameBuilder() {
    Column() {
      TextInput({
        text: this.userInfo.userName,
        placeholder: '请输入昵称',
      })
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .maxLength(10)
        .cancelButton({
          style: CancelButtonStyle.CONSTANT,
          icon: { size: 16, color: '#000000' }
        })
        .onChange((value: string) => {
          if (value.length <= 10) {
            this.nickName = value;
          }
        });

      Button('确定')
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#64BB5C')
        .width('100%')
        .margin({ left: 28, right: 28 })
        .enabled(!!this.userInfo.userName.trim())
        .onClick(() => {
          const trimmedName = this.nickName.toString().trim();
          if (!trimmedName) {
            this.getUIContext().getPromptAction().showToast({
              message: '昵称不能为空或空格',
              alignment: Alignment.Bottom
            })
            return;
          }
          this.userInfo.userName = trimmedName;
          this.isShow = false;
        });
    }
    .padding(16)
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Row() {
          Text('头像')
            .fontSize($r('sys.float.Body_L'))
            .layoutWeight(1)
            .lineHeight(22)
            .padding({
              left: 12,
            });

          FunctionalButton({
            params: {
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .type(ButtonType.Circle)
                  .backgroundImage(this.userInfo.userAvatar)
                  .backgroundImageSize(ImageSize.Cover)
                  .width(40)
                  .height(40)
              },
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onChooseAvatar((error, data) => {
                if (error) {
                  return;
                }
                this.userInfo.userAvatar = data.avatarUri ? data.avatarUri : this.userInfo.userAvatar;
              }),
          })
            .margin({
              right: 6,
            });

          Row() {
            rightArrow();
          }
          .margin({
            right: 8,
          });
        }
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .height(56)
        .borderRadius(16)
        .margin({ top: 16 });

        Column() {
          Row() {
            Text('昵称').opacity(0.9);
            Row() {
              Text(this.userInfo.userName).fontSize($r('sys.float.Body_M')).opacity(0.6)
                .margin({
                  right: 6,
                });
              Image($r('app.media.ic_public_brush'))
                .fillColor($r('sys.color.font_secondary'))
                .size({ height: 24, width: 24 })
                .onClick(() => {
                  this.isShow = true;
                })
                .bindSheet($$this.isShow, this.nickNameBuilder(), {
                  height: 420, title: { title: '设置昵称' },
                  preferType:SheetType.CENTER
                });
            };
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .padding(12)
        .width('100%')
        .height(58)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius(16)
      }
      .height('100%')
      .padding({
        left: 16,
        right: 16,
      });
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: px2vp(this.avoidArea.topRectHeight) })
    .title('个人信息')
    .onBackPressed(() => {
      this.vm.navStack.pop();
      return true;
    });
  }
}