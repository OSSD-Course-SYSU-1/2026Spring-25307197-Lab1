import { AvoidArea, TodoItem } from '@ohos_agcit/daily_schedule_component_lib';
import { addTodoTaskBuilder } from './builder/AddTodoTaskBuilder';
import { TodoDataManager } from '../mock/TodoDataManager';
import { ExtInfo, FilterInfo, TodoListTabInfo } from '../mock/TitleDataManager';
import { TodoTitleBar } from './components/TodoTitleBar';
import { AddTodoVM, UpdateTodoPlanTimeVM } from '../mock/TodoInfoVM';
import { TodoSectionList } from './components/TodoSectionList';
import { StatusFilterEnum } from '../enum/FilterEnum';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct TodoPage {
  addVM: AddTodoVM = AddTodoVM.instance
  dataManager: TodoDataManager = TodoDataManager.instance
  statusManager: FilterInfo = FilterInfo.instance
  updateTodoInfo: UpdateTodoPlanTimeVM = UpdateTodoPlanTimeVM.instance
  todoListTabInfo: TodoListTabInfo = TodoListTabInfo.instance
  extInfo: ExtInfo = ExtInfo.instance
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local isShowAddTodoSheet: boolean = false;
  @Local deleteTaskID: string = '';

  aboutToAppear(): void {
    this.restoreData()
    // this.dataManager.addTask(new TodoItem('2000', '思考人生', new Date('2025-10-11T08:00:00'), 0, 0, 0, false))
    // this.dataManager.addTask(new TodoItem('2001', '起床', new Date('2025-10-11T08:08:00'), 0, 0, 0, false))
    // this.dataManager.addTask(new TodoItem('2002', '吃饭', new Date('2025-10-11T08:09:00'), 0, 0, 1, false))
    // this.dataManager.addTask(new TodoItem('2003', '坐公交车', new Date('2025-10-11T08:11:00'), 0, 0, 1, false))
    // this.dataManager.addTask(new TodoItem('2004', '坐地铁', new Date('2025-10-11T08:12:00'), 0, 0, 2, false))
    // this.dataManager.addTask(new TodoItem('2005', '坐飞机', new Date('2025-10-11T08:22:00'), 0, 0, 2, false))
    // this.dataManager.addTask(new TodoItem('2006', '要记得上班打卡', new Date('2025-10-11T12:02:00'), 0, 0, 3, false))
    // this.dataManager.addTask(new TodoItem('2007', '梦游', new Date('2025-10-22T14:00:00'), 0, 0, 3, false))
  }

  save() {
    this.dataManager.addTask(
      new TodoItem(
        '',
        this.addVM.title,
        this.addVM.selectedTime,
        this.addVM.repetitionType,
        this.addVM.reminderType,
        this.addVM.priorityType,
        false))
  }

  restoreData() {
    this.addVM.title = ''
    this.addVM.selectedTime = new Date()
    this.addVM.repetitionType = 0
    this.addVM.reminderType = 0
    this.addVM.priorityType = 0
  }

  build() {
    Column() {
      TodoTitleBar({
        onSort: () => {
          this.extInfo.isDescending = !this.extInfo.isDescending
          this.dataManager.sortTask(this.extInfo.isDescending)
        }
      })
        .align(Alignment.Center)

      Stack() {
        if (this.dataManager.allTasks.length !== 0) {
          TodoSectionList({
            params: [
              {
                label: $r('app.string.todo_section_today'),
                data: this.dataManager.todayTasks,
                isShow:
                [StatusFilterEnum.ALL].indexOf(this.todoListTabInfo.statusIndex) !== -1
              },
              {
                label: $r('app.string.todo_section_tomorrow'),
                data: this.dataManager.tomorrowTasks,
                isShow:
                [StatusFilterEnum.ALL].indexOf(this.todoListTabInfo.statusIndex) !== -1
              },
              {
                label: $r('app.string.todo_section_all'),
                data: this.dataManager.allNotCompleteTasks,
                isShow:
                [StatusFilterEnum.ALL].indexOf(this.todoListTabInfo.statusIndex) !== -1
              },
              {
                label: $r('app.string.todo_section_complete'),
                data: this.dataManager.finishedTasks,
                isShow: this.extInfo.isShowFinished &&
                  [StatusFilterEnum.ALL, StatusFilterEnum.FINISHED].indexOf(this.todoListTabInfo.statusIndex) !== -1
              },
              {
                label: $r('app.string.todo_section_expire'),
                data: this.dataManager.expiredTasks,
                isShow:
                [StatusFilterEnum.ALL, StatusFilterEnum.EXPIRED].indexOf(this.todoListTabInfo.statusIndex) !== -1
              }
            ]
          })
        } else {
          Column() {
            Column() {
              Image($r('app.media.todo_bg'))
                .width(100)
                .height(150)
              Text('暂无待办事项，请开始添加吧～').fontWeight(FontWeight.Normal).fontColor($r('sys.color.font_tertiary'))
            }
          }
          .justifyContent(FlexAlign.Center)
          .height('60%')
          .width('100%')
        }


        Image($r('app.media.icon_add'))
          .height(44)
          .width(44)
          .onClick(() => {
            this.restoreData()
            this.isShowAddTodoSheet = !this.isShowAddTodoSheet
          })
          .zIndex(2)
          .position({ x: '80%', y: '85%' })
          .bindSheet($$this.isShowAddTodoSheet, addTodoTaskBuilder({
            onConfirm: () => {
              if (this.addVM.title === '') {
                this.getUIContext().getPromptAction().showToast({
                  message: '内容不能为空',
                  alignment: Alignment.Bottom
                })
                return
              }
              this.save()
              this.isShowAddTodoSheet = !this.isShowAddTodoSheet;
            },
            onClose: () => {
              this.isShowAddTodoSheet = !this.isShowAddTodoSheet;
            }
          }), {
            height: SheetSize.LARGE,
            preferType: SheetType.BOTTOM,
            showClose: false
          })
      }
      .align(Alignment.TopStart)
      .height('90%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .padding({ top: px2vp(this.avoidArea.topRectHeight) })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}


