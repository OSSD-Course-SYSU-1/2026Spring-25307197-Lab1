import { CustomIcon, FlingTodoListItem } from '@ohos_agcit/daily_schedule_component_lib';
import { TodoItem, ToastManager, showToast } from '@ohos_agcit/daily_schedule_common_lib';
import { TodoDataManager } from '../../mock/TodoDataManager';
import { DateUtils, FormatUtil, ThemeController } from '@ohos_agcit/daily_schedule_common_lib';
import { leftSwipeButtonBuilder } from '../builder/LeftSwipeButtonBuilder';
import { PriorityEnum } from '../../enum/TodoItemEnum';
import { UpdateTodoPlanTimeVM } from '../../mock/TodoInfoVM';
import { AppStorageV2, curves, promptAction } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';
import { ExtInfo } from '../../mock/TitleDataManager';

@ComponentV2
export struct TodoSection {
  vm: UpdateTodoPlanTimeVM = UpdateTodoPlanTimeVM.instance
  dataManager: TodoDataManager = TodoDataManager.instance
  themeController: ThemeController = ThemeController.instance;
  extInfo: ExtInfo = ExtInfo.instance
  controller: Scroller = new Scroller()
  toastManager: ToastManager = ToastManager.getInstance()
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
  @Param label: string | Resource = '今天'
  @Param todoItems: TodoItem[] = this.dataManager.loadMockTodos()
  @Param onDelete: (taskID: string) => void = () => {
  }
  @Param onModify: (taskID: string) => void = () => {
  }
  @Param maxLen: number = 16
  @Local isExpand: boolean = true
  @Local debugMessage: string = '等待手势触发...'
  @Local showTipDialog: boolean = false
  @Local tipMessage: string = ''
  // 可视区域索引范围（用于优化手势绑定）
  @Local visibleStartIndex: number = 0
  @Local visibleEndIndex: number = 1000 // 增大初始值，确保所有待办项都有手势

