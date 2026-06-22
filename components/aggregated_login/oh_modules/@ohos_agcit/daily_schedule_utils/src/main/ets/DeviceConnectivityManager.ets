/**
 * 设备互联能力管理工具类
 * 提供设备发现、绑定、查询和监听等分布式设备管理能力
 */
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { BusinessError } from '@ohos.base';
import Logger from './Logger';

const TAG = 'DeviceConnectivityManager';

/**
 * 设备信息
 */
export interface DeviceInfo {
  deviceId: string;      // 设备标识
  deviceName: string;    // 设备名称
  deviceType: string;    // 设备类型
  networkId?: string;    // 网络标识
}

/**
 * 设备状态变化类型
 */
export enum DeviceStateChange {
  UNKNOWN = 0,      // 未知状态
  AVAILABLE = 1,    // 设备可用
  UNAVAILABLE = 2   // 设备不可用
}

/**
 * 发现成功回调数据
 */
interface DiscoverSuccessData {
  device: distributedDeviceManager.DeviceBasicInfo;
}

/**
 * 发现失败回调数据
 */
interface DiscoverFailureData {
  reason: number;
}

/**
 * 绑定设备回调数据
 */
interface BindTargetData {
  deviceId: string;
}

/**
 * 设备状态变化回调数据
 */
interface DeviceStateChangeData {
  action: distributedDeviceManager.DeviceStateChange;
  device: distributedDeviceManager.DeviceBasicInfo;
}

/**
 * 设备互联能力管理器
 */
export class DeviceConnectivityManager {
  private static instance: DeviceConnectivityManager;
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  static getInstance(): DeviceConnectivityManager {
    if (!DeviceConnectivityManager.instance) {
      DeviceConnectivityManager.instance = new DeviceConnectivityManager();
    }
    return DeviceConnectivityManager.instance;
  }
  
