/**
 * 分布式任务流转使用示例
 * 演示如何使用分布式任务管理和设备互联能力
 */
import DistributedMissionManagerUtil, { ContinueState } from './DistributedMissionManager';
import DeviceConnectivityManager, { DeviceInfo, DeviceStateChange } from './DeviceConnectivityManager';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import Logger from './Logger';

const TAG = 'DistributedExample';

/**
 * 分布式任务流转管理类
 * 整合设备互联和任务管理能力
 */
export class DistributedTaskFlowManager {
  private static instance: DistributedTaskFlowManager;
  private missionManager: DistributedMissionManagerUtil;
  private connectivityManager: DeviceConnectivityManager;
  private isInitialized: boolean = false;
  
  private constructor() {
    this.missionManager = DistributedMissionManagerUtil.getInstance();
    this.connectivityManager = DeviceConnectivityManager.getInstance();
  }
  
  /**
   * 获取单例实例
   */
  static getInstance(): DistributedTaskFlowManager {
    if (!DistributedTaskFlowManager.instance) {
      DistributedTaskFlowManager.instance = new DistributedTaskFlowManager();
    }
    return DistributedTaskFlowManager.instance;
  }
  
  /**
   * 初始化分布式能力
   * @param context 应用上下文
   * @param bundleName 应用包名
   */
  async initialize(context: common.UIAbilityContext, bundleName: string): Promise<void> {
    if (this.isInitialized) {
      Logger.info(TAG, '分布式能力已初始化');
      return;
    }
    
    try {
      // 1. 申请分布式权限
      await this.requestDistributedPermissions(context);
      
      // 2. 初始化设备管理器
      await this.connectivityManager.initDeviceManager(bundleName);
      
      // 3. 注册设备状态监听
      this.registerDeviceStateListener();
      
      // 4. 开始发现设备
      this.startDeviceDiscovery();
      
      this.isInitialized = true;
      Logger.info(TAG, '分布式能力初始化完成');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `分布式能力初始化失败: ${err.message}`);
      throw new Error(`分布式能力初始化失败: ${err.message}`);
    }
  }
  
  /**
   * 申请分布式权限
   * @param context 应用上下文
   */
  private async requestDistributedPermissions(context: common.UIAbilityContext): Promise<void> {
    const atManager = abilityAccessCtrl.createAtManager();
    
    try {
      const result = await atManager.requestPermissionsFromUser(context, [
        'ohos.permission.DISTRIBUTED_DATASYNC',
        'ohos.permission.MANAGE_MISSIONS',
        'ohos.permission.GET_NETWORK_INFO'
      ]);
      
      Logger.info(TAG, `权限申请结果: ${JSON.stringify(result)}`);
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `权限申请失败: ${err.message}`);
      throw new Error(`权限申请失败: ${err.message}`);
    }
  }
  
  /**
   * 注册设备状态监听
   */
  private registerDeviceStateListener(): void {
    this.connectivityManager.registerDeviceStateListener(
      // 设备上线
      (device: DeviceInfo) => {
        Logger.info(TAG, `设备上线: ${device.deviceName}`);
        // 设备上线后，开始同步任务
        this.startSyncMissions(device.deviceId);
      },
      // 设备下线
      (device: DeviceInfo) => {
        Logger.info(TAG, `设备下线: ${device.deviceName}`);
        // 设备下线后，停止同步任务
        this.stopSyncMissions(device.deviceId);
      }
    );
  }
  
  /**
   * 开始发现设备
   */
  private startDeviceDiscovery(): void {
    this.connectivityManager.startDeviceDiscovery(
      // 发现设备
      (device: DeviceInfo) => {
        Logger.info(TAG, `发现设备: ${device.deviceName}, 类型: ${device.deviceType}`);
        // 发现设备后，可以自动绑定或提示用户绑定
      },
      // 发现失败
      (reason: number) => {
        Logger.error(TAG, `发现设备失败: ${reason}`);
      }
    );
  }
  
  /**
   * 开始同步任务
   * @param deviceId 设备ID
   */
  private startSyncMissions(deviceId: string): void {
    // 注册任务监听
    this.missionManager.registerMissionListener(
      deviceId,
      // 任务变化
      (deviceId: string) => {
        Logger.info(TAG, `设备 ${deviceId} 任务发生变化`);
      },
      // 快照变化
      (deviceId: string, missionId: number) => {
        Logger.info(TAG, `设备 ${deviceId} 任务快照变化: ${missionId}`);
      },
      // 网络断开
      (deviceId: string, state: number) => {
        Logger.info(TAG, `设备 ${deviceId} 网络断开: ${state}`);
      }
    ).then(() => {
      // 开始同步远端任务
      return this.missionManager.startSyncRemoteMissions(deviceId);
    }).then(() => {
      Logger.info(TAG, `开始同步设备 ${deviceId} 的任务`);
    }).catch((error: Error) => {
      Logger.error(TAG, `同步任务失败: ${error.message}`);
    });
  }
  
  /**
   * 停止同步任务
   * @param deviceId 设备ID
   */
  private stopSyncMissions(deviceId: string): void {
    this.missionManager.stopSyncRemoteMissions(deviceId)
      .then(() => {
        return this.missionManager.unregisterMissionListener(deviceId);
      })
      .then(() => {
        Logger.info(TAG, `停止同步设备 ${deviceId} 的任务`);
      })
      .catch((error: Error) => {
        Logger.error(TAG, `停止同步任务失败: ${error.message}`);
      });
  }
  
  /**
   * 迁移任务到目标设备
   * @param targetDeviceId 目标设备ID
   * @param missionId 任务ID（可选）
   * @param bundleName 包名（可选）
   */
  async migrateTask(
    targetDeviceId: string,
    missionId?: number,
    bundleName?: string
  ): Promise<void> {
    try {
      const localDeviceId = this.connectivityManager.getLocalDeviceNetworkId();
      
      if (missionId) {
        // 通过任务ID迁移
        await this.missionManager.continueMissionById(
          localDeviceId,
          targetDeviceId,
          missionId,
          { 'key': 'value' }
        );
        Logger.info(TAG, `任务 ${missionId} 迁移成功`);
      } else if (bundleName) {
        // 通过包名迁移
        await this.missionManager.continueMissionByBundleName(
          localDeviceId,
          targetDeviceId,
          bundleName,
          { 'key': 'value' }
        );
        Logger.info(TAG, `应用 ${bundleName} 迁移成功`);
      }
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `任务迁移失败: ${err.message}`);
      throw new Error(`任务迁移失败: ${err.message}`);
    }
  }
  
  /**
   * 注册任务流转状态监听
   */
  registerContinueStateListener(): void {
    this.missionManager.registerContinueStateChange(
      (state: ContinueState, info: Record<string, Object>) => {
        const stateStr = state === ContinueState.ACTIVE ? '激活' : '未激活';
        Logger.info(TAG, `任务流转状态: ${stateStr}, 信息: ${JSON.stringify(info)}`);
      }
    );
  }
  
  /**
   * 获取可用设备列表
   */
  getAvailableDevices(): DeviceInfo[] {
    return this.connectivityManager.getAvailableDeviceList();
  }
  
  /**
   * 绑定设备
   * @param deviceId 设备ID
   */
  async bindDevice(deviceId: string): Promise<void> {
    return this.connectivityManager.bindDevice(deviceId);
  }
  
  /**
   * 释放资源
   */
  release(): void {
    this.connectivityManager.stopDeviceDiscovery();
    this.connectivityManager.unregisterDeviceStateListener();
    this.missionManager.unregisterContinueStateChange();
    this.connectivityManager.releaseDeviceManager();
    this.isInitialized = false;
    Logger.info(TAG, '分布式资源释放完成');
  }
}

