import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { TodoItem } from '@ohos_agcit/daily_schedule_common_lib';
import { addTodoTaskBuilder } from './builder/AddTodoTaskBuilder';
import { TodoDataManager } from '../mock/TodoDataManager';
import { ExtInfo, FilterInfo, TodoListTabInfo } from '../mock/TitleDataManager';
import { TodoTitleBar } from './components/TodoTitleBar';
import { AddTodoVM, UpdateTodoPlanTimeVM } from '../mock/TodoInfoVM';
import { TodoSectionList } from './components/TodoSectionList';
import { StatusFilterEnum } from '../enum/FilterEnum';
import { AppStorageV2 } from '@kit.ArkUI';
import { EmptyStateComponent } from '../emptystate/EmptyStateComponent';
import { display } from '@kit.ArkUI';

// 极小窗口阈值（宽度小于此值时精简UI）
const MIN_WINDOW_WIDTH: number = 320;
// 紧凑窗口阈值
const COMPACT_WINDOW_WIDTH: number = 400;

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
  // 窗口尺寸状态（用于极小窗口自适应）
  @Local windowWidth: number = 360;
  @Local windowHeight: number = 640;
  // 极小窗口判断
  private get isMinimalWindow(): boolean {
    return this.windowWidth < MIN_WINDOW_WIDTH;
  }
  // 紧凑窗口判断
  private get isCompactWindow(): boolean {
    return this.windowWidth < COMPACT_WINDOW_WIDTH;
  }

  aboutToAppear(): void {
    this.restoreData()
    // 初始化窗口尺寸
    this.initWindowSize()
    // 调试日志：检查空状态功能是否工作
    console.info('[TodoPage] aboutToAppear - allTasks.length:', this.dataManager.allTasks.length)
    console.info('[TodoPage] 是否显示空状态:', this.dataManager.allTasks.length === 0)
    // this.dataManager.addTask(new TodoItem('2000', '思考人生', new Date('2025-10-11T08:00:00'), 0, 0, 0, false))
    // this.dataManager.addTask(new TodoItem('2001', '起床', new Date('2025-10-11T08:08:00'), 0, 0, 0, false))
    // this.dataManager.addTask(new TodoItem('2002', '吃饭', new Date('2025-10-11T08:09:00'), 0, 0, 1, false))
    // this.dataManager.addTask(new TodoItem('2003', '坐公交车', new Date('2025-10-11T08:11:00'), 0, 0, 1, false))
    // this.dataManager.addTask(new TodoItem('2004', '坐地铁', new Date('2025-10-11T08:12:00'), 0, 0, 2, false))
    // this.dataManager.addTask(new TodoItem('2005', '坐飞机', new Date('2025-10-11T08:22:00'), 0, 0, 2, false))
    // this.dataManager.addTask(new TodoItem('2006', '要记得上班打卡', new Date('2025-10-11T12:02:00'), 0, 0, 3, false))
    // this.dataManager.addTask(new TodoItem('2007', '梦游', new Date('2025-10-22T14:00:00'), 0, 0, 3, false))
  }

  // 初始化窗口尺寸
  private initWindowSize(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync();
      this.windowWidth = displayInfo.width;
      this.windowHeight = displayInfo.height;
      console.info(`[TodoPage] Window size: ${this.windowWidth}x${this.windowHeight}`);
    } catch (e) {
      console.warn(`[TodoPage] Failed to get display info: ${e}`);
    }
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
        // 极小窗口时精简标题栏UI
        isCompactMode: this.isCompactWindow,
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
          // 使用新的空状态组件（支持趣味文案和自定义）
          Column() {
            EmptyStateComponent()
          }
          .justifyContent(FlexAlign.Center)
          .height('60%')
          .width('100%')
        }


        Image($r('app.media.icon_add'))
          // 极小窗口时缩小按钮尺寸，保证功能按钮可见
          .height(this.isMinimalWindow ? 36 : 44)
          .width(this.isMinimalWindow ? 36 : 44)
          .onClick(() => {
            this.restoreData()
            this.isShowAddTodoSheet = !this.isShowAddTodoSheet
          })
          .zIndex(2)
          // 极小窗口时调整按钮位置，确保在可视区域内
          .position({ 
            x: this.isMinimalWindow ? '70%' : '80%', 
            y: this.isMinimalWindow ? '80%' : '85%' 
          })
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
    // 安全区适配：避开刘海、挖孔、底部手势栏
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    // 监听窗口尺寸变化，实现极小窗口自适应
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      if (newValue.width !== undefined) {
        const width = newValue.width as number;
        if (width > 0 && Math.abs(width - this.windowWidth) > 10) {
          this.windowWidth = width;
          console.info(`[TodoPage] Window width changed: ${this.windowWidth}`);
        }
      }
    })
  }
}


