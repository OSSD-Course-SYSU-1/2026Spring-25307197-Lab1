import { hilog } from '@kit.PerformanceAnalysisKit';

const LOG_DOMAIN = 0xFF00;
const LOG_TAG = 'ToastManager';

/**
 * 弹窗队列项
 */
export interface ToastQueueItem {
  id: string;
  message: string;
  duration: number; // 毫秒
  timestamp: number;
}

/**
 * 弹窗管理器 - 单例模式
 * 功能：
 * 1. 管理弹窗队列，防止重叠
 * 2. 单条弹窗展示
 * 3. 自动消失逻辑
 */
export class ToastManager {
  private static instance: ToastManager;
  
  // 弹窗队列
  private queue: ToastQueueItem[] = [];
  // 当前显示的弹窗ID
  private currentShowingId: string = '';
  // 是否正在显示
  private isShowing: boolean = false;
  // 弹窗计数器
  private counter: number = 0;
  
  // 回调：显示弹窗
  private onShowCallback: ((item: ToastQueueItem) => void) | null = null;
  // 回调：隐藏弹窗
  private onHideCallback: ((id: string) => void) | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): ToastManager {
    if (!ToastManager.instance) {
      ToastManager.instance = new ToastManager();
    }
    return ToastManager.instance;
  }

  /**
   * 设置显示回调
   */
  public setShowCallback(callback: (item: ToastQueueItem) => void): void {
    this.onShowCallback = callback;
  }

  /**
   * 设置隐藏回调
   */
  public setHideCallback(callback: (id: string) => void): void {
    this.onHideCallback = callback;
  }

  /**
   * 显示弹窗（单条展示，禁止重叠）
   * @param message 弹窗消息
   * @param duration 持续时间（毫秒），默认3000ms
   * @returns 弹窗ID
   */
  public show(message: string, duration: number = 3000): string {
    const id = `toast_${++this.counter}`;
    const item: ToastQueueItem = {
      id,
      message,
      duration,
      timestamp: Date.now()
    };

    // 如果当前有弹窗正在显示，加入队列等待
    if (this.isShowing) {
      this.queue.push(item);
      hilog.info(LOG_DOMAIN, LOG_TAG, `Toast queued: ${id}, queue length: ${this.queue.length}`);
      return id;
    }

    // 直接显示
    this.showItem(item);
    return id;
  }

  /**
   * 显示弹窗项
   */
  private showItem(item: ToastQueueItem): void {
    this.isShowing = true;
    this.currentShowingId = item.id;
    
    hilog.info(LOG_DOMAIN, LOG_TAG, `Showing toast: ${item.id}, message: ${item.message}`);
    
    // 调用显示回调
    if (this.onShowCallback) {
      this.onShowCallback(item);
    }

    // 设置自动消失定时器
    setTimeout(() => {
      this.hide(item.id);
    }, item.duration);
  }

  /**
   * 隐藏弹窗
   */
  public hide(id: string): void {
    if (this.currentShowingId !== id) {
      return;
    }

    hilog.info(LOG_DOMAIN, LOG_TAG, `Hiding toast: ${id}`);
    
    // 调用隐藏回调
    if (this.onHideCallback) {
      this.onHideCallback(id);
    }

    this.isShowing = false;
    this.currentShowingId = '';

    // 检查队列中是否有等待的弹窗
    if (this.queue.length > 0) {
      const nextItem = this.queue.shift();
      if (nextItem) {
        // 延迟显示下一个弹窗，避免视觉跳跃
        setTimeout(() => {
          this.showItem(nextItem);
        }, 100);
      }
    }
  }

  /**
   * 立即隐藏当前弹窗并清空队列
   */
  public clearAll(): void {
    if (this.currentShowingId && this.onHideCallback) {
      this.onHideCallback(this.currentShowingId);
    }
    this.queue = [];
    this.isShowing = false;
    this.currentShowingId = '';
    hilog.info(LOG_DOMAIN, LOG_TAG, 'All toasts cleared');
  }

  /**
   * 获取当前队列长度
   */
  public getQueueLength(): number {
    return this.queue.length;
  }

  /**
   * 是否有弹窗正在显示
   */
  public isCurrentlyShowing(): boolean {
    return this.isShowing;
  }
}

/**
 * 全局便捷方法：显示弹窗
 */
export function showToast(message: string, duration: number = 3000): string {
  return ToastManager.getInstance().show(message, duration);
}

/**
 * 全局便捷方法：隐藏当前弹窗
 */
export function hideCurrentToast(): void {
  ToastManager.getInstance().clearAll();
}
