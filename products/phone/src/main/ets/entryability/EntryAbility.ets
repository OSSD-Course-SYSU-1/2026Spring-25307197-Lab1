import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { ThemeController } from '@ohos_agcit/daily_schedule_common_lib';
import { WindowUtil } from '@ohos_agcit/daily_schedule_utils';
import { TodoDataManager } from '@ohos_agcit/daily_schedule_todo';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private themeController: ThemeController = ThemeController.instance;
  dataManager: TodoDataManager = TodoDataManager.instance

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    this.themeController.currentColorMode = this.context.config.colorMode;
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 一多适配
    WindowUtil.registerBreakPoint(windowStage);

    windowStage.loadContent('pages/MainEntry', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });

    // 获取当前布局遮挡区域
    let windowClass: window.Window = windowStage.getMainWindowSync();
    let isLayoutFullScreen = true;
    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      console.info('Succeeded in setting the window layout to full-screen mode.');
    }).catch((err: BusinessError) => {
      console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
    });

    // 导航条与状态栏避让
    let topAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    let topRectHeight = topAvoidArea.topRect.height; // 获取状态栏区域高度
    let bottomAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    let bottomRectHeight = bottomAvoidArea.bottomRect.height; // 获取到导航条区域的高度
    AppStorageV2.connect(AvoidArea, () => new AvoidArea(topRectHeight, bottomRectHeight));

    // 注册监听函数，动态获取避让区域数据
    windowClass.on('avoidAreaChange', (data) => {
      let avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        avoidArea.topRectHeight = data.area.topRect.height;
      } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        avoidArea.bottomRectHeight = data.area.bottomRect.height;
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * 夜间模式
   * @param newConfig
   */
  onConfigurationUpdate(newConfig: Configuration): void {
    if (this.themeController.currentColorMode !== newConfig.colorMode &&
    this.themeController.isFollowSystemSetting) {
      this.themeController.currentColorMode = newConfig.colorMode;
    }
  }

  onNewWant(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    this.dataManager.updateAtomicCard()
  }
}