export default DistributedTaskFlowManager;

/**
 * 使用示例：
 * 
 * // 在 Ability 中初始化
 * export default class EntryAbility extends UIAbility {
 *   onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
 *     // 初始化分布式能力
 *     const flowManager = DistributedTaskFlowManager.getInstance();
 *     flowManager.initialize(this.context, 'com.example.calendar');
 *   }
 *   
 *   onDestroy(): void {
 *     // 释放资源
 *     const flowManager = DistributedTaskFlowManager.getInstance();
 *     flowManager.release();
 *   }
 * }
 * 
 * // 在页面中使用
 * @Entry
 * @Component
 * struct IndexPage {
 *   build() {
 *     Column() {
 *       Button('获取设备列表')
 *         .onClick(() => {
 *           const flowManager = DistributedTaskFlowManager.getInstance();
 *           const devices = flowManager.getAvailableDevices();
 *           console.log('可用设备:', devices);
 *         })
 *       
 *       Button('迁移任务')
 *         .onClick(() => {
 *           const flowManager = DistributedTaskFlowManager.getInstance();
 *           const devices = flowManager.getAvailableDevices();
 *           if (devices.length > 0) {
 *             // 迁移到第一个可用设备
 *             flowManager.migrateTask(devices[0].deviceId, undefined, 'com.example.calendar');
 *           }
 *         })
 *     }
 *   }
 * }
 */
