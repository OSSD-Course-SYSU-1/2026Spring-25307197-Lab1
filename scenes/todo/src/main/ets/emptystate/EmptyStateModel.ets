/**
 * 空状态配置模型 - 使用 AppStorageV2 持久化
 */
@ObservedV2
export class EmptyStateConfig {
  @Trace
  isCustomMode: boolean = false; // 是否使用自定义文案模式
  
  @Trace
  customText: string = ''; // 用户自定义文案
  
  @Trace
  shownTextIndexes: number[] = []; // 最近显示过的文案索引（用于避免重复）
  
  @Trace
  lastShowDate: string = ''; // 最后显示日期（YYYY-MM-DD格式）
  
  @Trace
  currentSystemIndex: number = -1; // 当前显示的系统文案索引
}
