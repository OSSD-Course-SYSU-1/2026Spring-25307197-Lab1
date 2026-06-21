import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const LOG_DOMAIN = 0xFF00;
const LOG_TAG = 'DeviceManagerUtil';

export enum DeviceState {
  ONLINE = 1,
  OFFLINE = 2,
  CHANGE = 3
}

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  networkId?: string;
  state?: DeviceState;
}

export interface DeviceDiscoveryCallback {
  onDeviceFound?: (device: DeviceInfo) => void;
  onDiscoverFailed?: (errorCode: number) => void;
}

export interface DeviceStateCallback {
  onDeviceStateChanged?: (device: DeviceInfo, state: DeviceState) => void;
}

/**
 * 设备在线/离线回调接口
 * 提供更明确的在线、离线事件回调
 */
export interface DeviceOnlineOfflineCallback {
  /** 设备上线回调 */
  onDeviceOnline?: (device: DeviceInfo) => void;
  /** 设备离线回调 */
  onDeviceOffline?: (device: DeviceInfo) => void;
}

export interface DeviceAuthCallback {
  onAuthSuccess?: (deviceId: string) => void;
  onAuthFailed?: (errorCode: number, errorMsg: string) => void;
}

export interface DeviceAuthParam {
  bindType: number;
  targetPkgName?: string;
  appName?: string;
  appOperation?: string;
  customDescription?: string;
}

export interface DiscoveryFilterOptions {
  availableStatus?: number;
  discoverDistance?: number;
  authenticationStatus?: number;
  authorizationType?: number;
}

// ===== 用显式 class 避免 arkts-no-untyped-obj-literals =====
// 注意字段使用 Number（包装类型）确保是 Object
class DiscoverParam {
  discoverTargetType: Number = new Number(1);
}

class BindParam {
  bindType: Number = new Number(1);
}
// =======================================================

// ========== 官方事件回调入参结构 ==========
interface DiscoverSuccessCallbackData {
  device: distributedDeviceManager.DeviceBasicInfo;
}

interface DiscoverFailureCallbackData {
  reason: number;
}

interface DeviceStateChangeCallbackData {
  action: distributedDeviceManager.DeviceStateChange;
  device: distributedDeviceManager.DeviceBasicInfo;
}

interface BindTargetCallbackData {
  deviceId: string;
}
// ========================================================

export class DeviceManagerUtil {
  private static instance: DeviceManagerUtil | null = null;

  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private isDiscovering: boolean = false;

  private discoveryCallback: DeviceDiscoveryCallback | null = null;
  private stateCallback: DeviceStateCallback | null = null;
  private onlineOfflineCallback: DeviceOnlineOfflineCallback | null = null;

  private discoverSuccessHandler?: (data: DiscoverSuccessCallbackData) => void;
  private discoverFailureHandler?: (data: DiscoverFailureCallbackData) => void;
  private deviceStateChangeHandler?: (data: DeviceStateChangeCallbackData) => void;

  private constructor() {}

  public static getInstance(): DeviceManagerUtil {
    if (!DeviceManagerUtil.instance) {
      DeviceManagerUtil.instance = new DeviceManagerUtil();
    }
    return DeviceManagerUtil.instance;
  }

