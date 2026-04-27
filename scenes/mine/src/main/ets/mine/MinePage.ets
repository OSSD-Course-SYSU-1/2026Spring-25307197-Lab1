import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';
import { UserInfo } from 'aggregated_login';
import {  MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { AppStorageV2 } from '@kit.ArkUI';
import { ContactItem, MineItem } from '../components/MineItem';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { COMMON_SERVICE, MinePageCommonService } from '../constants/MineUiConstants';

@Builder
export function MinePageBuilder() {
  MinePage();
}

@ComponentV2
export struct MinePage {
  vm: MainEntryVM = MainEntryVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private userInfo: UserInfo = UserInfo.instance;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  @Builder
  titleBar() {
    Row() {
      Text('我的')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start);
    }
    .height('5%')
    .width('100%')
    .margin({bottom:16})
  }

  build() {
    Column(){
      this.titleBar();
      Scroll() {
        Column() {
          Row() {
            Image(this.userInfo.userAvatar)
              .width(56)
              .height(56)
              .margin({ left: 12 })

            Text(this.userInfo.userName)
              .fontSize($r('sys.float.Subtitle_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ left: 12 })
          }
          .width('100%')
          .height(72)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)
          .onClick(async () => {
            if (this.userInfo.isLogin) {
              this.vm.navStack.pushPathByName('UserInfoPage', undefined);
            } else {
              this.vm.navStack.pushPathByName('QuickLoginPage', undefined);
            }
          });

          Column() {
            ForEach(COMMON_SERVICE, (item: MinePageCommonService, index: number) => {
              MineItem({
                commonService: item,
                appPathStack: this.appPathStack
              })

              if (index < COMMON_SERVICE.length - 1) {
                Divider()
                  .margin({ left: 12, right: 12 })
              }
            },(item: MinePageCommonService)=>JSON.stringify(item))

            Divider()
              .margin({ left: 12, right: 12 })

            ContactItem({
              commonService: {
                icon: 'app.media.app_kefu',
                label: '联系客服',
              },
              appPathStack: this.appPathStack
            })
          }
          .height(190)
          .width('100%')
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)
          .margin({ top: 12 })
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
        top: 10,
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      },
      md: {
        top: 10,
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      },
      lg: {
        top: 10,
        left: $r('sys.float.padding_level16'),
        right: $r('sys.float.padding_level16'),
      },
    }).getValue(this.globalInfo.currentBreakpoint))
    .padding({left:'5%', top: px2vp(this.avoidArea.topRectHeight), right:'5%'})
    .backgroundColor($r('sys.color.background_secondary'))
  }
}