  build() {
    Column() {
      Row() {
        Text(this.label)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_L'))
        Blank()
        Text(this.todoItems.length.toString())
          .fontColor($r('app.color.color_gray_deeper'))
          .fontSize($r('sys.float.Body_L'))
        Image(this.isExpand ? $r('app.media.path_up') : $r('app.media.path_down'))
          .height(15)
          .width(15)
          .margin({ left: '2.5%' })
          .onClick(() => {
            this.isExpand = !this.isExpand
          })
      }
      .height(45)
      .width('100%')

      if (this.isExpand) {
        List({ scroller: this.controller, space: 12 }) {
          ForEach(this.todoItems, (item: TodoItem, index: number) => {
            ListItem() {
              // 根据甩出发送功能开关决定是否启用甩出发送
              if (this.extInfo.isShareDragEnable) {
                // 使用 FlingTodoListItem 包装待办卡片，添加甩出发送功能
                // isVisible: 仅当在可视区域内时才绑定手势，优化性能
                FlingTodoListItem({
                  todoItem: item,
                  isVisible: index >= this.visibleStartIndex && index <= this.visibleEndIndex,
                  onFlingSuccess: () => {
                    // 甩出成功回调
                    this.tipMessage = '✅ 甩出成功！';
                    this.showTipDialog = true;
                  },
                  onFlingFail: (reason: string) => {
                    // 甩出失败回调
                    this.tipMessage = `❌ 甩出失败：${reason}`;
                    this.showTipDialog = true;
                  },
                  content: (todoItem: TodoItem) => {
                    // 原有的待办卡片UI
                    this.TodoCardBuilder(todoItem);
                  }
                })
              } else {
                // 甩出发送功能已禁用，直接显示待办卡片
                this.TodoCardBuilder(item);
              }
            }
            .width('100%')
            .transition(TransitionEffect.OPACITY
              .combine(TransitionEffect.translate({ x: 0, y: 100 }))
              .animation({ curve: curves.springMotion(), delay: 30 * index }))
            // 注意：swipeAction 与甩出手势冲突，暂时禁用以测试甩出功能
            // .swipeAction({
            //   end: {
            //     builder: leftSwipeButtonBuilder(() => {
            //       this.onDelete(item.taskID);
            //     }, () => {
            //       this.onModify(item.taskID);
            //     })
            //   }
            // })
          }, (item: TodoItem) => item.taskID + '_' + item.isFinished)
          // 注意：onMove 与甩出手势冲突，暂时禁用
          // .onMove((from: number, to: number) => {
          //   // 交换数据位置
          //   let tmp = this.todoItems.splice(from, 1);
          //   this.todoItems.splice(to, 0, tmp[0]);
          //   // 触发数据更新
          //   this.dataManager.onAllTasksChange();
          // })
        }
        .width('100%')
        // 监听滚动，更新可视区域索引范围（优化手势绑定性能）
        .onScrollIndex((start: number, end: number) => {
          // 扩大可视区域范围，预留缓冲区确保边缘项也有手势
          this.visibleStartIndex = Math.max(0, start - 2);
          this.visibleEndIndex = Math.min(this.todoItems.length - 1, end + 2);
        })
      }
    }
    .height(this.calcHeight())
    .animation({
      curve: Curve.Linear,
      duration: 300
    })
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ left: '5%', right: '5%' })
    .bindSheet($$this.showTipDialog, this.TipDialogBuilder(), {
      height: SheetSize.FIT_CONTENT,
      preferType: SheetType.BOTTOM,
      showClose: false,
      backgroundColor: $r('sys.color.background_primary'),
      dragBar: false,
      onAppear: () => {
        // 3秒后自动消失
        setTimeout(() => {
          this.showTipDialog = false;
        }, 3000);
      }
    })
  }

  // 提示弹窗Builder（自适应屏幕宽度）
  @Builder
  TipDialogBuilder() {
    Column() {
      Text(this.tipMessage)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
        .padding({
          top: new BreakpointType<number>({ sm: 16, md: 20, lg: 24 }).getValue(this.globalInfo.currentBreakpoint),
          bottom: new BreakpointType<number>({ sm: 16, md: 20, lg: 24 }).getValue(this.globalInfo.currentBreakpoint),
          left: new BreakpointType<number>({ sm: 20, md: 24, lg: 32 }).getValue(this.globalInfo.currentBreakpoint),
          right: new BreakpointType<number>({ sm: 20, md: 24, lg: 32 }).getValue(this.globalInfo.currentBreakpoint)
        })
    }
    // 自适应屏幕宽度：手机90%，平板70%，PC50%
    .width(new BreakpointType<string>({ sm: '90%', md: '70%', lg: '50%' }).getValue(this.globalInfo.currentBreakpoint))
    .borderRadius(new BreakpointType<number>({ sm: 16, md: 20, lg: 24 }).getValue(this.globalInfo.currentBreakpoint))
    .margin({ bottom: new BreakpointType<number>({ sm: 20, md: 30, lg: 40 }).getValue(this.globalInfo.currentBreakpoint) })
  }

  private chooseTitleColor(item: TodoItem): ResourceColor {
    if (item.isFinished) {
      return $r('sys.color.font_tertiary')
    }
    return $r('sys.color.icon_primary');
  }

  private choosePlainTimeColor(item: TodoItem): ResourceColor {
    if (item.isFinished) {
      return $r('sys.color.font_tertiary')
    }
    return DateUtils.isExpiredDate(item.planTime) ? $r('sys.color.warning') :
    $r('sys.color.icon_primary');
  }

  private chooseCheckBoxColor(item: TodoItem): ResourceColor {
    if (item.priorityType === PriorityEnum.LOW) {
      return $r('sys.color.multi_color_04')
    }
    if (item.priorityType === PriorityEnum.MID) {
      return $r('sys.color.alert')
    }
    if (item.priorityType === PriorityEnum.HIGH) {
      return $r('sys.color.warning')
    }
    return $r('sys.color.font_tertiary')
  }

  private calcHeight(): Length {
    if (!this.isExpand || this.todoItems.length === 0) {
      return 45
    }
    return 45 + this.todoItems.length * 76 + (this.todoItems.length - 1) * 12;
  }

  @Builder
  itemEnd(index: number) {
    Row() {
      CustomIcon({
        resource: $r('sys.symbol.calendar_fill'),
        backgroundColor: $r('sys.color.multi_color_02'),
        onClick: () => {

        }
      })
      CustomIcon({
        resource: $r('sys.symbol.trash'),
        backgroundColor: $r('sys.color.warning'),
        onClick: () => {

        }
      })
    }
  }

  // 待办卡片UI Builder
  @Builder
  TodoCardBuilder(item: TodoItem) {
    Row() {
      Column() {
        Checkbox()
          .select(item.isFinished)
          .unselectedColor(this.chooseCheckBoxColor(item))
          .selectedColor($r('sys.color.icon_tertiary'))
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .mark({
            strokeColor: $r('sys.color.comp_background_primary_contrary'),
          })
          .onChange((value: boolean) => {
            this.dataManager.updateTaskFinish(item.taskID, value)
          })
          .margin({ top: 11 })
      }
      .height('100%')
      .justifyContent(FlexAlign.Start)

      Column() {
        Text(item.title.length > this.maxLen ? item.title.substring(0, this.maxLen) + '...' : item.title)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(this.chooseTitleColor(item))
          .maxLines(1)
        Blank().height(12)
        Text(FormatUtil.formatDate(item.planTime, FormatUtil.DATE_YYYY_MM_DD_24H_mm))
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.choosePlainTimeColor(item))
      }
      .margin({ left: 6, top: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .padding({ left: 14, right: 14 })
    .height(76)
    .width('100%')
    .backgroundColor(this.themeController.currentColorMode ===
    ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? $r('sys.color.background_tertiary') :
    $r('sys.color.background_primary'))
    .borderRadius(16)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }
}