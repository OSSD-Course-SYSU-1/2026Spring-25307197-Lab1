import { TodoCard, TodoItem } from '@ohos_agcit/daily_schedule_component_lib';
import { PriorityEnum } from '@ohos_agcit/daily_schedule_todo';

export class Utils {
  /**
   * 过滤指定日期的所有任务
   * @param allTasks
   * @param date
   * @returns
   */
  static filterTodayTasks(allTasks: TodoItem[], date: Date): TodoItem[] {
    return allTasks
      .filter(x => x.isFinished === false)
      .filter(x => {
        const planDate = x.planTime;
        return planDate.getFullYear() === date.getFullYear() &&
          planDate.getMonth() === date.getMonth() &&
          planDate.getDate() === date.getDate();
      })
  }

  /**
   * 过滤指定日期的所有任务
   * @param allTasks
   * @param date
   * @returns
   */
  static getAllCard(taskMap: Map<string, TodoItem[]>): Map<string, TodoItem[]> {
    const cardMap = new Map<string, TodoItem[]>();
    taskMap.forEach((todoItems, key) => {
      const todoCards = todoItems.slice(0, 3)
      cardMap.set(key, todoCards);
    });

    return cardMap;
  }

  static chooseCardColor(item: TodoItem): ResourceColor | undefined {
    if (item.priorityType === PriorityEnum.NO) {
      return $r('app.color.card_gray')
    }
    if (item.priorityType === PriorityEnum.LOW) {
      return $r('app.color.card_green')
    }
    if (item.priorityType === PriorityEnum.MID) {
      return $r('app.color.card_orange')
    }
    if (item.priorityType === PriorityEnum.HIGH) {
      return $r('app.color.card_red')
    }
    return $r('app.color.card_gray')
  }
}