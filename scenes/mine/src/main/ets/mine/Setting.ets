import { AppUtil, BreakpointType, DialogUtil, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';
import { UserInfo } from 'aggregated_login';
import { MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { MergeArrow, ThreeMergeArrow } from '../components/SettingComponents';
import { ThemeController } from '../controller/ThemeController';
import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { checkUpdate, findNewVersion, Params } from 'check_app_update';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { SettingViewModel } from './SettingViewModel';

@Builder
export function SettingBuilder() {
  Setting();
}
let themeController: ThemeController = ThemeController.instance;

@ComponentV2
export struct Setting {
  vm: MainEntryVM = MainEntryVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private userInfo: UserInfo = UserInfo.instance;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  @Local settingVm: SettingViewModel = new SettingViewModel();

  aboutToAppear(): void {
    this.settingVm.getCacheSize();
  }

  build() {
    NavDestination() {
      Column(){
        Scroll(){
          Column({ space: 17 }) {
            MergeArrow({
              text1: '个人信息',
              text1Click: () => {
                if (this.userInfo.isLogin) {
                  this.vm.navStack.pushPathByName('UserInfoPage', undefined);
                } else {
                  this.vm.navStack.pushPathByName('QuickLoginPage', undefined);
                }              },
              text2: '隐私设置',
              text2Click: () => {
                this.vm.navStack.pushPathByName('PrivacySetting', undefined);
              },
            });

            ThreeMergeArrow({
              text1: '检测版本',
              text1Click: () => {
                checkUpdateFunc();
              },
              text2: '清除缓存',
              extraText2: this.settingVm.cacheSize+'M',
              text2Click: () => {
                this.settingVm.clearCache();
              },
              text3: '关于我们',
              text3Click: () => {
                this.vm.navStack.pushPathByName('AboutUs', undefined);
              },
            });

            Blank()
              .layoutWeight(1)

            if (this.userInfo.isLogin){
              Button('退出登录')
                .width('100%')
                .height(40)
                .fontWeight(FontWeight.Medium)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .fontColor($r('sys.color.font_primary'))
                .margin({
                  bottom: 44,
                })
                .onClick(() => {
                  this.vm.navStack.pushPathByName('LogOutDialog', undefined);
                });
            }
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
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
    }
    .padding({ top: px2vp(this.avoidArea.topRectHeight)  })
    .backgroundColor($r('sys.color.background_secondary'))
    .title('设置')
  }
}

/**
 * 发现新版本
 * @param ctx
 */
export function checkUpdateFunc() {
  checkUpdate(AppUtil.getContext())
    .then(version => {
      // 0 不存在新版本， 1 存在新版本
      if (version === 1) {
        showNewVersionDialog(version);
      } else {
        // mock 新版本
        showNewVersionDialog(version);
      }
    });
}

/**
 * 发现新版本弹窗
 * @param version
 */
export function showNewVersionDialog(version: number) {
  let contentNode: ComponentContent<object> =
    new ComponentContent(AppUtil.getUIContext(), wrapBuilder(findNewVersion),
      new Params(version, themeController.dialogBgWhite));
  DialogUtil.setOptions({ alignment: DialogAlignment.Center, offset: { dx: 0, dy: 100 } });
  DialogUtil.openDialog(AppUtil.getUIContext(), contentNode);
}
