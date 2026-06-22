/**
 * 流转状态管理工具类
 * 封装在线设备查询、发起页面流转、流转回调监听、页面状态缓存逻辑
 */
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import preferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import Logger from './Logger';

const TAG = 'FlowTransferUtil';
const PREFERENCES_NAME = 'flow_transfer_cache';

/**
 * 设备信息
 */
export interface FlowDeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  networkId: string;
  isOnline: boolean;
}

/**
 * 流转状态类型
 */
export enum FlowState {
  IDLE = 0,           // 空闲
  PREPARING = 1,      // 准备中
  TRANSFERRING = 2,   // 流转中
  COMPLETED = 3,      // 已完成
  FAILED = 4,         // 失败
  ACTIVE = 5,         // 激活状态
  INACTIVE = 6        // 未激活状态
}

/**
 * 流转类型
 */
export enum FlowType {
  DATE_TRANSFER = 'date_transfer',           // 日期流转
  TODO_LIST_TRANSFER = 'todo_list_transfer', // 待办列表流转
  CALENDAR_TRANSFER = 'calendar_transfer',   // 黄历数据流转
  FULL_PAGE_TRANSFER = 'full_page_transfer' // 完整页面流转
}

/**
 * 选中日期信息
 */
export interface SelectedDateInfo {
  year: number;
  month: number;
  day: number;
  timestamp: number;
}

/**
 * 待办列表滚动位置信息
 */
export interface TodoListScrollInfo {
  scrollOffset: number;
  scrollIndex: number;
  scrollTop: number;
}

/**
 * 黄历展示数据
 */
export interface CalendarDisplayData {
  dateStr: string;
  lunarDate: string;
  solarTerm: string;
  festival: string;
  suit: string[];
  avoid: string[];
  extraInfo: Record<string, string>;
}

/**
 * 页面状态缓存数据
 */
export interface PageStateCache {
  selectedDate?: SelectedDateInfo;
  todoListScroll?: TodoListScrollInfo;
  calendarData?: CalendarDisplayData;
  customData?: Record<string, Object>;
  cacheTime: number;
  sourceDeviceId: string;
}

/**
 * 流转回调接口
 */
export interface FlowTransferCallback {
  onDeviceStateChanged?: (device: FlowDeviceInfo, isOnline: boolean) => void;
  onFlowStateChanged?: (state: FlowState, flowType: FlowType) => void;
  onFlowProgress?: (progress: number, message: string) => void;
  onFlowSuccess?: (targetDevice: FlowDeviceInfo, flowType: FlowType) => void;
  onFlowFailed?: (errorCode: number, errorMsg: string) => void;
  onReceiveFlowData?: (sourceDevice: FlowDeviceInfo, cacheData: PageStateCache) => void;
}

/**
 * 设备状态变化数据
 */
interface DeviceStateChangeData {
  action: distributedDeviceManager.DeviceStateChange;
  device: distributedDeviceManager.DeviceBasicInfo;
}

/**
 * 流转状态变化数据
 */
interface ContinueStateChangeData {
  state: number;
  info: Record<string, Object>;
}

/**
 * 流转状态管理工具类
 */
export class FlowTransferUtil {
  private static instance: FlowTransferUtil;
  
  private context: common.UIAbilityContext | null = null;
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private preferencesStore: preferences.Preferences | null = null;
  private callback: FlowTransferCallback | null = null;
  
  private onlineDevices: Map<string, FlowDeviceInfo> = new Map();
  private currentFlowState: FlowState = FlowState.IDLE;
  private currentFlowType: FlowType | null = null;
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  static getInstance(): FlowTransferUtil {
    if (!FlowTransferUtil.instance) {
      FlowTransferUtil.instance = new FlowTransferUtil();
    }
    return FlowTransferUtil.instance;
  }
  