  public async init(bundleName: string): Promise<boolean> {
    if (this.deviceManager) {
      hilog.info(LOG_DOMAIN, LOG_TAG, 'DeviceManager already initialized');
      return true;
    }
    try {
      this.deviceManager = distributedDeviceManager.createDeviceManager(bundleName);
      hilog.info(LOG_DOMAIN, LOG_TAG, 'DeviceManager initialized successfully');
      return true;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to init DeviceManager: ${e.code}, ${e.message}`);
      return false;
    }
  }

  public release(): void {
    if (!this.deviceManager) return;

    try {
      if (this.isDiscovering) {
        this.stopDiscovering();
      }
      this.unregisterAllListeners();
      distributedDeviceManager.releaseDeviceManager(this.deviceManager);
      this.deviceManager = null;
      hilog.info(LOG_DOMAIN, LOG_TAG, 'DeviceManager released');
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to release DeviceManager: ${e.code}, ${e.message}`);
    }
  }

  /**
   * 开始扫描周边设备
   * 为避免 ArkTS 在 filterOptions 上触发索引签名/undefined 相关规则，这里暂不把 filterOptions 传给系统 API。
   */
  public startDiscovering(callback: DeviceDiscoveryCallback, _filterOptions?: DiscoveryFilterOptions): boolean {
    if (!this.deviceManager) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'DeviceManager not initialized');
      return false;
    }
    if (this.isDiscovering) {
      hilog.warn(LOG_DOMAIN, LOG_TAG, 'Already discovering');
      return true;
    }

    this.discoveryCallback = callback;

    try {
      this.discoverSuccessHandler = (data: DiscoverSuccessCallbackData) => {
        const info = data.device;
        const device: DeviceInfo = {
          deviceId: info.deviceId,
          deviceName: info.deviceName,
          deviceType: info.deviceType,
          networkId: info.networkId
        };
        hilog.info(LOG_DOMAIN, LOG_TAG, `Device found: ${device.deviceName}`);
        this.discoveryCallback?.onDeviceFound?.(device);
      };

      this.discoverFailureHandler = (data: DiscoverFailureCallbackData) => {
        hilog.error(LOG_DOMAIN, LOG_TAG, `Discover failed: ${data.reason}`);
        this.discoveryCallback?.onDiscoverFailed?.(data.reason);
      };

      this.deviceManager.on('discoverSuccess', this.discoverSuccessHandler);
      this.deviceManager.on('discoverFailure', this.discoverFailureHandler);

      const discoverParam: DiscoverParam = new DiscoverParam();

      // 关键修复：通过 Object 做“双重断言”，避免 ArkTSCheck “不重叠类型断言”报错
      this.deviceManager.startDiscovering(discoverParam as Object as Record<string, Object>);

      this.isDiscovering = true;
      hilog.info(LOG_DOMAIN, LOG_TAG, 'Started discovering devices');
      return true;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to start discovering: ${e.code}, ${e.message}`);
      return false;
    }
  }

  public stopDiscovering(): void {
    if (!this.deviceManager || !this.isDiscovering) return;

    try {
      this.deviceManager.stopDiscovering();

      if (this.discoverSuccessHandler) this.deviceManager.off('discoverSuccess', this.discoverSuccessHandler);
      else this.deviceManager.off('discoverSuccess');

      if (this.discoverFailureHandler) this.deviceManager.off('discoverFailure', this.discoverFailureHandler);
      else this.deviceManager.off('discoverFailure');

      this.discoverSuccessHandler = undefined;
      this.discoverFailureHandler = undefined;

      this.isDiscovering = false;
      this.discoveryCallback = null;

      hilog.info(LOG_DOMAIN, LOG_TAG, 'Stopped discovering');
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to stop discovering: ${e.code}, ${e.message}`);
    }
  }

  public getAvailableDeviceListSync(): DeviceInfo[] {
    if (!this.deviceManager) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'DeviceManager not initialized');
      return [];
    }

    try {
      const list = this.deviceManager.getAvailableDeviceListSync();
      return list.map((d) => {
        const info: DeviceInfo = {
          deviceId: d.deviceId,
          deviceName: d.deviceName,
          deviceType: d.deviceType,
          networkId: d.networkId
        };
        return info;
      });
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to get device list: ${e.code}, ${e.message}`);
      return [];
    }
  }

  public async getAvailableDeviceList(): Promise<DeviceInfo[]> {
    if (!this.deviceManager) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'DeviceManager not initialized');
      return [];
    }

    try {
      const list = await this.deviceManager.getAvailableDeviceList();
      return list.map((d) => {
        const info: DeviceInfo = {
          deviceId: d.deviceId,
          deviceName: d.deviceName,
          deviceType: d.deviceType,
          networkId: d.networkId
        };
        return info;
      });
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to get device list: ${e.code}, ${e.message}`);
      return [];
    }
  }

  public registerDeviceStateListener(callback: DeviceStateCallback): void {
    if (!this.deviceManager) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'DeviceManager not initialized');
      return;
    }

    this.stateCallback = callback;

    this.deviceStateChangeHandler = (data: DeviceStateChangeCallbackData) => {
      const mapped: DeviceState = this.mapDeviceStateChange(data.action);
      const device: DeviceInfo = {
        deviceId: data.device.deviceId,
        deviceName: data.device.deviceName,
        deviceType: data.device.deviceType,
        networkId: data.device.networkId,
        state: mapped
      };
      this.stateCallback?.onDeviceStateChanged?.(device, mapped);
    };

    this.deviceManager.on('deviceStateChange', this.deviceStateChangeHandler);
    hilog.info(LOG_DOMAIN, LOG_TAG, 'Device state listener registered');
  }

  public unregisterDeviceStateListener(): void {
    if (!this.deviceManager) return;

    try {
      if (this.deviceStateChangeHandler) this.deviceManager.off('deviceStateChange', this.deviceStateChangeHandler);
      else this.deviceManager.off('deviceStateChange');

      this.deviceStateChangeHandler = undefined;
      this.stateCallback = null;

      hilog.info(LOG_DOMAIN, LOG_TAG, 'Device state listener unregistered');
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to unregister state listener: ${e.code}, ${e.message}`);
    }
  }

  /**
   * 注册设备在线/离线监听
   * 提供更明确的在线、离线事件回调
   */
  public registerDeviceOnlineOfflineListener(callback: DeviceOnlineOfflineCallback): void {
    if (!this.deviceManager) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'DeviceManager not initialized');
      return;
    }

    this.onlineOfflineCallback = callback;

    this.deviceStateChangeHandler = (data: DeviceStateChangeCallbackData) => {
      const device: DeviceInfo = {
        deviceId: data.device.deviceId,
        deviceName: data.device.deviceName,
        deviceType: data.device.deviceType,
        networkId: data.device.networkId
      };

      // 根据系统状态触发对应的回调
      if (data.action === distributedDeviceManager.DeviceStateChange.AVAILABLE) {
        // 设备上线（可用）
        hilog.info(LOG_DOMAIN, LOG_TAG, `Device online: ${device.deviceName}`);
        this.onlineOfflineCallback?.onDeviceOnline?.(device);
      } else if (data.action === distributedDeviceManager.DeviceStateChange.UNAVAILABLE) {
        // 设备离线（不可用）
        hilog.info(LOG_DOMAIN, LOG_TAG, `Device offline: ${device.deviceName}`);
        this.onlineOfflineCallback?.onDeviceOffline?.(device);
      } else {
        // UNKNOWN状态，记录日志但不触发回调
        hilog.info(LOG_DOMAIN, LOG_TAG, `Device state unknown: ${device.deviceName}, action: ${data.action}`);
      }
    };

    this.deviceManager.on('deviceStateChange', this.deviceStateChangeHandler);
    hilog.info(LOG_DOMAIN, LOG_TAG, 'Device online/offline listener registered');
  }

  /**
   * 注销设备在线/离线监听
   */
  public unregisterDeviceOnlineOfflineListener(): void {
    if (!this.deviceManager) return;

    try {
      if (this.deviceStateChangeHandler) this.deviceManager.off('deviceStateChange', this.deviceStateChangeHandler);
      else this.deviceManager.off('deviceStateChange');

      this.deviceStateChangeHandler = undefined;
      this.onlineOfflineCallback = null;

      hilog.info(LOG_DOMAIN, LOG_TAG, 'Device online/offline listener unregistered');
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to unregister online/offline listener: ${e.code}, ${e.message}`);
    }
  }

  private mapDeviceStateChange(action: distributedDeviceManager.DeviceStateChange): DeviceState {
    switch (action) {
      case distributedDeviceManager.DeviceStateChange.AVAILABLE:
        return DeviceState.ONLINE;
      case distributedDeviceManager.DeviceStateChange.UNAVAILABLE:
        return DeviceState.OFFLINE;
      default:
        return DeviceState.CHANGE;
    }
  }

  public authenticateDevice(deviceId: string, authParam: DeviceAuthParam, callback: DeviceAuthCallback): boolean {
    if (!this.deviceManager) return false;

    try {
      const bindParam: BindParam = new BindParam();
      bindParam.bindType = new Number(authParam.bindType);

      this.deviceManager.bindTarget(
        deviceId,
        // 关键修复：同样通过 Object 做“双重断言”
        bindParam as Object as Record<string, Object>,
        (err?: BusinessError, data?: BindTargetCallbackData) => {
          if (err) {
            hilog.error(LOG_DOMAIN, LOG_TAG, `Auth failed: ${err.code}, ${err.message}`);
            callback.onAuthFailed?.(err.code, err.message);
            return;
          }
          const boundId: string = data?.deviceId ? data.deviceId : deviceId;
          hilog.info(LOG_DOMAIN, LOG_TAG, `Auth success: ${boundId}`);
          callback.onAuthSuccess?.(boundId);
        }
      );

      return true;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to authenticate device: ${e.code}, ${e.message}`);
      return false;
    }
  }

  public unauthenticateDevice(deviceId: string): boolean {
    if (!this.deviceManager) return false;

    try {
      this.deviceManager.unbindTarget(deviceId);
      return true;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to unauthenticate device: ${e.code}, ${e.message}`);
      return false;
    }
  }

  public getLocalDeviceId(): string {
    if (!this.deviceManager) return '';
    try {
      return this.deviceManager.getLocalDeviceId();
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to get local device id: ${e.code}, ${e.message}`);
      return '';
    }
  }

  public getLocalDeviceName(): string {
    if (!this.deviceManager) return '';
    try {
      return this.deviceManager.getLocalDeviceName();
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to get local device name: ${e.code}, ${e.message}`);
      return '';
    }
  }

  public getLocalDeviceType(): number {
    if (!this.deviceManager) return 0;
    try {
      return this.deviceManager.getLocalDeviceType();
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to get local device type: ${e.code}, ${e.message}`);
      return 0;
    }
  }

  public getLocalDeviceNetworkId(): string {
    if (!this.deviceManager) return '';
    try {
      return this.deviceManager.getLocalDeviceNetworkId();
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to get local device network id: ${e.code}, ${e.message}`);
      return '';
    }
  }

  private unregisterAllListeners(): void {
    if (!this.deviceManager) return;

    try {
      if (this.discoverSuccessHandler) this.deviceManager.off('discoverSuccess', this.discoverSuccessHandler);
      else this.deviceManager.off('discoverSuccess');

      if (this.discoverFailureHandler) this.deviceManager.off('discoverFailure', this.discoverFailureHandler);
      else this.deviceManager.off('discoverFailure');

      if (this.deviceStateChangeHandler) this.deviceManager.off('deviceStateChange', this.deviceStateChangeHandler);
      else this.deviceManager.off('deviceStateChange');

      this.discoverSuccessHandler = undefined;
      this.discoverFailureHandler = undefined;
      this.deviceStateChangeHandler = undefined;
      
      // 清空所有回调
      this.stateCallback = null;
      this.onlineOfflineCallback = null;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to unregister all listeners: ${e.code}, ${e.message}`);
    }
  }
}

export const deviceManagerUtil = DeviceManagerUtil.getInstance();