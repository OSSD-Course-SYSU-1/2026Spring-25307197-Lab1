import { AppStorageV2 } from '@kit.ArkUI';
import { EmptyStateConfig } from './EmptyStateModel';
import { EmptyStateTexts } from './EmptyStateConstants';

/**
 * 空状态文案管理器
 * 负责文案选择、持久化、避免重复等核心逻辑
 */
export class EmptyStateManager {
  private static _instance: EmptyStateManager;
  private _config: EmptyStateConfig;
  
  // 单例模式
  static get instance(): EmptyStateManager {
    if (!EmptyStateManager._instance) {
      EmptyStateManager._instance = new EmptyStateManager();
    }
    return EmptyStateManager._instance;
  }
  
  private constructor() {
    // 使用 AppStorageV2 连接配置，实现持久化
    this._config = AppStorageV2.connect<EmptyStateConfig>(
      EmptyStateConfig,
      () => new EmptyStateConfig()
    )!;
    console.info('[EmptyStateManager] 初始化完成 - isCustomMode:', this._config.isCustomMode)
  }
  
  /**
   * 获取当前应显示的文案
   */
  getCurrentText(): string {
    // 如果是自定义模式且自定义文案不为空，返回自定义文案
    if (this._config.isCustomMode && this._config.customText.trim() !== '') {
      return this._config.customText.trim();
    }
    
    // 否则返回系统文案
    return this.getSystemText();
  }
  
  /**
   * 获取系统文案（带避免重复逻辑）
   */
  private getSystemText(): string {
    const today = this.getTodayString();
    const textCount = EmptyStateTexts.getTextCount();
    
    // 如果是新的一天，清空历史记录
    if (this._config.lastShowDate !== today) {
      this._config.shownTextIndexes = [];
      this._config.lastShowDate = today;
    }
    
    // 如果所有文案都显示过了，清空历史重新开始
    if (this._config.shownTextIndexes.length >= textCount) {
      this._config.shownTextIndexes = [];
    }
    
    // 获取可用的文案索引
    const availableIndexes = this.getAvailableIndexes(textCount);
    
    // 随机选择一个可用索引
    const randomIndex = availableIndexes[Math.floor(Math.random() * availableIndexes.length)];
    
    // 记录已显示的索引
    this._config.shownTextIndexes.push(randomIndex);
    this._config.currentSystemIndex = randomIndex;
    
    return EmptyStateTexts.SYSTEM_TEXTS[randomIndex];
  }
  
  /**
   * 获取可用的文案索引（排除已显示的）
   */
  private getAvailableIndexes(totalCount: number): number[] {
    const available: number[] = [];
    for (let i = 0; i < totalCount; i++) {
      if (this._config.shownTextIndexes.indexOf(i) === -1) {
        available.push(i);
      }
    }
    return available;
  }
  
  /**
   * 切换到下一个系统文案
   */
  switchToNextSystemText(): string {
    // 临时标记当前索引为已显示（如果还没标记）
    if (this._config.currentSystemIndex >= 0 &&
        this._config.shownTextIndexes.indexOf(this._config.currentSystemIndex) === -1) {
      this._config.shownTextIndexes.push(this._config.currentSystemIndex);
    }
    
    return this.getSystemText();
  }
  
  /**
   * 设置自定义文案
   */
  setCustomText(text: string): void {
    this._config.customText = text;
    this._config.isCustomMode = true;
  }
  
  /**
   * 切换到系统文案模式
   */
  switchToSystemMode(): void {
    this._config.isCustomMode = false;
  }
  
  /**
   * 切换到自定义文案模式
   */
  switchToCustomMode(): void {
    this._config.isCustomMode = true;
  }
  
  /**
   * 获取当前配置状态
   */
  getConfig(): EmptyStateConfig {
    return this._config;
  }
  
  /**
   * 判断是否为自定义模式
   */
  isCustomMode(): boolean {
    return this._config.isCustomMode;
  }
  
  /**
   * 获取自定义文案
   */
  getCustomText(): string {
    return this._config.customText;
  }
  
  /**
   * 获取当前系统文案索引
   */
  getCurrentSystemIndex(): number {
    return this._config.currentSystemIndex;
  }
  
  /**
   * 获取今日日期字符串（YYYY-MM-DD）
   */
  private getTodayString(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}
