import { CommonConstants, MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { TAB_LIST } from '../constants/Constants';
import { TabListItem } from '../types/Types';
import { TodoPage } from '@ohos_agcit/daily_schedule_todo';
import { CalendarPage } from '@ohos_agcit/daily_schedule_calendar';
import { MinePage } from '@ohos_agcit/daily_schedule_mine';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { AppStorageV2 } from '@kit.ArkUI';

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;
  bottomRectHeight: number = 0;
  @Local totalCount: number = 0;
  @Local didCount: number = 0;
  @Local accuracyRate: number = 0;
  @Local averageScore: number = 0;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;

  build() {
    Navigation(this.vm.navStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex }) {
          TabContent() {
            TodoPage()
          }
          .tabBar(this.tabBarBuilder(TAB_LIST[0], 0));

          TabContent() {
            CalendarPage()
          }
          .tabBar(this.tabBarBuilder(TAB_LIST[1], 1));

          TabContent() {
            MinePage()
          }
          .tabBar(this.tabBarBuilder(TAB_LIST[2], 2));
        }
        .scrollable(false)
        .height(CommonConstants.FULL_HEIGHT)
        .animationDuration(0)
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.vm.curIndex = index;
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
      .padding({
        bottom: px2vp(this.avoidArea.bottomRectHeight)
      })
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24)
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('sys.color.multi_color_04') :
        $r('sys.color.font_secondary'))
        .fontSize($r('app.string.font_size_10'))
        .margin({ top: $r('app.string.margin_xs') });
    }
    .width(CommonConstants.FULL_WIDTH);
  }
}