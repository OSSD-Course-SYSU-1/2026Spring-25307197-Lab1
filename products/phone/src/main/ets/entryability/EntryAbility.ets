import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { ThemeController, TodoDataReceiver, TodoAction, TodoItem, TodoDataFormat, DeviceManagerUtil, TransferUtil, transferUtil } from '@ohos_agcit/daily_schedule_common_lib';
import { WindowUtil } from '@ohos_agcit/daily_schedule_utils';
import { TodoDataManager, TodoPersistenceWrapper } from '@ohos_agcit/daily_schedule_todo';
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { distributedDataObject } from '@kit.ArkData';

const DOMAIN = 0x0000;

// 定义本地设备信息接口
interface LocalDeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: number;
  networkId: string;
}

// 定义设备状态变化数据接口
interface DeviceStateChangeData {
  action: distributedDeviceManager.DeviceStateChange;
  device: distributedDeviceManager.DeviceBasicInfo;
}

// 定义设备发现成功数据接口
interface DiscoverSuccessData {
  device: distributedDeviceManager.DeviceBasicInfo;
}

// 定义设备发现失败数据接口
interface DiscoverFailureData {
  reason: number;
}

// 定义避让区域变化数据接口
interface AvoidAreaChangeData {
  type: window.AvoidAreaType;
  area: window.AvoidArea;
}

export default class EntryAbility extends UIAbility {
  private themeController: ThemeController = ThemeController.instance;
  dataManager: TodoDataManager = TodoDataManager.instance;
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private todoDataObject: distributedDataObject.DataObject | null = null; // 分布式待办数据对象
  private dataReceiver: TodoDataReceiver = TodoDataReceiver.instance; // 数据接收管理器

  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    this.themeController.currentColorMode = this.context.config.colorMode;
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    
    // 初始化待办数据持久化
    TodoPersistenceWrapper.init(this.context);
    
    // 初始化分布式设备管理器
    this.initDeviceManager();
    
    // 初始化分布式软总线
    this.initDistributedSoftBus();
    
