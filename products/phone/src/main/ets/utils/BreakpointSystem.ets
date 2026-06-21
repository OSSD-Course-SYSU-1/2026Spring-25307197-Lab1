/**
 * 响应式布局断点系统
 * 用于PC窗口拖拽缩放时布局实时重排
 */

/**
 * 断点类型枚举
 * - SM: 小窗口 (< 600vp) - 单列布局
 * - MD: 中等窗口 (600-840vp) - 单列布局
 * - LG: 大窗口 (> 840vp) - 分栏布局
 */
export enum BreakpointType {
  SM = 'sm',
  MD = 'md',
  LG = 'lg'
}

/**
 * 断点阈值定义（单位：vp）
 */
export class BreakpointConstants {
  // SM断点上限
  static readonly BREAKPOINT_SM: number = 600;
  // MD断点上限
  static readonly BREAKPOINT_MD: number = 840;
  
  // 侧边栏宽度（分栏布局时）
  static readonly SIDEBAR_WIDTH: number = 280;
  // 侧边栏最小宽度
  static readonly SIDEBAR_MIN_WIDTH: number = 240;
  // 侧边栏最大宽度
  static readonly SIDEBAR_MAX_WIDTH: number = 320;
}

/**
 * 响应式布局工具类
 */
export class BreakpointSystem {
  /**
   * 根据窗口宽度计算当前断点类型
   * @param width 窗口宽度（vp）
   * @returns 断点类型
   */
  static getBreakpoint(width: number): BreakpointType {
    if (width < BreakpointConstants.BREAKPOINT_SM) {
      return BreakpointType.SM;
    } else if (width < BreakpointConstants.BREAKPOINT_MD) {
      return BreakpointType.MD;
    } else {
      return BreakpointType.LG;
    }
  }
  
  /**
   * 判断是否为分栏布局（大窗口）
   * @param width 窗口宽度（vp）
   * @returns 是否为分栏布局
   */
  static isColumnLayout(width: number): boolean {
    return width >= BreakpointConstants.BREAKPOINT_MD;
  }
  
  /**
   * 判断是否为单列布局（小窗口）
   * @param width 窗口宽度（vp）
   * @returns 是否为单列布局
   */
  static isSingleLayout(width: number): boolean {
    return width < BreakpointConstants.BREAKPOINT_MD;
  }
  
  /**
   * 计算侧边栏宽度
   * @param totalWidth 总窗口宽度
   * @returns 侧边栏宽度
   */
  static getSidebarWidth(totalWidth: number): number {
    // 分栏布局时，侧边栏宽度为固定值，但不超过总宽度的35%
    const maxWidth = Math.min(
      BreakpointConstants.SIDEBAR_MAX_WIDTH,
      totalWidth * 0.35
    );
    return Math.max(
      BreakpointConstants.SIDEBAR_MIN_WIDTH,
      Math.min(BreakpointConstants.SIDEBAR_WIDTH, maxWidth)
    );
  }
  
  /**
   * 计算内容区宽度
   * @param totalWidth 总窗口宽度
   * @returns 内容区宽度
   */
  static getContentWidth(totalWidth: number): number {
    if (BreakpointSystem.isSingleLayout(totalWidth)) {
      return totalWidth;
    }
    return totalWidth - BreakpointSystem.getSidebarWidth(totalWidth);
  }
}