  /**
   * 初始化设备管理器
   * @param bundleName 应用包名
   */
  async initDeviceManager(bundleName: string): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        this.deviceManager = distributedDeviceManager.createDeviceManager(bundleName);
        Logger.info(TAG, '设备管理器初始化成功');
        resolve();
      } catch (error) {
        const err = error as BusinessError;
        Logger.error(TAG, `设备管理器初始化失败: ${err.code}, ${err.message}`);
        reject(error);
      }
    });
  }
  
  /**
   * 释放设备管理器
   */
  releaseDeviceManager(): void {
    if (this.deviceManager) {
      try {
        distributedDeviceManager.releaseDeviceManager(this.deviceManager);
        this.deviceManager = null;
        Logger.info(TAG, '设备管理器释放成功');
      } catch (error) {
        Logger.error(TAG, `设备管理器释放失败: ${JSON.stringify(error)}`);
      }
    }
  }
  
  /**
   * 开始发现设备
   * @param onDeviceFound 发现设备回调
   * @param onDiscoverFail 发现失败回调
   */
  startDeviceDiscovery(
    onDeviceFound?: (device: DeviceInfo) => void,
    onDiscoverFail?: (reason: number) => void
  ): void {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return;
    }
    
    try {
      // 注册发现成功回调
      this.deviceManager.on('discoverSuccess', (data: DiscoverSuccessData) => {
        Logger.info(TAG, `发现设备: ${data.device.deviceName}`);
        const deviceInfo: DeviceInfo = {
          deviceId: data.device.deviceId,
          deviceName: data.device.deviceName,
          deviceType: data.device.deviceType,
          networkId: data.device.networkId
        };
        onDeviceFound?.(deviceInfo);
      });
      
      // 注册发现失败回调
      this.deviceManager.on('discoverFailure', (data: DiscoverFailureData) => {
        Logger.error(TAG, `发现设备失败: ${data.reason}`);
        onDiscoverFail?.(data.reason);
      });
      
      // 开始发现设备
      const discoverParam: Record<string, number> = {
        'discoverTargetType': 1  // 发现目标为设备
      };
      
      const filterOptions: Record<string, number> = {
        'availableStatus': 0  // 发现设备可信
      };
      
      this.deviceManager.startDiscovering(discoverParam, filterOptions);
      Logger.info(TAG, '开始发现设备');
    } catch (error) {
      Logger.error(TAG, `开始发现设备异常: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 停止发现设备
   */
  stopDeviceDiscovery(): void {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return;
    }
    
    try {
      this.deviceManager.stopDiscovering();
      this.deviceManager.off('discoverSuccess');
      this.deviceManager.off('discoverFailure');
      Logger.info(TAG, '停止发现设备成功');
    } catch (error) {
      Logger.error(TAG, `停止发现设备异常: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 绑定设备
   * @param deviceId 设备ID
   * @param onBindSuccess 绑定成功回调
   */
  bindDevice(deviceId: string, onBindSuccess?: (deviceId: string) => void): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.deviceManager) {
        Logger.error(TAG, '设备管理器未初始化');
        reject(new Error('设备管理器未初始化'));
        return;
      }
      
      const bindParam: Record<string, string | number> = {
        'bindType': 1,  // PIN码认证
        'targetPkgName': 'com.example.app',
        'appName': 'CalendarApp',
        'appOperation': '设备协同',
        'customDescription': '用于跨设备任务流转'
      };
      
      try {
        this.deviceManager.bindTarget(deviceId, bindParam, (error: BusinessError, data: BindTargetData) => {
          if (error) {
            Logger.error(TAG, `绑定设备失败: ${JSON.stringify(error)}`);
            reject(error);
            return;
          }
          Logger.info(TAG, `绑定设备成功: ${data.deviceId}`);
          onBindSuccess?.(data.deviceId);
          resolve();
        });
      } catch (error) {
        Logger.error(TAG, `绑定设备异常: ${JSON.stringify(error)}`);
        reject(error);
      }
    });
  }
  
  /**
   * 解绑设备
   * @param deviceId 设备ID
   */
  unbindDevice(deviceId: string): void {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return;
    }
    
    try {
      this.deviceManager.unbindTarget(deviceId);
      Logger.info(TAG, `解绑设备成功: ${deviceId}`);
    } catch (error) {
      Logger.error(TAG, `解绑设备异常: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 获取可用设备列表
   */
  getAvailableDeviceList(): DeviceInfo[] {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return [];
    }
    
    try {
      const deviceList = this.deviceManager.getAvailableDeviceListSync();
      Logger.info(TAG, `获取可用设备列表成功，数量: ${deviceList.length}`);
      
      return deviceList.map((device: distributedDeviceManager.DeviceBasicInfo): DeviceInfo => {
        return {
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          deviceType: device.deviceType,
          networkId: device.networkId
        };
      });
    } catch (error) {
      Logger.error(TAG, `获取可用设备列表异常: ${JSON.stringify(error)}`);
      return [];
    }
  }
  
  /**
   * 注册设备状态变化监听
   * @param onDeviceOnline 设备上线回调
   * @param onDeviceOffline 设备下线回调
   */
  registerDeviceStateListener(
    onDeviceOnline?: (device: DeviceInfo) => void,
    onDeviceOffline?: (device: DeviceInfo) => void
  ): void {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return;
    }
    
    try {
      this.deviceManager.on('deviceStateChange', (data: DeviceStateChangeData) => {
        const deviceInfo: DeviceInfo = {
          deviceId: data.device.deviceId,
          deviceName: data.device.deviceName,
          deviceType: data.device.deviceType,
          networkId: data.device.networkId
        };
        
        switch (data.action) {
          case distributedDeviceManager.DeviceStateChange.AVAILABLE:
            Logger.info(TAG, `设备上线: ${deviceInfo.deviceName}`);
            onDeviceOnline?.(deviceInfo);
            break;
          case distributedDeviceManager.DeviceStateChange.UNAVAILABLE:
            Logger.info(TAG, `设备下线: ${deviceInfo.deviceName}`);
            onDeviceOffline?.(deviceInfo);
            break;
          default:
            break;
        }
      });
      Logger.info(TAG, '注册设备状态监听成功');
    } catch (error) {
      Logger.error(TAG, `注册设备状态监听异常: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 取消设备状态监听
   */
  unregisterDeviceStateListener(): void {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return;
    }
    
    try {
      this.deviceManager.off('deviceStateChange');
      Logger.info(TAG, '取消设备状态监听成功');
    } catch (error) {
      Logger.error(TAG, `取消设备状态监听异常: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 获取本地设备网络ID
   */
  getLocalDeviceNetworkId(): string {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return '';
    }
    
    try {
      const networkId = this.deviceManager.getLocalDeviceNetworkId();
      Logger.info(TAG, `本地设备网络ID: ${networkId}`);
      return networkId;
    } catch (error) {
      Logger.error(TAG, `获取本地设备网络ID异常: ${JSON.stringify(error)}`);
      return '';
    }
  }
  
  /**
   * 获取本地设备名称
   */
  getLocalDeviceName(): string {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return '';
    }
    
    try {
      const deviceName = this.deviceManager.getLocalDeviceName();
      Logger.info(TAG, `本地设备名称: ${deviceName}`);
      return deviceName;
    } catch (error) {
      Logger.error(TAG, `获取本地设备名称异常: ${JSON.stringify(error)}`);
      return '';
    }
  }
  
  /**
   * 获取本地设备类型
   */
  getLocalDeviceType(): number {
    if (!this.deviceManager) {
      Logger.error(TAG, '设备管理器未初始化');
      return 0;
    }
    
    try {
      const deviceType = this.deviceManager.getLocalDeviceType();
      Logger.info(TAG, `本地设备类型: ${deviceType}`);
      return deviceType;
    } catch (error) {
      Logger.error(TAG, `获取本地设备类型异常: ${JSON.stringify(error)}`);
      return 0;
    }
  }
}

export default DeviceConnectivityManager;
