import { filterSelectBuilder } from '../builder/FilterSelectBuilder';
import { TodoDataManager } from '../../mock/TodoDataManager';
import { ExtInfo, FilterInfo, TodoListTabInfo } from '../../mock/TitleDataManager';

@ComponentV2
export struct TodoTitleBar {
  dataManager: TodoDataManager = TodoDataManager.instance
  filterInfo: FilterInfo = FilterInfo.instance
  todoListTabInfo: TodoListTabInfo = TodoListTabInfo.instance
  extInfo: ExtInfo = ExtInfo.instance
  @Local isShowFilterSheet: boolean = false;
  @Param onSort: () => void = () => {
  }
  // 紧凑模式（极小窗口时精简UI）
  @Param isCompactMode: boolean = false;

  build() {
    Row() {
      // 极小窗口时缩短标题，避免溢出
      Text(this.isCompactMode ? '待办' : $r('app.string.page_todo_title'))
        .fontSize(this.isCompactMode ? $r('sys.float.Body_L') : $r('sys.float.Title_L'))
        .fontWeight(FontWeight.Bolder)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Blank()
      // 筛选按钮（核心功能，始终保留）
      Image($r('app.media.icon_filter'))
        .height(this.isCompactMode ? 32 : 40)
        .width(this.isCompactMode ? 32 : 40)
        .margin({ right: this.isCompactMode ? 2 : 5 })
        .onClick(() => this.isShowFilterSheet = !this.isShowFilterSheet)
        .bindSheet($$this.isShowFilterSheet, filterSelectBuilder({
          onConfirm: () => {
            this.todoListTabInfo.statusIndex = this.filterInfo.statusIndex
            this.todoListTabInfo.priorityIndex = this.filterInfo.priorityIndex
            this.dataManager.onAllTasksChange()
            this.isShowFilterSheet = !this.isShowFilterSheet
          },
          onClose: () => this.isShowFilterSheet = !this.isShowFilterSheet
        }
        ), {
          height: SheetSize.FIT_CONTENT,
          preferType:
          SheetType.BOTTOM,
          showClose:
          false
        }
        )
      // 更多按钮（极小窗口时隐藏，保证核心功能按钮可见）
      if (!this.isCompactMode) {
        Image($r('app.media.icon_more')).height(40).width(40)
          .bindMenu(this.MenuBuilder())
      }
    }
    .padding({ 'left': this.isCompactMode ? '3%' : '5%', right: this.isCompactMode ? '3%' : '5%' })
    .height(this.isCompactMode ? '6%' : '7%')
    .width('100%')
  }

  @Builder
  MenuBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Column() {
        Row() {
          Image(this.extInfo.isShowFinished ? $r('app.media.icon_eye_on') : $r('app.media.icon_eye_off'))
            .height(26)
            .width(26)
          Text(this.extInfo.isShowFinished ? '显示已完成' : '隐藏已完成')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 10 })
            .width('80%')
        }
        .width('100%')
        .onClick(() => {
          this.extInfo.isShowFinished = !this.extInfo.isShowFinished
        })

        Divider().strokeWidth(1).width('80%').margin({ left: 30 })

        Row() {
          Image($r('app.media.icon_sort')).height(26).width(26)
          Text(this.extInfo.isDescending ? '排序方式' : '排序方式（升序）')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 10 })
        }
        .width('100%')
        .onClick(() => {
          this.onSort()
        })

        Divider().strokeWidth(1).width('80%').margin({ left: 30 })

        // 甩出发送功能开关
        Row() {
          Image(this.extInfo.isShareDragEnable ? $r('sys.symbol.checkmark_circle_fill') : $r('sys.symbol.circle'))
            .height(26)
            .width(26)
            .fillColor($r('sys.color.font_primary'))
          Text(this.extInfo.isShareDragEnable ? '甩出发送功能（已启用）' : '甩出发送功能（已禁用）')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 10 })
            .fontColor(this.extInfo.isShareDragEnable ? '#0000FF' : $r('sys.color.font_primary'))
        }
        .width('100%')
        .onClick(() => {
          this.extInfo.isShareDragEnable = !this.extInfo.isShareDragEnable
        })

        Divider().strokeWidth(1).width('80%').margin({ left: 30 })

        // 清除所有待办（用于测试空状态功能）
        Row() {
          Image($r('sys.symbol.trash'))
            .height(26)
            .width(26)
            .fillColor($r('sys.color.font_primary'))
          Text('清除所有待办')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.warning'))
            .margin({ left: 10 })
        }
        .width('100%')
        .onClick(() => {
          // 清空所有待办数据
          this.dataManager.allTasks = []
          this.dataManager.onAllTasksChange()
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(10)
      .height(200)
      .width(224)
    }
  }
}