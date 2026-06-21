import { CommonConstants, MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { TAB_LIST } from '../constants/Constants';
import { TabListItem } from '../types/Types';
import { TodoPage } from '@ohos_agcit/daily_schedule_todo';
import { CalendarPage } from '@ohos_agcit/daily_schedule_calendar';
import { MinePage } from '@ohos_agcit/daily_schedule_mine';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { AppStorageV2, display } from '@kit.ArkUI';
import { BreakpointSystem, BreakpointType, BreakpointConstants } from '../utils/BreakpointSystem';

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
  // 窗口尺寸状态（用于响应式布局）
  @Local windowWidth: number = 360;
  @Local windowHeight: number = 640;
  // 当前断点类型
  @Local currentBreakpoint: BreakpointType = BreakpointType.SM;
  
  aboutToAppear(): void {
    // 初始化窗口尺寸
    this.initWindowSize();
  }
  
  // 初始化窗口尺寸
  private initWindowSize(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync();
      this.windowWidth = displayInfo.width;
      this.windowHeight = displayInfo.height;
      this.currentBreakpoint = BreakpointSystem.getBreakpoint(this.windowWidth);
      console.info(`[MainEntry] Window size: ${this.windowWidth}x${this.windowHeight}, Breakpoint: ${this.currentBreakpoint}`);
    } catch (e) {
      console.warn(`[MainEntry] Failed to get display info: ${e}`);
    }
  }
  
  // 是否为分栏布局
  private get isColumnLayout(): boolean {
    return this.currentBreakpoint === BreakpointType.LG;
  }
  
  // 计算侧边栏宽度
  private get sidebarWidth(): number {
    return BreakpointSystem.getSidebarWidth(this.windowWidth);
  }

  build() {
    Navigation(this.vm.navStack) {
      // 根据断点类型选择布局
      if (this.isColumnLayout) {
        // 分栏布局：左侧侧边栏 + 右侧内容区
        this.ColumnLayoutBuilder()
      } else {
        // 单列布局：底部 TabBar
        this.SingleLayoutBuilder()
      }
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
    // 安全区适配：避开刘海、挖孔、底部手势栏
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    // 监听窗口尺寸变化，实现响应式布局切换
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      if (newValue.width !== undefined && newValue.height !== undefined) {
        const width = newValue.width as number;
        const height = newValue.height as number;
        if (width > 0 && height > 0) {
          // 避免频繁更新，只有变化超过阈值才更新
          if (Math.abs(width - this.windowWidth) > 10 || Math.abs(height - this.windowHeight) > 10) {
            this.windowWidth = width;
            this.windowHeight = height;
            const newBreakpoint = BreakpointSystem.getBreakpoint(width);
            if (newBreakpoint !== this.currentBreakpoint) {
              this.currentBreakpoint = newBreakpoint;
              console.info(`[MainEntry] Breakpoint changed: ${this.currentBreakpoint}`);
            }
          }
        }
      }
    })
  }

  // 单列布局（底部 TabBar）
  @Builder
  SingleLayoutBuilder() {
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

  // 分栏布局（左侧侧边栏 + 右侧内容区）
  @Builder
  ColumnLayoutBuilder() {
    Row() {
      // 左侧侧边栏
      Column() {
        // 侧边栏标题
        Row() {
          Text('日程')
            .fontSize($r('sys.float.Title_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .justifyContent(FlexAlign.Start)

        Divider()
          .width('100%')
          .height(1)

        // 侧边栏导航列表
        Column() {
          ForEach(TAB_LIST, (item: TabListItem, index: number) => {
            this.SidebarItemBuilder(item, index)
          }, (item: TabListItem, index: number) => index.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
      }
      .width(this.sidebarWidth)
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .justifyContent(FlexAlign.Start)

      // 分隔线
      Divider()
        .width(1)
        .height('100%')

      // 右侧内容区
      Column() {
        // 根据当前选中Tab显示对应内容
        if (this.vm.curIndex === 0) {
          TodoPage()
        } else if (this.vm.curIndex === 1) {
          CalendarPage()
        } else {
          MinePage()
        }
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }

  // 侧边栏导航项
  @Builder
  SidebarItemBuilder(item: TabListItem, index: number) {
    Row() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24)
        .margin({ right: 12 })

      Text(item.label)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(this.vm.curIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.vm.curIndex === index ? $r('sys.color.multi_color_04') : $r('sys.color.font_secondary'))
    }
    .width('100%')
    .height(48)
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.vm.curIndex === index ? $r('sys.color.background_primary') : Color.Transparent)
    .borderRadius(8)
    .margin({ left: 8, right: 8 })
    .onClick(() => {
      this.vm.curIndex = index;
    })
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