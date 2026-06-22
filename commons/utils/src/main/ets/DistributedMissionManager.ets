/**
 * 分布式任务管理工具类
 * 提供跨设备任务管理能力，包括任务监听、同步和迁移
 * 
 * 注意：@ohos.distributedMissionManager 是系统接口，三方应用无法使用
 * 此文件为存根实现，实际功能需要系统应用权限
 */
import { BusinessError } from '@ohos.base';
import Logger from './Logger';

const TAG = 'DistributedMissionManager';

/**
 * 任务变化回调信息
 */
export interface MissionChangeInfo {
  deviceId: string;
  missionId?: number;
  state?: number;
}

/**
 * 任务流转状态
 */
export enum ContinueState {
  ACTIVE = 0,    // 激活状态
  INACTIVE = 1   // 未激活状态
}

/**
 * 分布式任务管理器
 * 
 * 注意：此类的功能需要系统权限，三方应用无法使用
 */
export class DistributedMissionManagerUtil {
  private static instance: DistributedMissionManagerUtil;
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  static getInstance(): DistributedMissionManagerUtil {
    if (!DistributedMissionManagerUtil.instance) {
      DistributedMissionManagerUtil.instance = new DistributedMissionManagerUtil();
    }
    return DistributedMissionManagerUtil.instance;
  }
  
  /**
   * 注册任务状态监听
   * @param deviceId 设备ID，空字符串表示监听所有设备
   * @param onMissionsChanged 任务变化回调
   * @param onSnapshot 快照变化回调
   * @param onNetDisconnect 网络断开回调
   */
  registerMissionListener(
    deviceId: string = '',
    onMissionsChanged?: (deviceId: string) => void,
    onSnapshot?: (deviceId: string, missionId: number) => void,
    onNetDisconnect?: (deviceId: string, state: number) => void
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      Logger.warn(TAG, '分布式任务管理是系统接口，三方应用无法使用');
      reject(new Error('分布式任务管理是系统接口，三方应用无法使用'));
    });
  }
  
  /**
   * 取消任务状态监听
   * @param deviceId 设备ID
   */
  unregisterMissionListener(deviceId: string = ''): Promise<void> {
    return new Promise((resolve, reject) => {
      Logger.warn(TAG, '分布式任务管理是系统接口，三方应用无法使用');
      reject(new Error('分布式任务管理是系统接口，三方应用无法使用'));
    });
  }
  
  /**
   * 开始同步远端设备任务列表
   * @param deviceId 目标设备ID
   * @param fixConflict 是否修复冲突
   */
  startSyncRemoteMissions(deviceId: string = '', fixConflict: boolean = false): Promise<void> {
    return new Promise((resolve, reject) => {
      Logger.warn(TAG, '分布式任务管理是系统接口，三方应用无法使用');
      reject(new Error('分布式任务管理是系统接口，三方应用无法使用'));
    });
  }
  
  /**
   * 停止同步远端设备任务列表
   * @param deviceId 目标设备ID
   */
  stopSyncRemoteMissions(deviceId: string = ''): Promise<void> {
    return new Promise((resolve, reject) => {
      Logger.warn(TAG, '分布式任务管理是系统接口，三方应用无法使用');
      reject(new Error('分布式任务管理是系统接口，三方应用无法使用'));
    });
  }
  
  /**
   * 通过任务ID迁移任务
   * @param srcDeviceId 源设备ID
   * @param dstDeviceId 目标设备ID
   * @param missionId 任务ID
   * @param wantParam 迁移参数
   */
  continueMissionById(
    srcDeviceId: string,
    dstDeviceId: string,
    missionId: number,
    wantParam: Record<string, Object> = {}
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      Logger.warn(TAG, '分布式任务管理是系统接口，三方应用无法使用');
      reject(new Error('分布式任务管理是系统接口，三方应用无法使用'));
    });
  }
  
  /**
   * 通过包名迁移任务
   * @param srcDeviceId 源设备ID
   * @param dstDeviceId 目标设备ID
   * @param bundleName 包名
   * @param wantParam 迁移参数
   */
  continueMissionByBundleName(
    srcDeviceId: string,
    dstDeviceId: string,
    bundleName: string,
    wantParam: Record<string, Object> = {}
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      Logger.warn(TAG, '分布式任务管理是系统接口，三方应用无法使用');
      reject(new Error('分布式任务管理是系统接口，三方应用无法使用'));
    });
  }
  
  /**
   * 注册任务流转状态监听
   * @param callback 状态变化回调
   */
  registerContinueStateChange(
    callback: (state: ContinueState, info: Record<string, Object>) => void
  ): void {
    Logger.warn(TAG, '分布式任务管理是系统接口，三方应用无法使用');
  }
  
  /**
   * 取消任务流转状态监听
   */
  unregisterContinueStateChange(): void {
    Logger.warn(TAG, '分布式任务管理是系统接口，三方应用无法使用');
  }
}

export default DistributedMissionManagerUtil;