    // 初始化分布式待办数据对象
    this.initDistributedTodoObject();
  }
  
  /**
   * 初始化分布式设备管理器
   */
  private async initDeviceManager(): Promise<void> {
    try {
      const bundleName = this.context.abilityInfo.bundleName;
      
      // 初始化设备管理器
      const deviceManager = DeviceManagerUtil.getInstance();
      await deviceManager.init(bundleName);
      hilog.info(DOMAIN, 'DeviceManager', '设备管理器初始化成功');
      
      // 初始化传输工具
      await transferUtil.init(this.context, bundleName);
      hilog.info(DOMAIN, 'TransferUtil', '传输工具初始化成功');
      
      // 启动设备发现
      deviceManager.startDiscovering({
        onDeviceFound: (device) => {
          hilog.info(DOMAIN, 'DeviceManager', `发现设备: ${device.deviceName}`);
        },
        onDiscoverFailed: (errorCode) => {
          hilog.error(DOMAIN, 'DeviceManager', `设备发现失败: ${errorCode}`);
        }
      });
      hilog.info(DOMAIN, 'DeviceManager', '已启动设备发现');
      
    } catch (e) {
      const error = e as Error;
      hilog.error(DOMAIN, 'DeviceManager', `初始化失败: ${error.message}`);
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    
    // 释放分布式设备管理器
    this.releaseDistributedSoftBus();
    
    // 释放分布式待办数据对象
    this.releaseDistributedTodoObject();
  }
  
  /**
   * 初始化分布式待办数据对象
   */
  private initDistributedTodoObject(): void {
    try {
      hilog.info(DOMAIN, 'DistributedTodo', '开始初始化分布式待办数据对象');
      
      // 定义待办数据结构
      interface TodoSyncData {
        action: string; // 操作类型: 'add' | 'update' | 'delete'
        todoId: string;
        todoData?: string; // JSON序列化的待办数据
        timestamp: number;
        deviceId: string;
      }
      
      // 创建分布式数据对象
      const initData: TodoSyncData = {
        action: '',
        todoId: '',
        timestamp: 0,
        deviceId: ''
      };
      
      this.todoDataObject = distributedDataObject.create(this.context, initData);
      
      // 生成并设置sessionId (使用固定的sessionId以便多设备同步)
      const sessionId = 'todo_sync_session_' + this.context.applicationInfo.name;
      this.todoDataObject.setSessionId(sessionId);
      
      // 注册数据变更监听 - 接收其他设备发送的待办数据
      this.todoDataObject.on('change', (sessionId: string, fields: Array<string>) => {
        hilog.info(DOMAIN, 'DistributedTodo', `收到数据变更: sessionId=${sessionId}, fields=${JSON.stringify(fields)}`);
        
        if (this.todoDataObject) {
          const action = this.todoDataObject['action'] as string;
          const todoId = this.todoDataObject['todoId'] as string;
          const todoData = this.todoDataObject['todoData'] as string;
          const deviceId = this.todoDataObject['deviceId'] as string;
          
          hilog.info(DOMAIN, 'DistributedTodo', 
            `接收待办数据: action=${action}, todoId=${todoId}, from=${deviceId}`);
          
          // 处理接收到的待办数据
          this.handleReceivedTodoData(action, todoId, todoData, deviceId);
        }
      });
      
      // 注册状态监听 - 监听设备上下线
      this.todoDataObject.on('status', (sessionId: string, networkId: string, status: string) => {
        hilog.info(DOMAIN, 'DistributedTodo', 
          `设备状态变化: sessionId=${sessionId}, networkId=${networkId}, status=${status}`);
        
        if (status === 'online') {
          hilog.info(DOMAIN, 'DistributedTodo', `设备上线: ${networkId}`);
        } else if (status === 'offline') {
          hilog.info(DOMAIN, 'DistributedTodo', `设备下线: ${networkId}`);
        }
      });
      
      hilog.info(DOMAIN, 'DistributedTodo', '分布式待办数据对象初始化成功');
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedTodo', 
        `初始化分布式待办数据对象失败, errCode: ${e.code}, errMessage: ${e.message}`);
    }
  }
  
  /**
   * 处理接收到的待办数据
   * 自动解析JSON数据并插入本地待办列表，保存到数据库
   */
  private handleReceivedTodoData(action: string, todoId: string, todoData: string, deviceId: string): void {
    try {
      hilog.info(DOMAIN, 'DistributedTodo', 
        `开始处理待办数据: action=${action}, todoId=${todoId}, from=${deviceId}`);
      
      if (action === TodoAction.ADD && todoData) {
        // 新增待办 - 使用TodoDataReceiver解析和验证数据
        const data: TodoDataFormat | null = this.dataReceiver.parseAndValidate(todoData);
        if (data) {
          const todoItem: TodoItem = this.dataReceiver.convertToTodoItem(data, true);
          hilog.info(DOMAIN, 'DistributedTodo', 
            `新增待办: ${todoItem.title}, 计划时间: ${todoItem.planTime}, 优先级: ${todoItem.priorityType}`);
          
          // 调用TodoDataManager添加待办，自动触发数据变更和持久化
          this.dataManager.addTask(todoItem).then(() => {
            hilog.info(DOMAIN, 'DistributedTodo', '✓ 待办添加成功，已自动保存到数据库');
          }).catch((err: BusinessError) => {
            hilog.error(DOMAIN, 'DistributedTodo', `✗ 待办添加失败: ${err.message}`);
          });
        } else {
          hilog.error(DOMAIN, 'DistributedTodo', '✗ 数据验证失败，无法添加待办');
        }
        
      } else if (action === TodoAction.UPDATE && todoData) {
        // 更新待办 - 使用TodoDataReceiver解析数据
        const data: TodoDataFormat | null = this.dataReceiver.parseAndValidate(todoData);
        if (data) {
          hilog.info(DOMAIN, 'DistributedTodo', `更新待办: ${data.title || todoId}`);
          
          // 更新计划时间
          if (data.planTime) {
            this.dataManager.updateTaskPlanTime(todoId, new Date(data.planTime));
          }
          
          // 更新完成状态
          if (data.isFinished !== undefined) {
            this.dataManager.updateTaskFinish(todoId, data.isFinished);
          }
          
          hilog.info(DOMAIN, 'DistributedTodo', '✓ 待办更新成功，已自动保存到数据库');
        }
        
      } else if (action === TodoAction.DELETE) {
        // 删除待办
        hilog.info(DOMAIN, 'DistributedTodo', `删除待办: ${todoId}`);
        
        this.dataManager.deleteById(todoId).then(() => {
          hilog.info(DOMAIN, 'DistributedTodo', '✓ 待办删除成功，已自动保存到数据库');
        }).catch((err: BusinessError) => {
          hilog.error(DOMAIN, 'DistributedTodo', `✗ 待办删除失败: ${err.message}`);
        });
        
      } else {
        hilog.warn(DOMAIN, 'DistributedTodo', `未知的操作类型: ${action}`);
      }
      
      // 确保数据立即保存到本地数据库
      TodoPersistenceWrapper.save();
      
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedTodo', 
        `处理待办数据失败, errCode: ${e.code}, errMessage: ${e.message}`);
    }
  }
  
  /**
   * 发送待办数据到其他设备
   */
  public sendTodoData(action: string, todoId: string, todoData?: string): void {
    if (!this.todoDataObject) {
      hilog.error(DOMAIN, 'DistributedTodo', '分布式数据对象未初始化');
      return;
    }
    
    try {
      // 获取本地设备ID
      const deviceId = this.deviceManager?.getLocalDeviceNetworkId() || 'unknown';
      
      // 更新分布式数据对象,自动同步到其他设备
      this.todoDataObject['action'] = action;
      this.todoDataObject['todoId'] = todoId;
      this.todoDataObject['todoData'] = todoData || '';
      this.todoDataObject['timestamp'] = Date.now();
      this.todoDataObject['deviceId'] = deviceId;
      
      hilog.info(DOMAIN, 'DistributedTodo', 
        `发送待办数据: action=${action}, todoId=${todoId}`);
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedTodo', 
        `发送待办数据失败, errCode: ${e.code}, errMessage: ${e.message}`);
    }
  }
  
  /**
   * 释放分布式待办数据对象
   */
  private releaseDistributedTodoObject(): void {
    if (!this.todoDataObject) {
      return;
    }
    
    try {
      // 取消所有监听
      this.todoDataObject.off('change');
      this.todoDataObject.off('status');
      
      // 退出session
      this.todoDataObject.setSessionId(() => {
        hilog.info(DOMAIN, 'DistributedTodo', '退出分布式session');
      });
      
      this.todoDataObject = null;
      
      hilog.info(DOMAIN, 'DistributedTodo', '分布式待办数据对象释放成功');
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedTodo', 
        `释放分布式待办数据对象失败, errCode: ${e.code}, errMessage: ${e.message}`);
    }
  }
  
  /**
   * 初始化分布式软总线
   */
  private initDistributedSoftBus(): void {
    try {
      hilog.info(DOMAIN, 'DistributedSoftBus', '开始初始化分布式软总线');
      
      // 获取bundleName
      const bundleName = this.context.applicationInfo.name;
      
      // 创建设备管理器实例
      this.deviceManager = distributedDeviceManager.createDeviceManager(bundleName);
      
      if (this.deviceManager) {
        hilog.info(DOMAIN, 'DistributedSoftBus', '分布式设备管理器创建成功');
        
        // 注册设备状态变化监听
        this.registerDeviceStateListener();
        
        // 注册设备发现监听
        this.registerDeviceDiscoveryListener();
        
        // 开始发现周边设备
        this.startDeviceDiscovery();
      }
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedSoftBus', 
        `初始化分布式软总线失败, errCode: ${e.code}, errMessage: ${e.message}`);
    }
  }
  
  /**
   * 注册设备状态变化监听
   */
  private registerDeviceStateListener(): void {
    if (!this.deviceManager) {
      return;
    }
    
    try {
      this.deviceManager.on('deviceStateChange', (data: DeviceStateChangeData) => {
        hilog.info(DOMAIN, 'DistributedSoftBus', 
          `设备状态变化: ${JSON.stringify(data)}`);
        
        if (data.action === distributedDeviceManager.DeviceStateChange.AVAILABLE) {
          hilog.info(DOMAIN, 'DistributedSoftBus', 
            `设备上线: ${data.device.deviceName} (${data.device.deviceId})`);
        } else if (data.action === distributedDeviceManager.DeviceStateChange.UNAVAILABLE) {
          hilog.info(DOMAIN, 'DistributedSoftBus', 
            `设备下线: ${data.device.deviceName} (${data.device.deviceId})`);
        }
      });
      
      hilog.info(DOMAIN, 'DistributedSoftBus', '设备状态监听注册成功');
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedSoftBus', 
        `注册设备状态监听失败, errCode: ${e.code}, errMessage: ${e.message}`);
    }
  }
  
  /**
   * 注册设备发现监听
   */
  private registerDeviceDiscoveryListener(): void {
    if (!this.deviceManager) {
      return;
    }
    
    try {
      // 注册发现成功监听
      this.deviceManager.on('discoverSuccess', (data: DiscoverSuccessData) => {
        hilog.info(DOMAIN, 'DistributedSoftBus', 
          `发现设备: ${data.device.deviceName} (${data.device.deviceId})`);
      });
      
      // 注册发现失败监听
      this.deviceManager.on('discoverFailure', (data: DiscoverFailureData) => {
        hilog.error(DOMAIN, 'DistributedSoftBus', 
          `设备发现失败: ${JSON.stringify(data)}`);
      });
      
      hilog.info(DOMAIN, 'DistributedSoftBus', '设备发现监听注册成功');
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedSoftBus', 
        `注册设备发现监听失败, errCode: ${e.code}, errMessage: ${e.message}`);
    }
  }
  
  /**
   * 开始发现周边设备
   */
  private startDeviceDiscovery(): void {
    if (!this.deviceManager) {
      return;
    }
    
    try {
      // 发现参数配置
      const discoverParam: Record<string, number> = {
        'discoverTargetType': 1 // 发现目标类型：1表示设备
      };
      
      // 过滤选项配置
      const filterOptions: Record<string, number> = {
        'availableStatus': 0 // 0表示发现所有设备（包括离线设备）
      };
      
      // 开始发现设备（发现持续2分钟，最多发现99个设备）
      this.deviceManager.startDiscovering(discoverParam, filterOptions);
      
      hilog.info(DOMAIN, 'DistributedSoftBus', '开始发现周边设备');
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedSoftBus', 
        `开始设备发现失败, errCode: ${e.code}, errMessage: ${e.message}`);
    }
  }
  
  /**
   * 获取可用的设备列表
   */
  getAvailableDeviceList(): Array<distributedDeviceManager.DeviceBasicInfo> {
    if (!this.deviceManager) {
      return [];
    }
    
    try {
      const deviceList = this.deviceManager.getAvailableDeviceListSync();
      hilog.info(DOMAIN, 'DistributedSoftBus', 
        `获取可用设备列表成功，设备数量: ${deviceList.length}`);
      return deviceList;
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedSoftBus', 
        `获取可用设备列表失败, errCode: ${e.code}, errMessage: ${e.message}`);
      return [];
    }
  }
  
  /**
   * 获取本地设备信息
   */
  getLocalDeviceInfo(): LocalDeviceInfo | null {
    if (!this.deviceManager) {
      return null;
    }
    
    try {
      const deviceId = this.deviceManager.getLocalDeviceId();
      const deviceName = this.deviceManager.getLocalDeviceName();
      const deviceType = this.deviceManager.getLocalDeviceType();
      const networkId = this.deviceManager.getLocalDeviceNetworkId();
      
      hilog.info(DOMAIN, 'DistributedSoftBus', 
        `本地设备信息 - 名称: ${deviceName}, 类型: ${deviceType}, ID: ${deviceId}`);
      
      const deviceInfo: LocalDeviceInfo = {
        deviceId,
        deviceName,
        deviceType,
        networkId
      };
      
      return deviceInfo;
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedSoftBus', 
        `获取本地设备信息失败, errCode: ${e.code}, errMessage: ${e.message}`);
      return null;
    }
  }
  
  /**
   * 释放分布式软总线资源
   */
  private releaseDistributedSoftBus(): void {
    if (!this.deviceManager) {
      return;
    }
    
    try {
      // 停止设备发现
      this.deviceManager.stopDiscovering();
      
      // 取消所有监听
      this.deviceManager.off('deviceStateChange');
      this.deviceManager.off('discoverSuccess');
      this.deviceManager.off('discoverFailure');
      
      // 释放设备管理器实例
      distributedDeviceManager.releaseDeviceManager(this.deviceManager);
      this.deviceManager = null;
      
      hilog.info(DOMAIN, 'DistributedSoftBus', '分布式软总线资源释放成功');
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, 'DistributedSoftBus', 
        `释放分布式软总线资源失败, errCode: ${e.code}, errMessage: ${e.message}`);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 一多适配
    WindowUtil.registerBreakPoint(windowStage);

    windowStage.loadContent('pages/MainEntry', (err: BusinessError) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });

    // 获取当前布局遮挡区域
    const windowClass: window.Window = windowStage.getMainWindowSync();
    const isLayoutFullScreen = true;
    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      hilog.info(DOMAIN, 'WindowStage', 'Succeeded in setting the window layout to full-screen mode.');
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, 'WindowStage', 'Failed to set the window layout to full-screen mode. Cause: %{public}s',
        JSON.stringify(err));
    });

    // 导航条与状态栏避让
    const topAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    const topRectHeight = topAvoidArea.topRect.height; // 获取状态栏区域高度
    const bottomAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    const bottomRectHeight = bottomAvoidArea.bottomRect.height; // 获取到导航条区域的高度
    AppStorageV2.connect(AvoidArea, () => new AvoidArea(topRectHeight, bottomRectHeight));

    // 注册监听函数，动态获取避让区域数据
    windowClass.on('avoidAreaChange', (data: AvoidAreaChangeData) => {
      const avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        avoidArea.topRectHeight = data.area.topRect.height;
      } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        avoidArea.bottomRectHeight = data.area.bottomRect.height;
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    
    // 应用进入后台时立即保存数据
    TodoPersistenceWrapper.save();
  }

  /**
   * 夜间模式
   * @param newConfig - 新的配置信息
   */
  onConfigurationUpdate(newConfig: Configuration): void {
    if (this.themeController.currentColorMode !== newConfig.colorMode &&
    this.themeController.isFollowSystemSetting) {
      this.themeController.currentColorMode = newConfig.colorMode;
    }
  }

  onNewWant(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    this.dataManager.updateAtomicCard();
  }
}