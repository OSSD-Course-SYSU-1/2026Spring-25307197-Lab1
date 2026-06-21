import { distributedDataObject } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { DeviceManagerUtil, DeviceInfo } from './DeviceManagerUtil';
import { TodoItem } from '../model/TodoItem';

const LOG_DOMAIN = 0xFF00;
const LOG_TAG = 'TransferUtil';

/**
 * 传输状态枚举
 */
export enum TransferState {
  IDLE = 0,        // 空闲
  TRANSFERRING = 1, // 传输中
  SUCCESS = 2,     // 成功
  FAILED = 3       // 失败
}

/**
 * 传输结果接口
 */
export interface TransferResult {
  success: boolean;
  errorCode?: number;
  errorMsg?: string;
  deviceId?: string;
}

/**
 * 传输进度回调接口
 */
export interface TransferCallback {
  onProgress?: (state: TransferState, progress: number) => void;
  onSuccess?: (result: TransferResult) => void;
  onFailed?: (result: TransferResult) => void;
}

/**
 * 接收数据回调接口
 */
export interface ReceiveCallback {
  onTodoReceived?: (todoItem: TodoItem, fromDeviceId: string) => void;
  onBatchReceived?: (todoItems: TodoItem[], fromDeviceId: string) => void;
}

/**
 * TodoItem 数据接口（用于分布式数据传输）
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
 * 待办事项传输数据模型
 * 用于分布式数据对象传输
 */
class TodoTransferData {
  todoItem: TodoItemData | null = null;
  todoItems: TodoItemData[] = [];
  timestamp: number = 0;
  fromDeviceId: string = '';
  transferType: string = 'single'; // 'single' | 'batch'
}

/**
 * TransferUtil 工具类
 * 实现待办事项跨设备发送功能
 * 
 * 使用示例:
 * ```typescript
 * // 初始化
 * const transferUtil = TransferUtil.getInstance();
 * await transferUtil.init(context, bundleName);
 * 
 * // 发送单个待办
 * transferUtil.sendTodoToDevice(todoItem, targetDeviceId, {
 *   onSuccess: (result) => console.log('发送成功'),
 *   onFailed: (result) => console.log('发送失败')
 * });
 * 
 * // 接收待办
 * transferUtil.registerReceiveCallback({
 *   onTodoReceived: (todo, fromDevice) => {
 *     console.log('收到待办:', todo.title);
 *   }
 * });
 * ```
 */
export class TransferUtil {
  private static instance: TransferUtil | null = null;
  
  private context: common.UIAbilityContext | null = null;
  private distributedObject: distributedDataObject.DataObject | null = null;
  private sessionId: string = '';
  private transferState: TransferState = TransferState.IDLE;
  
  private transferCallback: TransferCallback | null = null;
  private receiveCallback: ReceiveCallback | null = null;
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  public static getInstance(): TransferUtil {
    if (!TransferUtil.instance) {
      TransferUtil.instance = new TransferUtil();
    }
    return TransferUtil.instance;
  }
  
