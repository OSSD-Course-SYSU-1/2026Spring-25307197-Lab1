import { FlingDetector, FlingDirection, FlingEvent } from './FlingDetector';
import { FlingAnimationEffects, DragDirectionIndicator, SendStatusAnimation } from './FlingAnimationEffects';
import { TodoItem, DeviceManagerUtil, DeviceInfo, TransferUtil, transferUtil } from '@ohos_agcit/daily_schedule_common_lib';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { curves, AppStorageV2 } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';

const LOG_DOMAIN = 0xFF00;
const LOG_TAG = 'FlingTodoCard';

// 断点类型枚举
export enum BreakpointTypeEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl'
}

// 全局信息模型
@ObservedV2
export class GlobalInfoModel {
  @Trace currentBreakpoint: string = BreakpointTypeEnum.SM;
}

// 断点类型接口
interface BreakpointTypes<T> {
  sm: T;
  md: T;
  lg: T;
}

// 断点适配类（与 daily_schedule_utils 中的实现一致）
class BreakpointType<T> {
  private sm: T;
  private md: T;
  private lg: T;

  public constructor(param: BreakpointTypes<T>) {
    this.sm = param.sm;
    this.md = param.md;
    this.lg = param.lg;
  }

  public getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === 'sm') {
      return this.sm;
    }
    if (currentBreakpoint === 'md') {
      return this.md;
    }
    return this.lg;
  }
}

// 断点适配配置
class BreakpointConfig {
  // 卡片尺寸缩放比例
  static readonly CARD_SCALE: BreakpointTypes<number> = {
    sm: 1.0,
    md: 1.05,
    lg: 1.1
  };
  
  // 甩出距离限制（相对于屏幕宽度的比例）
  static readonly FLING_DISTANCE_RATIO: BreakpointTypes<number> = {
    sm: 0.4,  // 手机：40%屏幕宽度
    md: 0.35, // 平板：35%
    lg: 0.3   // PC：30%
  };
  
  // 最小甩出速度阈值
  static readonly MIN_VELOCITY: BreakpointTypes<number> = {
    sm: 8,   // 手机：降低阈值，更容易触发
    md: 10,  // 平板
    lg: 12   // PC
  };
  
  // 最小甩出距离阈值
  static readonly MIN_DISTANCE: BreakpointTypes<number> = {
    sm: 30,  // 手机：降低阈值，更容易触发
    md: 50,  // 平板
    lg: 70   // PC
  };
}

// 甩出目标位置
interface FlingTarget {
  x: number;
  y: number;
}

/**
 * 可甩出的待办卡片组件
 * 支持甩出发送到其他设备
 */
@ComponentV2
export struct FlingTodoCard {
  // 子组件内容
  @BuilderParam content: () => void;

  // 待办事项数据
  @Param todoItem: TodoItem | null = null;

  // 甩出成功回调
  @Param onFlingSuccess: () => void = () => {};
  
  // 甩出失败回调（速度或距离不够）
  @Param onFlingFail: (reason: string) => void = () => {};

  /**
   * 处理甩出事件
   */
  private async handleFling(event: FlingEvent): Promise<void> {
    hilog.info(LOG_DOMAIN, LOG_TAG,
      `Fling detected: direction=${event.direction}, velocity=${event.velocity}`);

    // 任意方向的甩出都触发设备选择
    if (event.direction !== FlingDirection.NONE && this.todoItem) {
      await this.showDeviceSelectAndSend();
    }
  }
  
