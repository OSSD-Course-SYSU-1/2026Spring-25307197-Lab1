import { preferences } from '@kit.ArkData';
import { TodoItem } from '@ohos_agcit/daily_schedule_common_lib';
import { Logger } from '@ohos_agcit/daily_schedule_common_lib';

/**
 * 待办数据序列化接口
 */
interface TodoItemData {
  taskID: string;
  title: string;
  planTime: number;
  repetitionType: number;
  reminderType: number;
  priorityType: number;
  isFinished: boolean;
}

/**
 * 待办数据持久化管理器
 * 负责将待办数据保存到本地Preferences，实现数据持久化
 */
export class TodoPersistenceManager {
  private static readonly TODO_DATA_KEY = 'todo_data_list';
  private static readonly TODO_PREFERENCES_NAME = 'todo_preferences';
  private static dataPreferences: preferences.Preferences | null = null;
  private static _instance: TodoPersistenceManager;

  private constructor() {}

  static get instance(): TodoPersistenceManager {
    if (!TodoPersistenceManager._instance) {
      TodoPersistenceManager._instance = new TodoPersistenceManager();
    }
    return TodoPersistenceManager._instance;
  }

  /**
   * 初始化Preferences
   * @param context 应用上下文
   */
  public static init(context: Context): void {
    try {
      TodoPersistenceManager.dataPreferences = preferences.getPreferencesSync(context, {
        name: TodoPersistenceManager.TODO_PREFERENCES_NAME
      });
      Logger.info('TodoPersistenceManager', 'Preferences initialized successfully');
    } catch (error) {
      Logger.error('TodoPersistenceManager', `Failed to initialize Preferences: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 保存所有待办数据到本地
   * @param todoList 待办列表
   */
  public saveTodoList(todoList: TodoItem[]): void {
    if (!TodoPersistenceManager.dataPreferences) {
      Logger.error('TodoPersistenceManager', 'Preferences not initialized');
      return;
    }

    try {
      // 将TodoItem数组序列化为JSON字符串数组
      const todoDataList: string[] = todoList.map(item => this.serializeTodoItem(item));
      
      // 保存到Preferences
      TodoPersistenceManager.dataPreferences.putSync(TodoPersistenceManager.TODO_DATA_KEY, todoDataList);
      TodoPersistenceManager.dataPreferences.flushSync();
      
      Logger.info('TodoPersistenceManager', `Saved ${todoList.length} todo items`);
    } catch (error) {
      Logger.error('TodoPersistenceManager', `Failed to save todo list: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 从本地加载所有待办数据
   * @returns 待办列表
   */
  public loadTodoList(): TodoItem[] {
    if (!TodoPersistenceManager.dataPreferences) {
      Logger.error('TodoPersistenceManager', 'Preferences not initialized');
      return [];
    }

    try {
      // 从Preferences读取数据
      const todoDataList = TodoPersistenceManager.dataPreferences.getSync(
        TodoPersistenceManager.TODO_DATA_KEY, 
        []
      ) as string[];

      if (!todoDataList || todoDataList.length === 0) {
        Logger.info('TodoPersistenceManager', 'No saved todo data found');
        return [];
      }

      // 反序列化为TodoItem数组
      const todoList: TodoItem[] = todoDataList.map(data => this.deserializeTodoItem(data));
      
      Logger.info('TodoPersistenceManager', `Loaded ${todoList.length} todo items`);
      return todoList;
    } catch (error) {
      Logger.error('TodoPersistenceManager', `Failed to load todo list: ${JSON.stringify(error)}`);
      return [];
    }
  }

  /**
   * 清空所有保存的待办数据
   */
  public clearTodoList(): void {
    if (!TodoPersistenceManager.dataPreferences) {
      Logger.error('TodoPersistenceManager', 'Preferences not initialized');
      return;
    }

    try {
      TodoPersistenceManager.dataPreferences.deleteSync(TodoPersistenceManager.TODO_DATA_KEY);
      TodoPersistenceManager.dataPreferences.flushSync();
      Logger.info('TodoPersistenceManager', 'Cleared all todo data');
    } catch (error) {
      Logger.error('TodoPersistenceManager', `Failed to clear todo list: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 序列化TodoItem为JSON字符串
   * @param item 待办项
   * @returns JSON字符串
   */
  private serializeTodoItem(item: TodoItem): string {
    const data: TodoItemData = {
      taskID: item.taskID,
      title: item.title,
      planTime: item.planTime.getTime(), // 将Date转换为时间戳
      repetitionType: item.repetitionType,
      reminderType: item.reminderType,
      priorityType: item.priorityType,
      isFinished: item.isFinished
    };
    return JSON.stringify(data);
  }

  /**
   * 从JSON字符串反序列化为TodoItem
   * @param data JSON字符串
   * @returns TodoItem对象
   */
  private deserializeTodoItem(data: string): TodoItem {
    const obj: TodoItemData = JSON.parse(data) as TodoItemData;
    return new TodoItem(
      obj.taskID,
      obj.title,
      new Date(obj.planTime), // 将时间戳转换回Date
      obj.repetitionType,
      obj.reminderType,
      obj.priorityType,
      obj.isFinished
    );
  }

  /**
   * 检查是否有保存的数据
   * @returns 是否有保存的数据
   */
  public hasSavedData(): boolean {
    if (!TodoPersistenceManager.dataPreferences) {
      return false;
    }

    try {
      const todoDataList = TodoPersistenceManager.dataPreferences.getSync(
        TodoPersistenceManager.TODO_DATA_KEY, 
        []
      ) as string[];
      return todoDataList && todoDataList.length > 0;
    } catch (error) {
      return false;
    }
  }
}
