import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { Logger } from './Logger';
import { AppStorageV2 } from '@kit.ArkUI';

/**
 * 主题颜色枚举
 */
export enum ThemeType {
  GREEN = 'green',      // 绿色主题（默认）
  BLUE = 'blue',        // 蓝色主题
  ORANGE = 'orange',    // 橙色主题
  PURPLE = 'purple',    // 紫色主题
  CYAN = 'cyan'         // 青色主题
}

/**
 * 主题颜色配置接口
 */
export interface ThemeColors {
  primary: string;           // 主色
  primaryLight: string;      // 主色浅色
  primaryDark: string;       // 主色深色
  accent: string;            // 强调色
  background: string;        // 背景色
  cardBg: string;            // 卡片背景色
  text: string;              // 文本色
  textSecondary: string;     // 次要文本色
  divider: string;           // 分割线颜色
}

/**
 * 主题状态模型 - 用于 AppStorageV2
 */
@ObservedV2
export class ThemeState {
  @Trace currentTheme: ThemeType = ThemeType.GREEN;
  
  constructor(theme: ThemeType = ThemeType.GREEN) {
    this.currentTheme = theme;
  }
}

/**
 * 主题管理器
 * 负责主题切换、持久化存储等
 */
export class ThemeManager {
  private static _instance: ThemeManager;
  private dataPreferences: preferences.Preferences | null = null;
  private readonly PREF_FILE_NAME = 'theme_preferences';
  private readonly PREF_KEY_THEME = 'current_theme';
  
  // 主题状态（响应式）
  private themeState: ThemeState | null = null;
  
  // 主题颜色映射表
  private themeColorsMap: Map<ThemeType, ThemeColors> = new Map();

  private constructor() {
    // 初始化主题颜色映射
    this.initThemeColors();
  }

  /**
   * 初始化主题颜色映射
   */
  private initThemeColors(): void {
    // 绿色主题
    const greenColors: ThemeColors = {
      primary: '#4CAF50',
      primaryLight: '#81C784',
      primaryDark: '#388E3C',
      accent: '#8BC34A',
      background: '#F1F8E9',
      cardBg: '#FFFFFF',
      text: '#212121',
      textSecondary: '#757575',
      divider: '#BDBDBD'
    };
    this.themeColorsMap.set(ThemeType.GREEN, greenColors);

    // 蓝色主题
    const blueColors: ThemeColors = {
      primary: '#2196F3',
      primaryLight: '#64B5F6',
      primaryDark: '#1976D2',
      accent: '#03A9F4',
      background: '#E3F2FD',
      cardBg: '#FFFFFF',
      text: '#212121',
      textSecondary: '#757575',
      divider: '#BDBDBD'
    };
    this.themeColorsMap.set(ThemeType.BLUE, blueColors);

    // 橙色主题
    const orangeColors: ThemeColors = {
      primary: '#FF9800',
      primaryLight: '#FFB74D',
      primaryDark: '#F57C00',
      accent: '#FFC107',
      background: '#FFF3E0',
      cardBg: '#FFFFFF',
      text: '#212121',
      textSecondary: '#757575',
      divider: '#BDBDBD'
    };
    this.themeColorsMap.set(ThemeType.ORANGE, orangeColors);

    // 紫色主题
    const purpleColors: ThemeColors = {
      primary: '#9C27B0',
      primaryLight: '#BA68C8',
      primaryDark: '#7B1FA2',
      accent: '#E91E63',
      background: '#F3E5F5',
      cardBg: '#FFFFFF',
      text: '#212121',
      textSecondary: '#757575',
      divider: '#BDBDBD'
    };
    this.themeColorsMap.set(ThemeType.PURPLE, purpleColors);

    // 青色主题
    const cyanColors: ThemeColors = {
      primary: '#00BCD4',
      primaryLight: '#4DD0E1',
      primaryDark: '#0097A7',
      accent: '#00ACC1',
      background: '#E0F7FA',
      cardBg: '#FFFFFF',
      text: '#212121',
      textSecondary: '#757575',
      divider: '#BDBDBD'
    };
    this.themeColorsMap.set(ThemeType.CYAN, cyanColors);
  }

  /**
   * 获取单例实例
   */
  public static get instance(): ThemeManager {
    if (!ThemeManager._instance) {
      ThemeManager._instance = new ThemeManager();
    }
    return ThemeManager._instance;
  }

  /**
   * 初始化主题管理器
   * @param context 上下文
   */
  public init(context?: common.UIAbilityContext): void {
    try {
      const ctx = context || getContext() as common.UIAbilityContext;
      this.dataPreferences = preferences.getPreferencesSync(ctx, { name: this.PREF_FILE_NAME });
      
      // 从持久化存储加载主题，如果没有则使用默认绿色主题
      const savedTheme = this.loadThemeFromPreferences();
      
      // 使用 AppStorageV2 创建响应式主题状态
      this.themeState = AppStorageV2.connect(ThemeState, () => new ThemeState(savedTheme))!;
      
      Logger.info(`ThemeManager: init success, current theme: ${this.themeState.currentTheme}`);
    } catch (e) {
      Logger.error(`ThemeManager: init error: ${JSON.stringify(e)}`);
      // 初始化失败时使用默认主题
      this.themeState = AppStorageV2.connect(ThemeState, () => new ThemeState(ThemeType.GREEN))!;
    }
  }

