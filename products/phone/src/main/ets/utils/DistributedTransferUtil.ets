/**
 * 分布式任务流转工具类
 * 封装设备发现、状态缓存和任务流转功能
 */
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

const DOMAIN = 0x0000;
const TAG = 'DistributedTransferUtil';

// 设备信息接口
export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: number;
  networkId: string;
}

// 页面状态接口
export interface PageState {
  curIndex: number; // 当前Tab索引
  windowWidth: number;
  windowHeight: number;
  timestamp: number;
}

export class DistributedTransferUtil {
  private static instance: DistributedTransferUtil;
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private context: common.UIAbilityContext | null = null;
  
  private constructor() {}
  
  public static getInstance(): DistributedTransferUtil {
    if (!DistributedTransferUtil.instance) {
      DistributedTransferUtil.instance = new DistributedTransferUtil();
    }
    return DistributedTransferUtil.instance;
  }
  
  /**
   * 初始化分布式流转工具
   */
  public async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.context = context;
      const bundleName = context.applicationInfo.name;
      this.deviceManager = distributedDeviceManager.createDeviceManager(bundleName);
      hilog.info(DOMAIN, TAG, '分布式流转工具初始化成功');
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, `初始化失败: ${e.message}`);
    }
  }
  
  /**
   * 获取在线设备列表
   */
  public getOnlineDevices(): DeviceInfo[] {
    if (!this.deviceManager) {
      hilog.warn(DOMAIN, TAG, '设备管理器未初始化');
      return [];
    }
    
    try {
      const devices = this.deviceManager.getAvailableDeviceListSync();
      const localNetworkId = this.deviceManager.getLocalDeviceNetworkId();
      
      // 过滤掉本地设备
      const result: DeviceInfo[] = [];
      for (let i = 0; i < devices.length; i++) {
        const device = devices[i];
        if (device.networkId !== localNetworkId) {
          const info: DeviceInfo = {
            deviceId: device.deviceId,
            deviceName: device.deviceName,
            deviceType: Number(device.deviceType),
            networkId: device.networkId ?? ''
          };
          result.push(info);
        }
      }
      
      return result;
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, `获取设备列表失败: ${e.message}`);
      return [];
    }
  }
  
  /**
   * 缓存当前页面状态
   */
  public cachePageState(state: PageState): string {
    try {
      const stateJson = JSON.stringify(state);
      hilog.info(DOMAIN, TAG, `缓存页面状态: ${stateJson}`);
      return stateJson;
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, `缓存状态失败: ${e.message}`);
      return '';
    }
  }
  
  /**
   * 恢复页面状态
   */
  public restorePageState(stateJson: string): PageState | null {
    try {
      const state = JSON.parse(stateJson) as PageState;
      hilog.info(DOMAIN, TAG, `恢复页面状态: Tab索引=${state.curIndex}`);
      return state;
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, `恢复状态失败: ${e.message}`);
      return null;
    }
  }
  
  /**
   * 发起分布式任务流转
   * 注意：此方法会缓存页面状态，并提示用户使用系统超级终端面板进行流转
   * 因为distributedMissionManager是系统API，三方应用无法直接调用
   * 
   * 使用方式：
   * 1. 用户在设备选择弹窗中选择目标设备
   * 2. 应用缓存当前页面状态
   * 3. 引导用户使用系统超级终端面板（从屏幕右上角下滑打开）
   * 4. 系统自动调用应用的onContinue方法完成流转
   */
  public async startMigration(targetDevice: DeviceInfo, pageState: PageState): Promise<boolean> {
    hilog.info(DOMAIN, TAG, 
      `准备流转到设备: ${targetDevice.deviceName} (${targetDevice.networkId})`);
    
    // 缓存页面状态到本地存储
    const stateJson = this.cachePageState(pageState);
    if (stateJson) {
      hilog.info(DOMAIN, TAG, '页面状态已缓存，等待用户使用超级终端面板');
      // 返回false表示需要用户手动使用超级终端面板
      return false;
    }
    
    return false;
  }
  
  /**
   * 释放资源
   */
  public release(): void {
    if (this.deviceManager) {
      try {
        distributedDeviceManager.releaseDeviceManager(this.deviceManager);
        this.deviceManager = null;
        hilog.info(DOMAIN, TAG, '分布式流转工具资源已释放');
      } catch (err) {
        const e = err as BusinessError;
        hilog.error(DOMAIN, TAG, `释放资源失败: ${e.message}`);
      }
    }
  }
}