  /**
   * 显示设备选择并发送待办
   */
  private async showDeviceSelectAndSend(): Promise<void> {
    if (!this.todoItem) {
      return;
    }
    
    try {
      // 获取在线设备列表
      const deviceManager = DeviceManagerUtil.getInstance();
      const devices = deviceManager.getAvailableDeviceListSync();
      
      if (devices.length === 0) {
        promptAction.showToast({
          message: '没有发现在线设备',
          duration: 2000
        });
        return;
      }
      
      // 如果只有一个设备，直接发送
      if (devices.length === 1) {
        await this.sendTodoToDevice(devices[0]);
        return;
      }
      
      // 多个设备时，显示设备列表
      let deviceListText = '可用设备：\n';
      devices.forEach((device: DeviceInfo, index: number) => {
        deviceListText += `${index + 1}. ${device.deviceName}\n`;
      });
      
      promptAction.showDialog({
        title: '选择发送设备',
        message: deviceListText,
        buttons: [
          { text: '发送到第一个', color: '#4CAF50' },
          { text: '取消', color: '#666666' }
        ]
      }, async (error: Error, data: promptAction.ShowDialogSuccessResponse) => {
        if (error) {
          hilog.error(LOG_DOMAIN, LOG_TAG, `Dialog error: ${error.message}`);
          return;
        }
        
        if (data && data.index === 0) {
          // 发送到第一个设备
          await this.sendTodoToDevice(devices[0]);
        }
      });
    } catch (e) {
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to show device select: ${e}`);
      promptAction.showToast({
        message: '设备选择失败',
        duration: 2000
      });
    }
  }
  
  /**
   * 发送待办到指定设备
   */
  private async sendTodoToDevice(device: DeviceInfo): Promise<void> {
    if (!this.todoItem) {
      return;
    }
    
    promptAction.showToast({
      message: `正在发送到 ${device.deviceName}...`,
      duration: 1500
    });
    
    try {
      const result = await transferUtil.sendTodoToDevice(this.todoItem, device.deviceId);
      
      if (result.success) {
        promptAction.showToast({
          message: `已发送到 ${device.deviceName}`,
          duration: 2000
        });
        
        try {
          this.onFlingSuccess();
          hilog.info(LOG_DOMAIN, LOG_TAG, 'Todo sent successfully');
        } catch (e) {
          hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to call onFlingSuccess: ${e}`);
        }
      } else {
        promptAction.showToast({
          message: `发送失败: ${result.errorMsg || '未知错误'}`,
          duration: 2000
        });
      }
    } catch (e) {
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to send todo: ${e}`);
      promptAction.showToast({
        message: '发送失败',
        duration: 2000
      });
    }
  }

  build() {
    // 用“插槽写法”传递 builder，解决 @BuilderParam 的告警
    FlingDetector({
      minFlingVelocity: 18,
      minFlingDistance: 100,
      panDirection: PanDirection.All,

      onFling: (event: FlingEvent) => {
        this.handleFling(event);
      },

      onDragBegin: () => {
        hilog.info(LOG_DOMAIN, LOG_TAG, 'Drag begin');
      },

      // offsetX/offsetY 未使用：改成 _offsetX/_offsetY 消除告警
      onDragUpdate: (_offsetX: number, _offsetY: number) => {
        // 可在这里添加拖拽视觉反馈
      },

      onDragFinish: () => {
        hilog.info(LOG_DOMAIN, LOG_TAG, 'Drag finish without fling');
      }
    }) {
      this.content()
    }
  }
}

/**
 * 可甩出的待办列表项组件
 * 包装普通的待办列表项，添加甩出发送功能
 * 
 * 特性：
 * 1. 卡片尺寸随窗口自适应
 * 2. 甩出动画不越界
 * 3. 手势仅绑定可视渲染的待办条目
 * 4. 空白区域无法触发甩出
 */
@ComponentV2
export struct FlingTodoListItem {
  // 子组件内容（原始的待办列表项）
  @BuilderParam content: (item: TodoItem) => void;

  // 待办事项数据
  @Param todoItem: TodoItem | null = null;

  // 甩出成功回调
  @Param onFlingSuccess: () => void = () => {};
  
  // 甩出失败回调（速度或距离不够）
  @Param onFlingFail: (reason: string) => void = () => {};
  
  // 是否在可视区域内（由父组件控制）
  @Param isVisible: boolean = true;

  // 内部状态
  @Local isDragging: boolean = false;
  @Local dragOffsetX: number = 0;
  @Local dragOffsetY: number = 0;
  @Local currentVelocity: number = 0;
  
  // 动画状态
  @Local showParticleEffect: boolean = false;
  @Local showSuccessAnimation: boolean = false;
  @Local showDirectionIndicator: boolean = false;
  @Local particleCenterX: number = 0;
  @Local particleCenterY: number = 0;
  @Local cardOpacity: number = 1;
  @Local cardScale: number = 1;
  @Local glowIntensity: number = 0;
  
  // 断点信息
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
  
  // 速度计算相关
  private lastOffsetX: number = 0;
  private lastOffsetY: number = 0;
  private lastMoveTime: number = 0;
  private velocityHistoryX: number[] = [];
  private velocityHistoryY: number[] = [];
  private readonly VELOCITY_HISTORY_SIZE: number = 5;
  private velocityX: number = 0;
  private velocityY: number = 0;
  
  // 组件尺寸和边界
  private componentWidth: number = 0;
  private componentHeight: number = 0;
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  private componentLeft: number = 0;
  private componentTop: number = 0;
  
  // 获取当前断点配置
  private getCardScale(): number {
    const bp = this.globalInfo.currentBreakpoint;
    const config = BreakpointConfig.CARD_SCALE;
    if (bp === 'sm') return config.sm;
    if (bp === 'md') return config.md;
    return config.lg;
  }
  
  private getMinVelocity(): number {
    const bp = this.globalInfo.currentBreakpoint;
    const config = BreakpointConfig.MIN_VELOCITY;
    if (bp === 'sm') return config.sm;
    if (bp === 'md') return config.md;
    return config.lg;
  }
  
  private getMinDistance(): number {
    const bp = this.globalInfo.currentBreakpoint;
    const config = BreakpointConfig.MIN_DISTANCE;
    if (bp === 'sm') return config.sm;
    if (bp === 'md') return config.md;
    return config.lg;
  }
  
  private getFlingDistanceRatio(): number {
    const bp = this.globalInfo.currentBreakpoint;
    const config = BreakpointConfig.FLING_DISTANCE_RATIO;
    if (bp === 'sm') return config.sm;
    if (bp === 'md') return config.md;
    return config.lg;
  }
  
  /**
   * 计算边界限制后的甩出目标位置
   * 确保动画不越界
   */
  private calculateBoundedFlingTarget(angle: number): FlingTarget {
    const maxDistance = Math.min(this.screenWidth, this.screenHeight) * this.getFlingDistanceRatio();
    
    // 计算原始目标位置
    let targetX = Math.cos(angle) * maxDistance;
    let targetY = Math.sin(angle) * maxDistance;
    
    // 边界限制：确保不超出屏幕
    const cardHalfWidth = this.componentWidth / 2;
    const cardHalfHeight = this.componentHeight / 2;
    
    // 左边界
    if (this.componentLeft + targetX < -cardHalfWidth) {
      targetX = -this.componentLeft - cardHalfWidth;
    }
    // 右边界
    if (this.componentLeft + this.componentWidth + targetX > this.screenWidth + cardHalfWidth) {
      targetX = this.screenWidth - this.componentLeft - this.componentWidth + cardHalfWidth;
    }
    // 上边界
    if (this.componentTop + targetY < -cardHalfHeight) {
      targetY = -this.componentTop - cardHalfHeight;
    }
    // 下边界
    if (this.componentTop + this.componentHeight + targetY > this.screenHeight + cardHalfHeight) {
      targetY = this.screenHeight - this.componentTop - this.componentHeight + cardHalfHeight;
    }
    
    const result: FlingTarget = { x: targetX, y: targetY };
    return result;
  }

  build() {
    Stack() {
      // 主内容
      Column() {
        if (this.todoItem) {
          this.content(this.todoItem)
        }
      }
      .width('100%')
      .offset({ x: this.dragOffsetX, y: this.dragOffsetY })
      .opacity(this.cardOpacity)
      .scale({
        x: this.cardScale * this.getCardScale() + (this.isDragging ? 0.05 : 0),
        y: this.cardScale * this.getCardScale() + (this.isDragging ? 0.05 : 0)
      })
      .shadow(this.isDragging ? {
        radius: 30,
        color: `rgba(76, 175, 80, ${0.3 + this.glowIntensity * 0.4})`,
        offsetX: 0,
        offsetY: 10
      } : undefined)
      .borderRadius(12)
      // 手势绑定：使用 priorityGesture 确保手势优先级最高
      .priorityGesture(
        PanGesture({ direction: PanDirection.All, distance: 5 })  // 降低最小触发距离
          .onActionStart(() => {
            hilog.info(LOG_DOMAIN, LOG_TAG, `✋ PanGesture started for: ${this.todoItem?.title}`);
            this.startDrag();
          })
          .onActionUpdate((event: GestureEvent) => {
            this.updateDrag(event);
          })
          .onActionEnd(() => {
            this.endDrag();
          })
      )
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        // 正确获取组件实际尺寸
        if (newValue.width !== undefined && newValue.height !== undefined) {
          const width = newValue.width as number;
          const height = newValue.height as number;
          if (width > 0 && height > 0) {
            this.componentWidth = width;
            this.componentHeight = height;
          }
        }
      })
      
      // 方向指示器
      DragDirectionIndicator({
        offsetX: this.dragOffsetX,
        offsetY: this.dragOffsetY,
        isVisible: this.showDirectionIndicator,
        velocity: this.currentVelocity
      })
      
      // 粒子效果
      FlingAnimationEffects({
        isVisible: this.showParticleEffect,
        centerX: this.componentWidth / 2,
        centerY: this.componentHeight / 2,
        animationType: 'particle',
        particleColor: '#4CAF50'
      })
      
      // 成功动画
      FlingAnimationEffects({
        isVisible: this.showSuccessAnimation,
        centerX: this.componentWidth / 2,
        centerY: this.componentHeight / 2,
        animationType: 'success',
        particleColor: '#4CAF50'
      })
    }
    .width('100%')
    .height('100%')  // 确保 Stack 有正确的高度
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      // 正确获取窗口/容器尺寸
      if (newValue.width !== undefined && newValue.height !== undefined) {
        const width = newValue.width as number;
        const height = newValue.height as number;
        if (width > 0 && height > 0) {
          this.screenWidth = width;
          this.screenHeight = height;
        }
      }
    })
  }

  // 组件生命周期：初始化时获取屏幕尺寸
  aboutToAppear(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync();
      this.screenWidth = displayInfo.width;
      this.screenHeight = displayInfo.height;
      hilog.info(LOG_DOMAIN, LOG_TAG, 
        `📱 FlingTodoListItem initialized: ${this.screenWidth}x${this.screenHeight}, isVisible=${this.isVisible}, todoItem=${this.todoItem?.title}`);
    } catch (e) {
      hilog.warn(LOG_DOMAIN, LOG_TAG, `Failed to get display info: ${e}`);
      // 使用默认值
      this.screenWidth = 360;
      this.screenHeight = 640;
    }
  }

  private startDrag(): void {
    this.isDragging = true;
    this.showDirectionIndicator = true;
    this.dragOffsetX = 0;
    this.dragOffsetY = 0;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
    this.lastMoveTime = Date.now();
    this.velocityHistoryX = [];
    this.velocityHistoryY = [];
    this.velocityX = 0;
    this.velocityY = 0;
    this.currentVelocity = 0;
    
    // 拖拽开始动画
    animateTo({
      duration: 200,
      curve: curves.springMotion(0.6, 0.8)
    }, () => {
      this.cardScale = 1.02;
    });
    
    hilog.info(LOG_DOMAIN, LOG_TAG, `✋ Drag started, isVisible=${this.isVisible}, todoItem=${this.todoItem?.title}`);
  }

  private updateDrag(event: GestureEvent): void {
    const currentTime = Date.now();
    const deltaTime = currentTime - this.lastMoveTime;

    if (deltaTime > 0) {
      const instantVelocityX = (event.offsetX - this.lastOffsetX) / deltaTime * 16.67;
      const instantVelocityY = (event.offsetY - this.lastOffsetY) / deltaTime * 16.67;

      this.velocityHistoryX.push(instantVelocityX);
      this.velocityHistoryY.push(instantVelocityY);

      if (this.velocityHistoryX.length > this.VELOCITY_HISTORY_SIZE) {
        this.velocityHistoryX.shift();
        this.velocityHistoryY.shift();
      }

      this.velocityX = this.velocityHistoryX.reduce((a, b) => a + b, 0) / this.velocityHistoryX.length;
      this.velocityY = this.velocityHistoryY.reduce((a, b) => a + b, 0) / this.velocityHistoryY.length;
    }

    this.lastOffsetX = event.offsetX;
    this.lastOffsetY = event.offsetY;
    this.lastMoveTime = currentTime;

    this.dragOffsetX = event.offsetX;
    this.dragOffsetY = event.offsetY;
    
    // 计算当前速度
    this.currentVelocity = Math.sqrt(this.velocityX * this.velocityX + this.velocityY * this.velocityY);
    
    // 根据速度调整光晕强度
    this.glowIntensity = Math.min(1, this.currentVelocity / 20);
  }

  private endDrag(): void {
    const totalVelocity = Math.sqrt(this.velocityX * this.velocityX + this.velocityY * this.velocityY);
    const totalOffset = Math.sqrt(this.dragOffsetX * this.dragOffsetX + this.dragOffsetY * this.dragOffsetY);
    
    // 使用自适应阈值
    const minVelocity = this.getMinVelocity();
    const minDistance = this.getMinDistance();

    hilog.info(LOG_DOMAIN, LOG_TAG, 
      `Drag ended: velocity=${totalVelocity.toFixed(2)}(min:${minVelocity}), offset=${totalOffset.toFixed(2)}(min:${minDistance})`);

    if (totalVelocity >= minVelocity && totalOffset >= minDistance && this.todoItem) {
      // 触发甩出
      this.triggerFling();
    } else {
      // 回弹动画
      this.animateBounceBack();
      
      // 通知甩出失败（延迟调用，避免在动画过程中触发）
      setTimeout(() => {
        try {
          let reason = '甩出条件不满足';
          if (totalVelocity < minVelocity) {
            reason = `速度不够 (当前: ${totalVelocity.toFixed(1)}, 需要: ${minVelocity})`;
          } else if (totalOffset < minDistance) {
            reason = `距离不够 (当前: ${totalOffset.toFixed(1)}, 需要: ${minDistance})`;
          }
          if (this.onFlingFail) {
            this.onFlingFail(reason);
          }
        } catch (e) {
          hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to call onFlingFail: ${e}`);
        }
      }, 100);
    }
    
    this.showDirectionIndicator = false;
  }
  
  /**
   * 触发甩出发送（带边界限制）
   */
  private triggerFling(): void {
    hilog.info(LOG_DOMAIN, LOG_TAG, 'Fling triggered!');
    
    // 显示粒子效果
    this.showParticleEffect = true;
    
    // 计算甩出方向角度
    const angle = Math.atan2(this.velocityY, this.velocityX);
    
    // 使用边界限制计算目标位置
    const target = this.calculateBoundedFlingTarget(angle);
    
    hilog.info(LOG_DOMAIN, LOG_TAG, 
      `Fling target: x=${target.x.toFixed(1)}, y=${target.y.toFixed(1)}, breakpoint=${this.globalInfo.currentBreakpoint}`);
    
    animateTo({
      duration: 400,
      curve: curves.springMotion(0.5, 0.8),
      onFinish: () => {
        // 显示设备选择对话框
        this.showDeviceSelectDialog();
      }
    }, () => {
      this.dragOffsetX = target.x;
      this.dragOffsetY = target.y;
      this.cardOpacity = 0;
      this.cardScale = 0.8;
    });
  }
  
  /**
   * 显示设备选择对话框
   */
  private async showDeviceSelectDialog(): Promise<void> {
    if (!this.todoItem) {
      return;
    }
    
    try {
      // 获取在线设备列表
      const deviceManager = DeviceManagerUtil.getInstance();
      const devices = deviceManager.getAvailableDeviceListSync();
      
      if (devices.length === 0) {
        promptAction.showToast({
          message: '没有发现在线设备',
          duration: 2000
        });
        this.resetState();
        return;
      }
      
      // 如果只有一个设备，直接发送
      if (devices.length === 1) {
        await this.sendTodoToDevice(devices[0]);
        return;
      }
      
      // 多个设备时，显示设备列表
      let deviceListText = '可用设备：\n';
      devices.forEach((device: DeviceInfo, index: number) => {
        deviceListText += `${index + 1}. ${device.deviceName}\n`;
      });
      
      promptAction.showDialog({
        title: '选择发送设备',
        message: deviceListText,
        buttons: [
          { text: '发送到第一个', color: '#4CAF50' },
          { text: '取消', color: '#666666' }
        ]
      }, async (error: Error, data: promptAction.ShowDialogSuccessResponse) => {
        if (error) {
          hilog.error(LOG_DOMAIN, LOG_TAG, `Dialog error: ${error.message}`);
          this.resetState();
          return;
        }
        
        if (data && data.index === 0) {
          // 发送到第一个设备
          await this.sendTodoToDevice(devices[0]);
        } else {
          this.resetState();
        }
      });
    } catch (e) {
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to show device select: ${e}`);
      promptAction.showToast({
        message: '设备选择失败',
        duration: 2000
      });
      this.resetState();
    }
  }
  
  /**
   * 发送待办到指定设备
   */
  private async sendTodoToDevice(device: DeviceInfo): Promise<void> {
    if (!this.todoItem) {
      return;
    }
    
    promptAction.showToast({
      message: `正在发送到 ${device.deviceName}...`,
      duration: 1500
    });
    
    try {
      const result = await transferUtil.sendTodoToDevice(this.todoItem, device.deviceId);
      
      if (result.success) {
        promptAction.showToast({
          message: `已发送到 ${device.deviceName}`,
          duration: 2000
        });
        
        try {
          this.onFlingSuccess();
          this.showSuccessFeedback();
          hilog.info(LOG_DOMAIN, LOG_TAG, 'Todo sent successfully');
        } catch (e) {
          hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to call onFlingSuccess: ${e}`);
        }
      } else {
        promptAction.showToast({
          message: `发送失败: ${result.errorMsg || '未知错误'}`,
          duration: 2000
        });
      }
      
      this.resetState();
    } catch (e) {
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to send todo: ${e}`);
      promptAction.showToast({
        message: '发送失败',
        duration: 2000
      });
      this.resetState();
    }
  }
  
  /**
   * 显示成功反馈
   */
  private showSuccessFeedback(): void {
    this.showSuccessAnimation = true;
    
    // 震动反馈（如果支持）
    try {
      // vibrator.vibrate({
      //   type: 'time',
      //   duration: 100
      // });
    } catch (err) {
      hilog.warn(LOG_DOMAIN, LOG_TAG, 'Vibration not supported');
    }
  }

  private animateBounceBack(): void {
    animateTo({
      duration: 300,
      curve: curves.springMotion(0.6, 0.8)
    }, () => {
      this.dragOffsetX = 0;
      this.dragOffsetY = 0;
      this.cardScale = 1;
      this.glowIntensity = 0;
      this.isDragging = false;
    });
  }
  
  /**
   * 重置状态
   */
  private resetState(): void {
    this.isDragging = false;
    this.dragOffsetX = 0;
    this.dragOffsetY = 0;
    this.cardOpacity = 1;
    this.cardScale = 1;
    this.glowIntensity = 0;
    this.showParticleEffect = false;
    this.currentVelocity = 0;
    
    // 延迟隐藏成功动画
    setTimeout(() => {
      this.showSuccessAnimation = false;
    }, 1000);
  }
}
