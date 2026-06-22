import { ThemeManager, ThemeType, ThemeColors } from '../utils/ThemeManager';

/**
 * 主题选择器组件示例
 * 展示如何使用 ThemeManager 进行主题切换
 */
@Component
export struct ThemeSelectorExample {
  @State currentTheme: ThemeType = ThemeManager.instance.currentTheme;
  @State currentColors: ThemeColors = ThemeManager.instance.currentColors;
  private themes: ThemeType[] = ThemeManager.instance.getAllThemes();

  build() {
    Column() {
      // 标题
      Text('主题设置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.currentColors.text)
        .margin({ bottom: 30 })

      // 当前主题显示
      Row() {
        Text('当前主题：')
          .fontSize(16)
          .fontColor(this.currentColors.textSecondary)
        
        Text(ThemeManager.instance.getThemeDisplayName(this.currentTheme))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentColors.primary)
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 主题列表
      Column() {
        ForEach(this.themes, (theme: ThemeType) => {
          this.ThemeItem(theme)
        })
      }
      .width('100%')
      .backgroundColor(this.currentColors.cardBg)
      .borderRadius(12)
      .padding(16)

      // 颜色预览
      this.ColorPreview()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentColors.background)
    .padding(20)
  }

  /**
   * 主题选项组件
   */
  @Builder
  ThemeItem(theme: ThemeType) {
    Row() {
      // 主题颜色圆点
      Circle()
        .width(24)
        .height(24)
        .fill(ThemeManager.instance.getThemeColors(theme).primary)
      
      // 主题名称
      Text(ThemeManager.instance.getThemeDisplayName(theme))
        .fontSize(16)
        .fontColor(this.currentColors.text)
        .margin({ left: 12 })
        .layoutWeight(1)

      // 选中标记
      if (this.currentTheme === theme) {
        Text('✓')
          .fontSize(18)
          .fontColor(this.currentColors.primary)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .height(56)
    .onClick(() => {
      this.onThemeChange(theme);
    })
  }

  /**
   * 颜色预览组件
   */
  @Builder
  ColorPreview() {
    Column() {
      Text('颜色预览')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentColors.text)
        .margin({ bottom: 16 })

      // 主色
      Row() {
        Text('主色')
          .fontSize(14)
          .fontColor(this.currentColors.textSecondary)
          .width(80)
        
        Row()
          .width(40)
          .height(24)
          .backgroundColor(this.currentColors.primary)
          .borderRadius(4)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 强调色
      Row() {
        Text('强调色')
          .fontSize(14)
          .fontColor(this.currentColors.textSecondary)
          .width(80)
        
        Row()
          .width(40)
          .height(24)
          .backgroundColor(this.currentColors.accent)
          .borderRadius(4)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 背景色
      Row() {
        Text('背景色')
          .fontSize(14)
          .fontColor(this.currentColors.textSecondary)
          .width(80)
        
        Row()
          .width(40)
          .height(24)
          .backgroundColor(this.currentColors.background)
          .borderRadius(4)
          .border({ width: 1, color: this.currentColors.divider })
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.currentColors.cardBg)
    .borderRadius(12)
    .padding(16)
    .margin({ top: 20 })
  }

  /**
   * 主题切换处理
   */
  private onThemeChange(theme: ThemeType): void {
    // 切换主题
    ThemeManager.instance.switchTheme(theme);
    
    // 更新本地状态
    this.currentTheme = theme;
    this.currentColors = ThemeManager.instance.currentColors;
  }
}