  /**
   * 初始化传输工具
   * @param context UIAbility上下文
   * @param bundleName 应用包名
   */
  public async init(context: common.UIAbilityContext, bundleName: string): Promise<boolean> {
    if (this.context) {
      hilog.info(LOG_DOMAIN, LOG_TAG, 'TransferUtil already initialized');
      return true;
    }
    
    try {
      this.context = context;
      
      // 初始化设备管理器
      const deviceManager = DeviceManagerUtil.getInstance();
      await deviceManager.init(bundleName);
      
      hilog.info(LOG_DOMAIN, LOG_TAG, 'TransferUtil initialized successfully');
      return true;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to init TransferUtil: ${e.code}, ${e.message}`);
      return false;
    }
  }
  
  /**
   * 发送单个待办事项到指定设备
   * @param todoItem 待办事项
   * @param targetDeviceId 目标设备ID
   * @param callback 传输回调
   */
  public async sendTodoToDevice(
    todoItem: TodoItem,
    targetDeviceId: string,
    callback?: TransferCallback
  ): Promise<TransferResult> {
    if (!this.context) {
      const result: TransferResult = {
        success: false,
        errorCode: -1,
        errorMsg: 'TransferUtil not initialized'
      };
      callback?.onFailed?.(result);
      return result;
    }
    
    this.transferCallback = callback ?? null;
    this.transferState = TransferState.TRANSFERRING;
    this.transferCallback?.onProgress?.(this.transferState, 0);
    
    try {
      // 创建分布式数据对象
      const transferData = new TodoTransferData();
      transferData.todoItem = this.convertToData(todoItem);
      transferData.timestamp = Date.now();
      transferData.fromDeviceId = DeviceManagerUtil.getInstance().getLocalDeviceId();
      transferData.transferType = 'single';
      
      // 创建分布式对象并设置sessionId
      this.distributedObject = distributedDataObject.create(this.context, transferData);
      this.sessionId = distributedDataObject.genSessionId();
      this.distributedObject.setSessionId(this.sessionId);
      
      hilog.info(LOG_DOMAIN, LOG_TAG, `Sending todo to device: ${targetDeviceId}`);
      
      // 保存数据到目标设备
      await this.distributedObject.save(targetDeviceId);
      
      this.transferState = TransferState.SUCCESS;
      this.transferCallback?.onProgress?.(this.transferState, 100);
      
      const result: TransferResult = {
        success: true,
        deviceId: targetDeviceId
      };
      this.transferCallback?.onSuccess?.(result);
      
      hilog.info(LOG_DOMAIN, LOG_TAG, 'Todo sent successfully');
      return result;
      
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to send todo: ${e.code}, ${e.message}`);
      
      this.transferState = TransferState.FAILED;
      this.transferCallback?.onProgress?.(this.transferState, 0);
      
      const result: TransferResult = {
        success: false,
        errorCode: e.code,
        errorMsg: e.message,
        deviceId: targetDeviceId
      };
      this.transferCallback?.onFailed?.(result);
      return result;
    }
  }
  
  /**
   * 批量发送待办事项到指定设备
   * @param todoItems 待办事项数组
   * @param targetDeviceId 目标设备ID
   * @param callback 传输回调
   */
  public async sendBatchTodoToDevice(
    todoItems: TodoItem[],
    targetDeviceId: string,
    callback?: TransferCallback
  ): Promise<TransferResult> {
    if (!this.context) {
      const result: TransferResult = {
        success: false,
        errorCode: -1,
        errorMsg: 'TransferUtil not initialized'
      };
      callback?.onFailed?.(result);
      return result;
    }
    
    this.transferCallback = callback ?? null;
    this.transferState = TransferState.TRANSFERRING;
    this.transferCallback?.onProgress?.(this.transferState, 0);
    
    try {
      // 创建分布式数据对象
      const transferData = new TodoTransferData();
      transferData.todoItems = todoItems.map(item => this.convertToData(item));
      transferData.timestamp = Date.now();
      transferData.fromDeviceId = DeviceManagerUtil.getInstance().getLocalDeviceId();
      transferData.transferType = 'batch';
      
      // 创建分布式对象并设置sessionId
      this.distributedObject = distributedDataObject.create(this.context, transferData);
      this.sessionId = distributedDataObject.genSessionId();
      this.distributedObject.setSessionId(this.sessionId);
      
      hilog.info(LOG_DOMAIN, LOG_TAG, `Sending ${todoItems.length} todos to device: ${targetDeviceId}`);
      
      // 保存数据到目标设备
      await this.distributedObject.save(targetDeviceId);
      
      this.transferState = TransferState.SUCCESS;
      this.transferCallback?.onProgress?.(this.transferState, 100);
      
      const result: TransferResult = {
        success: true,
        deviceId: targetDeviceId
      };
      this.transferCallback?.onSuccess?.(result);
      
      hilog.info(LOG_DOMAIN, LOG_TAG, 'Batch todos sent successfully');
      return result;
      
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to send batch todos: ${e.code}, ${e.message}`);
      
      this.transferState = TransferState.FAILED;
      this.transferCallback?.onProgress?.(this.transferState, 0);
      
      const result: TransferResult = {
        success: false,
        errorCode: e.code,
        errorMsg: e.message,
        deviceId: targetDeviceId
      };
      this.transferCallback?.onFailed?.(result);
      return result;
    }
  }
  
  /**
   * 注册接收待办事项回调
   * @param callback 接收回调
   */
  public registerReceiveCallback(callback: ReceiveCallback): void {
    if (!this.context) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'TransferUtil not initialized');
      return;
    }
    
    this.receiveCallback = callback;
    
    // 创建空的分布式数据对象用于接收
    const emptyData = new TodoTransferData();
    this.distributedObject = distributedDataObject.create(this.context, emptyData);
    
    // 监听数据变更
    this.distributedObject.on('change', (sessionId: string, fields: Array<string>) => {
      hilog.info(LOG_DOMAIN, LOG_TAG, `Data changed, sessionId: ${sessionId}, fields: ${fields.join(',')}`);
      this.handleDataChange();
    });
    
    // 监听状态变更
    this.distributedObject.on('status', (sessionId: string, networkId: string, status: string) => {
      hilog.info(LOG_DOMAIN, LOG_TAG, `Status changed: ${status}, sessionId: ${sessionId}, networkId: ${networkId}`);
      
      if (status === 'restored') {
        // 数据恢复完成,处理接收到的数据
        this.handleDataChange();
      }
    });
    
    hilog.info(LOG_DOMAIN, LOG_TAG, 'Receive callback registered');
  }
  
  /**
   * 安全获取分布式对象的字符串属性
   */
  private getStringProperty(key: string): string {
    if (!this.distributedObject) return '';
    try {
      return Reflect.get(this.distributedObject, key) as string;
    } catch {
      return '';
    }
  }
  
  /**
   * 安全获取分布式对象的对象属性
   */
  private getObjectProperty<T>(key: string): T | null {
    if (!this.distributedObject) return null;
    try {
      return Reflect.get(this.distributedObject, key) as T;
    } catch {
      return null;
    }
  }
  
  /**
   * 处理数据变更
   */
  private handleDataChange(): void {
    if (!this.distributedObject || !this.receiveCallback) return;
    
    try {
      const transferType = this.getStringProperty('transferType');
      const fromDeviceId = this.getStringProperty('fromDeviceId');
      
      if (transferType === 'single') {
        // 单个待办
        const todoData = this.getObjectProperty<TodoItemData>('todoItem');
        if (todoData) {
          const todoItem = this.parseTodoItem(todoData);
          hilog.info(LOG_DOMAIN, LOG_TAG, `Received todo: ${todoItem.title} from ${fromDeviceId}`);
          promptAction.showToast({ message: '接收成功' });
          this.receiveCallback.onTodoReceived?.(todoItem, fromDeviceId);
        }
      } else if (transferType === 'batch') {
        // 批量待办
        const todoItemsData = this.getObjectProperty<TodoItemData[]>('todoItems');
        if (todoItemsData && todoItemsData.length > 0) {
          const todoItems: TodoItem[] = todoItemsData.map((data: TodoItemData): TodoItem => this.parseTodoItem(data));
          hilog.info(LOG_DOMAIN, LOG_TAG, `Received ${todoItems.length} todos from ${fromDeviceId}`);
          promptAction.showToast({ message: '接收成功' });
          this.receiveCallback.onBatchReceived?.(todoItems, fromDeviceId);
        }
      }
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to handle data change: ${e.code}, ${e.message}`);
    }
  }
  
  /**
   * 解析待办事项数据
   */
  private parseTodoItem(data: TodoItemData): TodoItem {
    // 从分布式对象中解析待办事项
    return new TodoItem(
      data.taskID,
      data.title,
      new Date(data.planTime),
      data.repetitionType,
      data.reminderType,
      data.priorityType,
      data.isFinished
    );
  }
  
  /**
   * 将TodoItem转换为可序列化的数据格式
   */
  private convertToData(todoItem: TodoItem): TodoItemData {
    return {
      taskID: todoItem.taskID,
      title: todoItem.title,
      planTime: todoItem.planTime.getTime(),
      repetitionType: todoItem.repetitionType,
      reminderType: todoItem.reminderType,
      priorityType: todoItem.priorityType,
      isFinished: todoItem.isFinished
    };
  }
  
  /**
   * 加入分布式会话
   * @param sessionId 会话ID
   */
  public joinSession(sessionId: string): boolean {
    if (!this.distributedObject) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'Distributed object not created');
      return false;
    }
    
    try {
      this.distributedObject.setSessionId(sessionId);
      this.sessionId = sessionId;
      hilog.info(LOG_DOMAIN, LOG_TAG, `Joined session: ${sessionId}`);
      return true;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to join session: ${e.code}, ${e.message}`);
      return false;
    }
  }
  
  /**
   * 退出分布式会话
   */
  public leaveSession(): void {
    if (!this.distributedObject) return;
    
    try {
      this.distributedObject.setSessionId('');
      this.sessionId = '';
      hilog.info(LOG_DOMAIN, LOG_TAG, 'Left session');
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to leave session: ${e.code}, ${e.message}`);
    }
  }
  
  /**
   * 获取当前传输状态
   */
  public getTransferState(): TransferState {
    return this.transferState;
  }
  
  /**
   * 获取当前会话ID
   */
  public getSessionId(): string {
    return this.sessionId;
  }
  
  /**
   * 释放资源
   */
  public release(): void {
    try {
      if (this.distributedObject) {
        // 取消监听
        this.distributedObject.off('change');
        this.distributedObject.off('status');
        this.distributedObject = null;
      }
      
      this.context = null;
      this.sessionId = '';
      this.transferState = TransferState.IDLE;
      this.transferCallback = null;
      this.receiveCallback = null;
      
      hilog.info(LOG_DOMAIN, LOG_TAG, 'TransferUtil released');
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to release TransferUtil: ${e.code}, ${e.message}`);
    }
  }
}

/**
 * 导出单例实例
 */
export const transferUtil = TransferUtil.getInstance();
