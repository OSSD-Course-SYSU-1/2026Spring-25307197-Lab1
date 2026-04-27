import { TodoItem } from '@ohos_agcit/daily_schedule_component_lib';
import { CardManager, DateUtils, FormatUtil, FormDataClass } from '@ohos_agcit/daily_schedule_common_lib';
import { BaseResponse } from '@ohos_agcit/daily_schedule_network';
import { PriorityFilterEnum } from '../enum/FilterEnum';
import { TodoListTabInfo } from '../mock/TitleDataManager';
import { PriorityEnum } from '../enum/TodoItemEnum';

@ObservedV2
export class TodoDataManager {
  private static ID: number = 1000
  @Trace allTasks: TodoItem[] = []
  @Trace allNotCompleteTasks: TodoItem[] = []
  @Trace todayTasks: TodoItem[] = []
  @Trace tomorrowTasks: TodoItem[] = []
  @Trace expiredTasks: TodoItem[] = []
  @Trace finishedTasks: TodoItem[] = []
  @Trace taskMap: Map<string, TodoItem[]> = new Map();
  @Trace refreshNum: number = 0;
  private static _instance: TodoDataManager
  todoListTabInfo: TodoListTabInfo = TodoListTabInfo.instance

  static get instance() {
    if (!TodoDataManager._instance) {
      TodoDataManager._instance = new TodoDataManager();
      TodoDataManager._instance.allTasks = []
    }
    return TodoDataManager._instance;
  }

  onAllTasksChange(isDescending: boolean = true) {
    let priorityIndex = this.todoListTabInfo.priorityIndex

    let priorityValue: number | undefined = undefined;
    if (priorityIndex === PriorityFilterEnum.NO) {
      priorityValue = PriorityEnum.NO
    } else if (priorityIndex === PriorityFilterEnum.LOW) {
      priorityValue = PriorityEnum.LOW
    } else if (priorityIndex === PriorityFilterEnum.MID) {
      priorityValue = PriorityEnum.MID
    } else if (priorityIndex === PriorityFilterEnum.HIGH) {
      priorityValue = PriorityEnum.HIGH
    } else {
      priorityValue = undefined
    }

    this.todayTasks.splice(0, this.todayTasks.length)
    this.todayTasks.push(...this.refreshTodayTasks(isDescending, priorityValue))

    this.tomorrowTasks.splice(0, this.tomorrowTasks.length)
    this.tomorrowTasks.push(...this.refreshTomorrowTasks(isDescending, priorityValue))

    this.allNotCompleteTasks.splice(0, this.allNotCompleteTasks.length)
    this.allNotCompleteTasks.push(...this.refreshAllNotCompleteTasks(isDescending, priorityValue))

    this.expiredTasks.splice(0, this.expiredTasks.length)
    this.expiredTasks.push(...this.refreshExpiredTasks(isDescending, priorityValue))

    this.finishedTasks.splice(0, this.finishedTasks.length)
    this.finishedTasks.push(...this.refreshFinishedTasks(isDescending, priorityValue))

    this.taskMap.clear()
    this.allTasks.filter((item: TodoItem) => !item.isFinished).forEach((task: TodoItem) => {
      const dateKey = FormatUtil.formatDate(task.planTime, FormatUtil.DATE_YYYY_MM_DD)
      if (!this.taskMap.has(dateKey)) {
        this.taskMap.set(dateKey, []);
      }
      this.taskMap.get(dateKey)!.push(task);
    })
    this.refreshNum++

    this.updateAtomicCard()
  }

  loadMockTodos(): TodoItem[] {
    return [
      new TodoItem('1001', '起床', new Date('2025-08-28T12:00:00'), 0, 0, 0, false),
      new TodoItem('1002', '吃饭', new Date('2025-08-28T13:00:00'), 0, 0, 1, false),
      new TodoItem('1003', '洗澡', new Date('2025-08-28T14:00:00'), 0, 0, 2, false),
      new TodoItem('1004', '睡觉', new Date('2025-08-28T14:00:00'), 0, 0, 3, false)
    ]
  }

