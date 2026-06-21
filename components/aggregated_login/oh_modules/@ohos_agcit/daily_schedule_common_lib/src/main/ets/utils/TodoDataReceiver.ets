import { TodoItem } from '../model/TodoItem';
import { Logger } from './Logger';

/**
 * 待办数据接收格式接口
 */
export interface TodoDataFormat {
  taskID?: string;
  title?: string;
  planTime?: number; // 时间戳
  repetitionType?: number;
  reminderType?: number;
  priorityType?: number;
  isFinished?: boolean;
}

/**
 * 待办操作类型
 */
export enum TodoAction {
  ADD = 'add',
  UPDATE = 'update',
  DELETE = 'delete'
}

/**
 * 数据接收结果
 */
export interface ReceiveResult {
  success: boolean;
  message: string;
  todoItem?: TodoItem;
}

/**
 * 同步数据包接口
 */
export interface SyncDataPacket {
  action: TodoAction;
  todoId: string;
  todoData: string;
  timestamp: number;
}

/**
 * 待办数据接收管理器
 * 负责接收、解析、验证和转换待办数据
 */
export class TodoDataReceiver {
  private static _instance: TodoDataReceiver;
  
  private constructor() {}
  
  static get instance(): TodoDataReceiver {
    if (!TodoDataReceiver._instance) {
      TodoDataReceiver._instance = new TodoDataReceiver();
    }
    return TodoDataReceiver._instance;
  }
  
  /**
   * 解析并验证待办JSON数据
   * @param jsonData JSON字符串
   * @returns 解析后的数据对象，如果解析失败返回null
   */
  public parseAndValidate(jsonData: string): TodoDataFormat | null {
    try {
      // 解析JSON
      const data = JSON.parse(jsonData) as TodoDataFormat;
      
      // 验证必要字段
      if (!this.validateTodoData(data)) {
        Logger.error('TodoDataReceiver', '数据验证失败：缺少必要字段');
        return null;
      }
      
      Logger.info('TodoDataReceiver', `数据解析成功: ${data.title || '未命名'}`);
      return data;
      
    } catch (error) {
      Logger.error('TodoDataReceiver', `JSON解析失败: ${JSON.stringify(error)}`);
      return null;
    }
  }
  
  /**
   * 验证待办数据的有效性
   * @param data 待办数据
   * @returns 是否有效
   */
  private validateTodoData(data: TodoDataFormat): boolean {
    // 标题不能为空（对于新增操作）
    if (data.title !== undefined && data.title.trim().length === 0) {
      Logger.error('TodoDataReceiver', '验证失败：标题不能为空');
      return false;
    }
    
    // 计划时间必须是有效的时间戳
    if (data.planTime !== undefined) {
      if (typeof data.planTime !== 'number' || data.planTime <= 0) {
        Logger.error('TodoDataReceiver', '验证失败：计划时间格式错误');
        return false;
      }
    }
    
    // 优先级必须在有效范围内
    if (data.priorityType !== undefined) {
      if (data.priorityType < 0 || data.priorityType > 3) {
        Logger.error('TodoDataReceiver', '验证失败：优先级超出范围');
        return false;
      }
    }
    
    // 重复类型必须在有效范围内
    if (data.repetitionType !== undefined) {
      if (data.repetitionType < 0 || data.repetitionType > 3) {
        Logger.error('TodoDataReceiver', '验证失败：重复类型超出范围');
        return false;
      }
    }
    
    // 提醒类型必须在有效范围内
    if (data.reminderType !== undefined) {
      if (data.reminderType < 0 || data.reminderType > 4) {
        Logger.error('TodoDataReceiver', '验证失败：提醒类型超出范围');
        return false;
      }
    }
    
    return true;
  }
  
  /**
   * 将解析的数据转换为TodoItem对象
   * @param data 解析后的数据
   * @param generateId 是否生成新ID（用于新增操作）
   * @returns TodoItem对象
   */
  public convertToTodoItem(data: TodoDataFormat, generateId: boolean = false): TodoItem {
    // 生成或使用提供的taskID
    const taskID = data.taskID || (generateId ? this.generateTaskId() : 'unknown');
    
    // 设置默认值
    const title = data.title || '未命名待办';
    const planTime = data.planTime ? new Date(data.planTime) : new Date();
    const repetitionType = data.repetitionType ?? 0;
    const reminderType = data.reminderType ?? 0;
    const priorityType = data.priorityType ?? 0;
    const isFinished = data.isFinished ?? false;
    
    return new TodoItem(taskID, title, planTime, repetitionType, reminderType, priorityType, isFinished);
  }
  
  /**
   * 生成唯一的任务ID
   * @returns 唯一ID字符串
   */
  private generateTaskId(): string {
    return `todo_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  /**
   * 批量解析待办数据
   * @param jsonDataArray JSON字符串数组
   * @returns 解析结果数组
   */
  public batchParse(jsonDataArray: string[]): ReceiveResult[] {
    const results: ReceiveResult[] = [];
    
    for (const jsonData of jsonDataArray) {
      const data = this.parseAndValidate(jsonData);
      
      if (data) {
        const todoItem = this.convertToTodoItem(data, true);
        results.push({
          success: true,
          message: '解析成功',
          todoItem
        });
      } else {
        results.push({
          success: false,
          message: '数据解析或验证失败'
        });
      }
    }
    
    Logger.info('TodoDataReceiver', `批量解析完成: ${results.filter(r => r.success).length}/${results.length} 成功`);
    return results;
  }
  
  /**
   * 创建待办数据的JSON字符串（用于发送）
   * @param todoItem 待办事项
   * @returns JSON字符串
   */
  public createTodoDataJson(todoItem: TodoItem): string {
    const data: TodoDataFormat = {
      taskID: todoItem.taskID,
      title: todoItem.title,
      planTime: todoItem.planTime.getTime(),
      repetitionType: todoItem.repetitionType,
      reminderType: todoItem.reminderType,
      priorityType: todoItem.priorityType,
      isFinished: todoItem.isFinished
    };
    
    return JSON.stringify(data);
  }
  
  /**
   * 创建同步数据包
   * @param action 操作类型
   * @param todoItem 待办事项
   * @returns 同步数据包
   */
  public createSyncDataPacket(action: TodoAction, todoItem: TodoItem): string {
    const packet: SyncDataPacket = {
      action,
      todoId: todoItem.taskID,
      todoData: this.createTodoDataJson(todoItem),
      timestamp: Date.now()
    };
    
    return JSON.stringify(packet);
  }
}
