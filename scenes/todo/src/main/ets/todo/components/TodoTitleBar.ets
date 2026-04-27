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

  build() {
    Row() {
      Text($r('app.string.page_todo_title')).fontSize(26).fontWeight(FontWeight.Bolder)
      Blank()
      Image($r('app.media.icon_filter'))
        .height(40)
        .width(40)
        .margin({ right: 5 })
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
      Image($r('app.media.icon_more')).height(40).width(40)
        .bindMenu(this.MenuBuilder())
    }
    .padding({ 'left': '5%', right: '5%' })
    .height('7%')
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

        Divider().strokeWidth('1px').width('80%').margin({ left: 30 })

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
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(10)
      .height(100)
      .width(224)
    }
  }
}