  public addTask(item: TodoItem): Promise<BaseResponse<undefined>> {
    this.addTodo(item);

    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  public sortTask(isDescending: boolean) {
    this.onAllTasksChange(isDescending)
  }

  public updateTaskPlanTime(taskID: string, planTime: Date) {
    this.updatePlanTime(taskID, planTime)
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  public updateTaskFinish(taskID: string, isFinished: boolean) {
    this.updateFinish(taskID, isFinished)
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  public deleteById(taskID: string) {
    const index = this.allTasks.findIndex((item: TodoItem) => item.taskID === taskID);
    if (index >= 0) {
      this.allTasks.splice(index, 1);
    }
    this.onAllTasksChange()
    let resp: BaseResponse = { code: 200, data: undefined };
    return Promise.resolve(resp);
  }

  static getId() {
    return '' + TodoDataManager.ID++
  }

  /**
   * 新增数据
   * @param todo
   */
  private addTodo(todo: TodoItem) {
    if (todo.taskID) {
      this.allTasks.push(todo)
    } else {
      todo.taskID = TodoDataManager.getId();
      this.allTasks.push(todo);
    }
    this.onAllTasksChange()
  }

  /**
   * 过滤数据
   * @param priorityIndex
   */
  private filter(priorityIndex: number) {
    if (priorityIndex === PriorityFilterEnum.ALL) {
      return
    }
    this.todayTasks = this.todayTasks.filter(x => x.priorityType === priorityIndex)
    this.tomorrowTasks = this.tomorrowTasks.filter(x => x.priorityType === priorityIndex)
    this.expiredTasks = this.expiredTasks.filter(x => x.priorityType === priorityIndex)
    this.finishedTasks = this.finishedTasks.filter(x => x.priorityType === priorityIndex)

    this.onAllTasksChange()
  }

  private updatePlanTime(taskID: string, planTime: Date) {
    const index = this.allTasks.findIndex((item: TodoItem) => item.taskID === taskID);
    if (index >= 0) {
      this.allTasks[index].planTime = planTime
    }
    this.onAllTasksChange()
  }

  private updateFinish(taskID: string, isFinished: boolean) {
    const index = this.allTasks.findIndex((item: TodoItem) => item.taskID === taskID);
    if (index >= 0) {
      this.allTasks[index].isFinished = isFinished
    }
    this.onAllTasksChange()
  }

  private refreshTodayTasks(isDescending: boolean, priorityType?: number): TodoItem[] {
    return this.allTasks
      .filter(item => item.isFinished === false)
      .filter(item => {
        if (priorityType) {
          return item.priorityType === priorityType
        }
        return true
      })
      .filter(item => DateUtils.isToday(FormatUtil.formatDate(item.planTime,
        FormatUtil.DATE_YYYY_MM_DD)))
      .sort((a, b) => {
        const timeA = a?.planTime ? new Date(a.planTime).getTime() : 0;
        const timeB = b?.planTime ? new Date(b.planTime).getTime() : 0;
        return isDescending ? timeB - timeA : timeA - timeB;
      });
  }

  private refreshTomorrowTasks(isDescending: boolean, priorityType?: number): TodoItem[] {
    return this.allTasks
      .filter(item => item.isFinished === false)
      .filter(item => DateUtils.isTomorrow(FormatUtil.formatDate(item.planTime,
        FormatUtil.DATE_YYYY_MM_DD)))
      .filter(item => {
        if (priorityType) {
          return item.priorityType === priorityType
        }
        return true
      })
      .sort((a, b) => {
        const timeA = a?.planTime ? new Date(a.planTime).getTime() : 0;
        const timeB = b?.planTime ? new Date(b.planTime).getTime() : 0;
        return isDescending ? timeB - timeA : timeA - timeB;
      });
  }

  private refreshAllNotCompleteTasks(isDescending: boolean, priorityType?: number): TodoItem[] {
    return this.allTasks
      .filter(item => item.isFinished === false)
      .filter(item => {
        if (priorityType) {
          return item.priorityType === priorityType
        }
        return true
      })
      .sort((a, b) => {
        const timeA = a?.planTime ? new Date(a.planTime).getTime() : 0;
        const timeB = b?.planTime ? new Date(b.planTime).getTime() : 0;
        return isDescending ? timeB - timeA : timeA - timeB;
      });
  }

  private refreshExpiredTasks(isDescending: boolean, priorityType?: number): TodoItem[] {
    return this.allTasks
      .filter(item => item.isFinished === false)
      .filter(item => DateUtils.isExpired(FormatUtil.formatDate(item.planTime,
        FormatUtil.DATE_YYYY_MM_DD)))
      .filter(item => {
        if (priorityType) {
          return item.priorityType === priorityType
        }
        return true
      })
      .sort((a, b) => {
        const timeA = a?.planTime ? new Date(a.planTime).getTime() : 0;
        const timeB = b?.planTime ? new Date(b.planTime).getTime() : 0;
        return isDescending ? timeB - timeA : timeA - timeB;
      });
  }

  private refreshFinishedTasks(isDescending: boolean, priorityType?: number): TodoItem[] {
    return this.allTasks
      .filter(item => item.isFinished === true)
      .filter(item => {
        if (priorityType) {
          return item.priorityType === priorityType
        }
        return true
      })
      .sort((a, b) => {
        const timeA = a?.planTime ? new Date(a.planTime).getTime() : 0;
        const timeB = b?.planTime ? new Date(b.planTime).getTime() : 0;
        return isDescending ? timeB - timeA : timeA - timeB;
      });
  }

  public updateAtomicCard() {
    let dataClass = new FormDataClass()
    dataClass.titles = this.todayTasks.map(item => item.title)
    CardManager.get().updateCard(dataClass)
  }
}


@ObservedV2
export class FilterStatusManager {
  @Trace statusIndex: number = 0;
  @Trace priorityIndex: number = 0;
  private static _instance: FilterStatusManager

  static get instance() {
    if (!FilterStatusManager._instance) {
      FilterStatusManager._instance = new FilterStatusManager();
    }
    return FilterStatusManager._instance;
  }
}