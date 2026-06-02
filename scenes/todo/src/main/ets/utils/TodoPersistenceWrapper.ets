import { TodoItem } from '@ohos_agcit/daily_schedule_component_lib';
import { Logger } from '@ohos_agcit/daily_schedule_common_lib';
import { TodoDataManager } from '../mock/TodoDataManager';
import { TodoPersistenceManager } from './TodoPersistenceManager';

/**
 * 待办数据持久化包装器
 * 
 * 功能说明：
 * 1. 包装 TodoDataManager，在数据变更时自动保存到本地
 * 2. 应用启动时自动加载历史数据
 * 3. 完全独立封装，不改动原有逻辑
 * 
 * 使用方式：
 * 1. 在 EntryAbility.onCreate 中调用 TodoPersistenceWrapper.init(context)
 * 2. 正常使用 TodoDataManager，数据会自动持久化
 */
export class TodoPersistenceWrapper {
  private static _instance: TodoPersistenceWrapper;
  private dataManager: TodoDataManager = TodoDataManager.instance;
  private persistenceManager: TodoPersistenceManager = TodoPersistenceManager.instance;
  private isInitialized: boolean = false;
  private saveTimer: number = -1;
  private static readonly SAVE_DELAY: number = 500; // 延迟保存时间（毫秒）

  private constructor() {}

  static get instance(): TodoPersistenceWrapper {
    if (!TodoPersistenceWrapper._instance) {
      TodoPersistenceWrapper._instance = new TodoPersistenceWrapper();
    }
    return TodoPersistenceWrapper._instance;
  }

  /**
   * 初始化持久化包装器
   * @param context 应用上下文
   */
  public static init(context: Context): void {
    try {
      // 初始化 Preferences
      TodoPersistenceManager.init(context);
      
      // 加载历史数据
      TodoPersistenceWrapper.instance.loadPersistedData();
      
      Logger.info('TodoPersistenceWrapper', 'Persistence wrapper initialized successfully');
    } catch (error) {
      Logger.error('TodoPersistenceWrapper', `Failed to initialize: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 加载持久化的历史数据
   */
  private loadPersistedData(): void {
    if (this.isInitialized) {
      return;
    }

    try {
      // 检查是否有保存的数据
      if (this.persistenceManager.hasSavedData()) {
        const savedTasks = this.persistenceManager.loadTodoList();
        
        if (savedTasks.length > 0) {
          // 清空现有数据，加载持久化数据
          this.dataManager.allTasks.splice(0, this.dataManager.allTasks.length);
          this.dataManager.allTasks.push(...savedTasks);
          
          // 触发数据刷新
          this.dataManager.onAllTasksChange();
          
          Logger.info('TodoPersistenceWrapper', `Loaded ${savedTasks.length} tasks from persistence`);
        }
      } else {
        Logger.info('TodoPersistenceWrapper', 'No saved data found, using default data');
      }
      
      this.isInitialized = true;
      
      // 启动自动保存监听
      this.startAutoSave();
      
    } catch (error) {
      Logger.error('TodoPersistenceWrapper', `Failed to load persisted data: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 启动自动保存监听
   * 通过监听 refreshNum 的变化来触发保存
   */
  private startAutoSave(): void {
    // 使用定时器定期检查数据变化并保存
    // 这里采用延迟保存策略，避免频繁写入
    setInterval(() => {
      this.checkAndSave();
    }, 1000); // 每秒检查一次
  }

  /**
   * 检查数据变化并保存
   */
  private checkAndSave(): void {
    if (!this.isInitialized) {
      return;
    }

    try {
      // 保存当前所有任务
      this.scheduleSave();
    } catch (error) {
      Logger.error('TodoPersistenceWrapper', `Failed to check and save: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 调度保存操作（延迟保存，避免频繁写入）
   */
  private scheduleSave(): void {
    // 清除之前的定时器
    if (this.saveTimer !== -1) {
      clearTimeout(this.saveTimer);
    }

    // 延迟保存
    this.saveTimer = setTimeout(() => {
      this.saveNow();
      this.saveTimer = -1;
    }, TodoPersistenceWrapper.SAVE_DELAY);
  }

  /**
   * 立即保存数据
   */
  public saveNow(): void {
    if (!this.isInitialized) {
      return;
    }

    try {
      this.persistenceManager.saveTodoList(this.dataManager.allTasks);
      Logger.info('TodoPersistenceWrapper', 'Data saved successfully');
    } catch (error) {
      Logger.error('TodoPersistenceWrapper', `Failed to save data: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 手动触发保存（供外部调用）
   */
  public static save(): void {
    TodoPersistenceWrapper.instance.saveNow();
  }

  /**
   * 清空持久化数据
   */
  public static clear(): void {
    TodoPersistenceWrapper.instance.persistenceManager.clearTodoList();
    Logger.info('TodoPersistenceWrapper', 'Persistence data cleared');
  }

  /**
   * 获取持久化状态
   * @returns 是否已初始化
   */
  public static isReady(): boolean {
    return TodoPersistenceWrapper.instance.isInitialized;
  }
}
