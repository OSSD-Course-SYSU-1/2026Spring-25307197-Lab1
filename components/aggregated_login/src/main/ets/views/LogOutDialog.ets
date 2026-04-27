import { MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { UserInfo } from '../model/UserInfo';

@Builder
export function LogOutDialogBuilder() {
  LogOutDialog();
}

/**
 * 设置-退出登录弹窗
 */
@ComponentV2
export struct LogOutDialog {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  vm: MainEntryVM = MainEntryVM.instance;
  private userInfo: UserInfo = UserInfo.instance;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column({ space: 18 }) {
          Text('账号退出登录')
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))

          Text('请确认是否退出当前账户？')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))

          Flex({justifyContent: FlexAlign.SpaceAround}){
            Row(){
              Text('取消')
                .fontColor($r('sys.color.icon_emphasize'))
                .fontSize($r('sys.float.Body_L'))
            }
            .justifyContent(FlexAlign.Center)
            .width('50%')
            .onClick(() => {
              this.vm.navStack.pop();
            })

            Row(){
              Text('确定')
                .fontColor($r('sys.color.icon_emphasize'))
                .fontSize($r('sys.float.Body_L'))
            }
            .justifyContent(FlexAlign.Center)
            .width('50%')
            .onClick(() => {
              this.userInfo.logOut();
              this.vm.navStack.pop();
            })
          }
          .padding({
            top: 10
          })
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(32)
        .height(139)
        .width('92%')
      }
      .height('100%')
      .width('100%')
      .onClick(() => {
        this.vm.navStack.pop();
      })
    }
    .backgroundColor($r('sys.color.mask_fourth'))
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG);
  }
}