import { DraggableTodoList } from '@ohos_agcit/daily_schedule_component_lib';
import { TodoItem } from '@ohos_agcit/daily_schedule_common_lib';
import { TodoDataManager } from '../../mock/TodoDataManager';
import { DateUtils, FormatUtil, ThemeController } from '@ohos_agcit/daily_schedule_common_lib';
import { leftSwipeButtonBuilder } from '../builder/LeftSwipeButtonBuilder';
import { PriorityEnum } from '../../enum/TodoItemEnum';
import { UpdateTodoPlanTimeVM } from '../../mock/TodoInfoVM';
import { AppStorageV2, curves } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';

/**
 * 集成拖拽功能的待办列表
 * 基于原有的 TodoSection 组件，添加拖拽功能
 */
@ComponentV2
export struct TodoSectionWithDrag {
  vm: UpdateTodoPlanTimeVM = UpdateTodoPlanTimeVM.instance
  dataManager: TodoDataManager = TodoDataManager.instance
  themeController: ThemeController = ThemeController.instance;
  controller: Scroller = new Scroller()
  @Param label: string | Resource = '今天'
  @Param todoItems: TodoItem[] = this.dataManager.loadMockTodos()
  @Param onDelete: (taskID: string) => void = () => {
  }
  @Param onModify: (taskID: string) => void = () => {
  }
  @Param maxLen: number = 16
  @Local isExpand: boolean = true

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
        // 使用拖拽列表组件替代原有的 List
        DraggableTodoList({
          todoItems: this.todoItems,
          itemHeight: 76,
          itemSpacing: 12,
          longPressDuration: 500,
          maxTitleLen: this.maxLen,
          onDelete: (taskID: string) => {
            this.onDelete(taskID);
          },
          onModify: (taskID: string) => {
            this.onModify(taskID);
          },
          onFinishChange: (taskID: string, isFinished: boolean) => {
            this.dataManager.updateTaskFinish(taskID, isFinished);
          },
          onDragEnd: (fromIndex: number, toIndex: number) => {
            // 交换数据位置
            let tmp = this.todoItems.splice(fromIndex, 1);
            this.todoItems.splice(toIndex, 0, tmp[0]);
            // 触发数据更新
            this.dataManager.onAllTasksChange();
          }
        })
        .width('100%')
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
  }

  private calcHeight(): Length {
    if (!this.isExpand || this.todoItems.length === 0) {
      return 45
    }
    return 45 + this.todoItems.length * 76 + (this.todoItems.length - 1) * 12;
  }
}