  /**
   * 获取当前主题
   */
  public get currentTheme(): ThemeType {
    return this.themeState?.currentTheme || ThemeType.GREEN;
  }

  /**
   * 获取主题状态对象（用于组件连接）
   */
  public getThemeState(): ThemeState {
    if (!this.themeState) {
      // 如果未初始化，返回默认状态
      this.themeState = AppStorageV2.connect(ThemeState, () => new ThemeState(ThemeType.GREEN))!;
    }
    return this.themeState;
  }

  /**
   * 获取当前主题颜色配置
   */
  public get currentColors(): ThemeColors {
    return this.themeColorsMap.get(this.currentTheme)!;
  }

  /**
   * 切换主题
   * @param theme 目标主题
   */
  public switchTheme(theme: ThemeType): void {
    if (!this.themeState) {
      Logger.error('ThemeManager: themeState is null');
      return;
    }
    
    Logger.info(`ThemeManager: switching from ${this.themeState.currentTheme} to ${theme}`);
    
    if (this.themeState.currentTheme === theme) {
      Logger.info(`ThemeManager: theme ${theme} is already active`);
      return;
    }

    this.themeState.currentTheme = theme;
    Logger.info(`ThemeManager: themeState.currentTheme updated to ${this.themeState.currentTheme}`);
    
    this.saveThemeToPreferences();
    Logger.info(`ThemeManager: switched to theme ${theme}`);
  }

  /**
   * 获取指定主题的颜色配置
   * @param theme 主题类型
   */
  public getThemeColors(theme: ThemeType): ThemeColors {
    return this.themeColorsMap.get(theme)!;
  }

  /**
   * 获取所有可用主题列表
   */
  public getAllThemes(): ThemeType[] {
    const themes: ThemeType[] = [
      ThemeType.GREEN,
      ThemeType.BLUE,
      ThemeType.ORANGE,
      ThemeType.PURPLE,
      ThemeType.CYAN
    ];
    return themes;
  }

  /**
   * 获取主题显示名称
   * @param theme 主题类型
   */
  public getThemeDisplayName(theme: ThemeType): string {
    const nameMap: Map<ThemeType, string> = new Map();
    nameMap.set(ThemeType.GREEN, '绿色');
    nameMap.set(ThemeType.BLUE, '蓝色');
    nameMap.set(ThemeType.ORANGE, '橙色');
    nameMap.set(ThemeType.PURPLE, '紫色');
    nameMap.set(ThemeType.CYAN, '青色');
    
    return nameMap.get(theme) || theme;
  }

  /**
   * 从持久化存储加载主题
   * @returns 加载的主题类型
   */
  private loadThemeFromPreferences(): ThemeType {
    if (!this.dataPreferences) {
      Logger.warn('ThemeManager: dataPreferences is null, use default theme');
      return ThemeType.GREEN;
    }

    try {
      const savedTheme = this.dataPreferences.getSync(this.PREF_KEY_THEME, ThemeType.GREEN) as string;
      
      // 验证保存的主题是否有效
      if (Object.values(ThemeType).includes(savedTheme as ThemeType)) {
        Logger.info(`ThemeManager: loaded theme from preferences: ${savedTheme}`);
        return savedTheme as ThemeType;
      } else {
        Logger.warn(`ThemeManager: invalid saved theme: ${savedTheme}, use default`);
        return ThemeType.GREEN;
      }
    } catch (e) {
      Logger.error(`ThemeManager: load theme error: ${JSON.stringify(e)}`);
      return ThemeType.GREEN;
    }
  }

  /**
   * 保存主题到持久化存储
   */
  private saveThemeToPreferences(): void {
    if (!this.dataPreferences || !this.themeState) {
      Logger.warn('ThemeManager: dataPreferences or themeState is null, cannot save theme');
      return;
    }

    try {
      this.dataPreferences.putSync(this.PREF_KEY_THEME, this.themeState.currentTheme);
      this.dataPreferences.flushSync();
      Logger.info(`ThemeManager: saved theme to preferences: ${this.themeState.currentTheme}`);
    } catch (e) {
      Logger.error(`ThemeManager: save theme error: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 清除持久化主题数据
   */
  public clearThemePreferences(): void {
    if (!this.dataPreferences) {
      Logger.warn('ThemeManager: dataPreferences is null');
      return;
    }

    try {
      this.dataPreferences.deleteSync(this.PREF_KEY_THEME);
      this.dataPreferences.flushSync();
      Logger.info('ThemeManager: cleared theme preferences');
    } catch (e) {
      Logger.error(`ThemeManager: clear preferences error: ${JSON.stringify(e)}`);
    }
  }
}