  /**
   * 初始化流转管理器
   */
  async initialize(context: common.UIAbilityContext, bundleName: string): Promise<void> {
    try {
      this.context = context;
      
      // 1. 初始化设备管理器
      this.deviceManager = distributedDeviceManager.createDeviceManager(bundleName);
      Logger.info(TAG, '设备管理器初始化成功');
      
      // 2. 初始化首选项存储
      await this.initPreferences();
      
      // 3. 注册设备状态监听
      this.registerDeviceStateListener();
      
      Logger.info(TAG, '流转管理器初始化完成');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `初始化失败: ${err.message}`);
      throw new Error(`初始化失败: ${err.message}`);
    }
  }
  
  /**
   * 初始化首选项存储
   */
  private async initPreferences(): Promise<void> {
    if (!this.context) {
      throw new Error('上下文未初始化');
    }
    
    try {
      this.preferencesStore = await preferences.getPreferences(this.context, PREFERENCES_NAME);
      Logger.info(TAG, '首选项存储初始化成功');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `首选项存储初始化失败: ${err.message}`);
      throw new Error(`首选项存储初始化失败: ${err.message}`);
    }
  }
  
  /**
   * 注册设备状态监听
   */
  private registerDeviceStateListener(): void {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return;
    }
    
    try {
      this.deviceManager.on('deviceStateChange', (data: DeviceStateChangeData) => {
        const deviceInfo: FlowDeviceInfo = {
          deviceId: data.device.deviceId,
          deviceName: data.device.deviceName,
          deviceType: data.device.deviceType,
          networkId: data.device.networkId ?? '',
          isOnline: data.action === distributedDeviceManager.DeviceStateChange.AVAILABLE
        };
        
        if (data.action === distributedDeviceManager.DeviceStateChange.AVAILABLE) {
          this.onlineDevices.set(deviceInfo.deviceId, deviceInfo);
          Logger.info(TAG, `设备上线: ${deviceInfo.deviceName}`);
          if (this.callback?.onDeviceStateChanged) {
            this.callback.onDeviceStateChanged(deviceInfo, true);
          }
        } else if (data.action === distributedDeviceManager.DeviceStateChange.UNAVAILABLE) {
          this.onlineDevices.delete(deviceInfo.deviceId);
          Logger.info(TAG, `设备下线: ${deviceInfo.deviceName}`);
          if (this.callback?.onDeviceStateChanged) {
            this.callback.onDeviceStateChanged(deviceInfo, false);
          }
        }
      });
      
      Logger.info(TAG, '设备状态监听注册成功');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `设备状态监听注册失败: ${err.message}`);
    }
  }
  
  /**
   * 设置流转回调
   */
  setCallback(callback: FlowTransferCallback): void {
    this.callback = callback;
    Logger.info(TAG, '流转回调设置成功');
  }
  
  /**
   * 查询在线设备列表
   */
  queryOnlineDevices(): FlowDeviceInfo[] {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return [];
    }
    
    try {
      const deviceList = this.deviceManager.getAvailableDeviceListSync();
      
      deviceList.forEach(device => {
        const deviceInfo: FlowDeviceInfo = {
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          deviceType: device.deviceType,
          networkId: device.networkId ?? '',
          isOnline: true
        };
        this.onlineDevices.set(deviceInfo.deviceId, deviceInfo);
      });
      
      Logger.info(TAG, `查询到 ${deviceList.length} 个在线设备`);
      return Array.from(this.onlineDevices.values());
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `查询在线设备失败: ${err.message}`);
      return [];
    }
  }
  
  /**
   * 获取指定设备信息
   */
  getDeviceInfo(deviceId: string): FlowDeviceInfo | null {
    return this.onlineDevices.get(deviceId) ?? null;
  }
  
  /**
   * 缓存页面状态
   */
  async cachePageState(pageState: PageStateCache): Promise<void> {
    if (!this.preferencesStore) {
      Logger.error(TAG, '首选项存储未初始化');
      return;
    }
    
    try {
      const cacheKey = `page_state_${pageState.sourceDeviceId}`;
      const cacheValue = JSON.stringify(pageState);
      
      await this.preferencesStore.put(cacheKey, cacheValue);
      await this.preferencesStore.flush();
      
      Logger.info(TAG, `页面状态缓存成功: ${cacheKey}`);
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `页面状态缓存失败: ${err.message}`);
    }
  }
  
  /**
   * 获取缓存的页面状态
   */
  async getCachedPageState(sourceDeviceId: string): Promise<PageStateCache | null> {
    if (!this.preferencesStore) {
      Logger.error(TAG, '首选项存储未初始化');
      return null;
    }
    
    try {
      const cacheKey = `page_state_${sourceDeviceId}`;
      const cacheValue = await this.preferencesStore.get(cacheKey, '');
      
      if (cacheValue && typeof cacheValue === 'string') {
        const pageState = JSON.parse(cacheValue) as PageStateCache;
        Logger.info(TAG, `获取缓存成功: ${cacheKey}`);
        return pageState;
      }
      
      return null;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `获取缓存失败: ${err.message}`);
      return null;
    }
  }
  
  /**
   * 缓存选中日期
   */
  async cacheSelectedDate(year: number, month: number, day: number): Promise<void> {
    const localDeviceId = this.getLocalDeviceId();
    
    const selectedDate: SelectedDateInfo = {
      year: year,
      month: month,
      day: day,
      timestamp: Date.now()
    };
    
    const pageState: PageStateCache = {
      selectedDate: selectedDate,
      cacheTime: Date.now(),
      sourceDeviceId: localDeviceId
    };
    
    await this.cachePageState(pageState);
    Logger.info(TAG, `日期缓存成功: ${year}-${month}-${day}`);
  }
  
  /**
   * 缓存待办列表滚动位置
   */
  async cacheTodoListScrollPosition(scrollOffset: number, scrollIndex: number, scrollTop: number): Promise<void> {
    const localDeviceId = this.getLocalDeviceId();
    
    const todoListScroll: TodoListScrollInfo = {
      scrollOffset: scrollOffset,
      scrollIndex: scrollIndex,
      scrollTop: scrollTop
    };
    
    const pageState: PageStateCache = {
      todoListScroll: todoListScroll,
      cacheTime: Date.now(),
      sourceDeviceId: localDeviceId
    };
    
    await this.cachePageState(pageState);
    Logger.info(TAG, '待办列表滚动位置缓存成功');
  }
  
  /**
   * 缓存黄历展示数据
   */
  async cacheCalendarData(calendarData: CalendarDisplayData): Promise<void> {
    const localDeviceId = this.getLocalDeviceId();
    
    const pageState: PageStateCache = {
      calendarData: calendarData,
      cacheTime: Date.now(),
      sourceDeviceId: localDeviceId
    };
    
    await this.cachePageState(pageState);
    Logger.info(TAG, '黄历数据缓存成功');
  }
  
  /**
   * 获取本地设备ID
   */
  private getLocalDeviceId(): string {
    if (!this.deviceManager) {
      return '';
    }
    
    try {
      return this.deviceManager.getLocalDeviceNetworkId();
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `获取本地设备ID失败: ${err.message}`);
      return '';
    }
  }
  
  /**
   * 清除缓存
   */
  async clearCache(sourceDeviceId?: string): Promise<void> {
    if (!this.preferencesStore) {
      Logger.error(TAG, '首选项存储未初始化');
      return;
    }
    
    try {
      if (sourceDeviceId) {
        const cacheKey = `page_state_${sourceDeviceId}`;
        await this.preferencesStore.delete(cacheKey);
      } else {
        await this.preferencesStore.clear();
      }
      
      await this.preferencesStore.flush();
      Logger.info(TAG, '缓存清除成功');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `缓存清除失败: ${err.message}`);
    }
  }
  
  /**
   * 获取当前流转状态
   */
  getCurrentFlowState(): FlowState {
    return this.currentFlowState;
  }
  
  /**
   * 是否正在流转
   */
  isFlowing(): boolean {
    return this.currentFlowState === FlowState.TRANSFERRING;
  }
  
  /**
   * 释放资源
   */
  release(): void {
    try {
      if (this.deviceManager) {
        this.deviceManager.off('deviceStateChange');
        distributedDeviceManager.releaseDeviceManager(this.deviceManager);
        this.deviceManager = null;
      }
      
      this.onlineDevices.clear();
      this.callback = null;
      this.context = null;
      this.preferencesStore = null;
      
      Logger.info(TAG, '流转管理器资源释放完成');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `资源释放失败: ${err.message}`);
    }
  }
}

export default FlowTransferUtil;
