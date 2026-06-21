/**
 * TransferUtil 使用示例
 * 演示如何使用 TransferUtil 实现待办事项跨设备发送
 */
import { TransferUtil, transferUtil, TransferState } from './TransferUtil';
import { DeviceManagerUtil, DeviceInfo, deviceManagerUtil } from './DeviceManagerUtil';
import { TodoItem } from '../model/TodoItem';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const LOG_DOMAIN = 0xFF00;
const LOG_TAG = 'TransferExample';

/**
 * TransferUtil 使用示例类
 */
export class TransferExample {
  private context: common.UIAbilityContext;
  private isInitialized: boolean = false;
  
  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }
  
  /**
   * 初始化示例
   */
  async init(): Promise<void> {
    if (this.isInitialized) return;
    
    try {
      // 初始化传输工具
      const bundleName = this.context.abilityInfo.bundleName;
      await transferUtil.init(this.context, bundleName);
      await deviceManagerUtil.init(bundleName);
      
      // 注册接收回调
      this.setupReceiveCallback();
      
      // 开始设备发现
      this.startDeviceDiscovery();
      
      this.isInitialized = true;
      hilog.info(LOG_DOMAIN, LOG_TAG, 'TransferExample initialized');
    } catch (err) {
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to init: ${err}`);
    }
  }
  
  /**
   * 设置接收回调
   */
  private setupReceiveCallback(): void {
    transferUtil.registerReceiveCallback({
      onTodoReceived: (todoItem: TodoItem, fromDeviceId: string) => {
        hilog.info(LOG_DOMAIN, LOG_TAG, 
          `收到待办事项: ${todoItem.title}, 来自设备: ${fromDeviceId}`);
        
        // 这里可以处理接收到的待办事项
        // 例如: 保存到本地数据库、更新UI等
        this.handleReceivedTodo(todoItem);
      },
      
      onBatchReceived: (todoItems: TodoItem[], fromDeviceId: string) => {
        hilog.info(LOG_DOMAIN, LOG_TAG, 
          `收到 ${todoItems.length} 个待办事项, 来自设备: ${fromDeviceId}`);
        
        // 批量处理接收到的待办事项
        todoItems.forEach(item => this.handleReceivedTodo(item));
      }
    });
  }
  
  /**
   * 开始设备发现
   */
  private startDeviceDiscovery(): void {
    deviceManagerUtil.startDiscovering({
      onDeviceFound: (device: DeviceInfo) => {
        hilog.info(LOG_DOMAIN, LOG_TAG, 
          `发现设备: ${device.deviceName} (${device.deviceType})`);
      },
      onDiscoverFailed: (errorCode: number) => {
        hilog.error(LOG_DOMAIN, LOG_TAG, `设备发现失败: ${errorCode}`);
      }
    });
  }
  
  /**
   * 发送单个待办事项示例
   */
  async sendSingleTodo(): Promise<void> {
    // 创建测试待办事项
    const todoItem = new TodoItem(
      `task_${Date.now()}`,
      '完成项目报告',
      new Date(),
      0, // 不重复
      1, // 提醒
      2, // 高优先级
      false
    );
    
    // 获取可用设备列表
    const devices = deviceManagerUtil.getAvailableDeviceListSync();
    
    if (devices.length === 0) {
      hilog.warn(LOG_DOMAIN, LOG_TAG, '没有可用的目标设备');
      return;
    }
    
    // 选择第一个设备作为目标
    const targetDevice = devices[0];
    
    // 发送待办事项
    const result = await transferUtil.sendTodoToDevice(
      todoItem,
      targetDevice.deviceId,
      {
        onProgress: (state, progress) => {
          hilog.info(LOG_DOMAIN, LOG_TAG, 
            `传输进度: 状态=${state}, 进度=${progress}%`);
        },
        onSuccess: (result) => {
          hilog.info(LOG_DOMAIN, LOG_TAG, 
            `发送成功, 目标设备: ${result.deviceId}`);
        },
        onFailed: (result) => {
          hilog.error(LOG_DOMAIN, LOG_TAG, 
            `发送失败: ${result.errorCode} - ${result.errorMsg}`);
        }
      }
    );
    
    if (result.success) {
      hilog.info(LOG_DOMAIN, LOG_TAG, '待办事项发送成功');
    } else {
      hilog.error(LOG_DOMAIN, LOG_TAG, '待办事项发送失败');
    }
  }
  
  /**
   * 批量发送待办事项示例
   */
  async sendBatchTodos(): Promise<void> {
    // 创建多个测试待办事项
    const todoItems: TodoItem[] = [];
    
    for (let i = 0; i < 5; i++) {
      const todo = new TodoItem(
        `task_${Date.now()}_${i}`,
        `待办事项 ${i + 1}`,
        new Date(Date.now() + i * 3600000), // 每小时一个
        0,
        1,
        i % 3, // 优先级循环
        false
      );
      todoItems.push(todo);
    }
    
    // 获取可用设备列表
    const devices = deviceManagerUtil.getAvailableDeviceListSync();
    
    if (devices.length === 0) {
      hilog.warn(LOG_DOMAIN, LOG_TAG, '没有可用的目标设备');
      return;
    }
    
    // 选择第一个设备作为目标
    const targetDevice = devices[0];
    
    // 批量发送待办事项
    const result = await transferUtil.sendBatchTodoToDevice(
      todoItems,
      targetDevice.deviceId,
      {
        onProgress: (state, progress) => {
          hilog.info(LOG_DOMAIN, LOG_TAG, 
            `批量传输进度: 状态=${state}, 进度=${progress}%`);
        },
        onSuccess: (result) => {
          hilog.info(LOG_DOMAIN, LOG_TAG, 
            `批量发送成功, 目标设备: ${result.deviceId}`);
        },
        onFailed: (result) => {
          hilog.error(LOG_DOMAIN, LOG_TAG, 
            `批量发送失败: ${result.errorCode} - ${result.errorMsg}`);
        }
      }
    );
    
    if (result.success) {
      hilog.info(LOG_DOMAIN, LOG_TAG, `成功发送 ${todoItems.length} 个待办事项`);
    } else {
      hilog.error(LOG_DOMAIN, LOG_TAG, '批量发送失败');
    }
  }
  
  /**
   * 处理接收到的待办事项
   */
  private handleReceivedTodo(todoItem: TodoItem): void {
    // 这里可以实现具体的业务逻辑
    // 例如:
    // 1. 保存到本地数据库
    // 2. 更新UI显示
    // 3. 发送通知
    // 4. 同步到云端等
    
    hilog.info(LOG_DOMAIN, LOG_TAG, 
      `处理接收到的待办: ID=${todoItem.taskID}, 标题=${todoItem.title}`);
    
    // 示例: 打印待办详情
    hilog.info(LOG_DOMAIN, LOG_TAG, 
      `待办详情: 计划时间=${todoItem.planTime}, 优先级=${todoItem.priorityType}, 是否完成=${todoItem.isFinished}`);
  }
  
  /**
   * 获取可用设备列表
   */
  getAvailableDevices(): DeviceInfo[] {
    return deviceManagerUtil.getAvailableDeviceListSync();
  }
  
  /**
   * 获取传输状态
   */
  getTransferState(): TransferState {
    return transferUtil.getTransferState();
  }
  
  /**
   * 释放资源
   */
  release(): void {
    transferUtil.release();
    deviceManagerUtil.release();
    this.isInitialized = false;
    hilog.info(LOG_DOMAIN, LOG_TAG, 'TransferExample released');
  }
}

/**
 * 使用示例:
 * 
 * // 在页面或组件中使用
 * const context = getContext(this) as common.UIAbilityContext;
 * const transferExample = new TransferExample(context);
 * 
 * // 初始化
 * await transferExample.init();
 * 
 * // 发送单个待办
 * await transferExample.sendSingleTodo();
 * 
 * // 批量发送
 * await transferExample.sendBatchTodos();
 * 
 * // 获取可用设备
 * const devices = transferExample.getAvailableDevices();
 * console.log('可用设备数量:', devices.length);
 * 
 * // 释放资源
 * transferExample.release();
 */
