# ThemeManager 使用指南

## 概述

ThemeManager 是一个主题管理工具类，提供多套主题颜色配置、主题切换和持久化存储功能。

## 主题类型

内置 5 套主题：
- **GREEN（绿色）** - 默认主题
- **BLUE（蓝色）**
- **ORANGE（橙色）**
- **PURPLE（紫色）**
- **CYAN（青色）**

## 基本用法

### 1. 初始化

在应用启动时（EntryAbility 的 onCreate 方法中）初始化：

```typescript
import { ThemeManager } from '@ohos_agcit/daily_schedule_common_lib';

// 在 onCreate 中初始化
ThemeManager.instance.init(this.context);
```

### 2. 获取当前主题

```typescript
import { ThemeManager, ThemeType } from '@ohos_agcit/daily_schedule_common_lib';

// 获取当前主题类型
const currentTheme = ThemeManager.instance.currentTheme;

// 判断是否为某个主题
if (currentTheme === ThemeType.GREEN) {
  console.log('当前是绿色主题');
}
```

### 3. 切换主题

```typescript
import { ThemeManager, ThemeType } from '@ohos_agcit/daily_schedule_common_lib';

// 切换到蓝色主题
ThemeManager.instance.switchTheme(ThemeType.BLUE);

// 切换到橙色主题
ThemeManager.instance.switchTheme(ThemeType.ORANGE);
```

### 4. 获取主题颜色配置

```typescript
import { ThemeManager } from '@ohos_agcit/daily_schedule_common_lib';

// 获取当前主题的颜色配置
const colors = ThemeManager.instance.currentColors;

// 使用颜色配置
console.log('主色:', colors.primary);
console.log('背景色:', colors.background);
console.log('文本色:', colors.text);
```

### 5. 在 UI 组件中使用

```typescript
import { ThemeManager, ThemeType, ThemeColors } from '@ohos_agcit/daily_schedule_common_lib';

@Entry
@Component
struct MyComponent {
  @State currentColors: ThemeColors = ThemeManager.instance.currentColors;

  build() {
    Column() {
      Text('主题示例')
        .fontColor(this.currentColors.text)
        .backgroundColor(this.currentColors.primary)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentColors.background)
  }

  // 监听主题变化
  aboutToAppear() {
    // 可以在这里订阅主题变化通知
  }
}
```

### 6. 获取所有可用主题

```typescript
import { ThemeManager, ThemeType } from '@ohos_agcit/daily_schedule_common_lib';

// 获取所有主题列表
const allThemes = ThemeManager.instance.getAllThemes();
// 返回: [ThemeType.GREEN, ThemeType.BLUE, ThemeType.ORANGE, ThemeType.PURPLE, ThemeType.CYAN]

// 获取主题显示名称
const displayName = ThemeManager.instance.getThemeDisplayName(ThemeType.BLUE);
// 返回: '蓝色'
```

### 7. 创建主题选择器组件

```typescript
import { ThemeManager, ThemeType } from '@ohos_agcit/daily_schedule_common_lib';

@Entry
@Component
struct ThemeSelector {
  @State currentTheme: ThemeType = ThemeManager.instance.currentTheme;
  private themes: ThemeType[] = ThemeManager.instance.getAllThemes();

  build() {
    Column() {
      Text('选择主题')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      ForEach(this.themes, (theme: ThemeType) => {
        Row() {
          Text(ThemeManager.instance.getThemeDisplayName(theme))
            .fontSize(16)
          
          if (this.currentTheme === theme) {
            Text('✓')
              .fontSize(16)
              .fontColor('#4CAF50')
          }
        }
        .width('100%')
        .height(50)
        .onClick(() => {
          ThemeManager.instance.switchTheme(theme);
          this.currentTheme = theme;
        })
      })
    }
    .padding(20)
  }
}
```

## 主题颜色配置

每个主题包含以下颜色配置：

```typescript
interface ThemeColors {
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
```

### 默认主题颜色值

#### 绿色主题（默认）
```typescript
{
  primary: '#4CAF50',
  primaryLight: '#81C784',
  primaryDark: '#388E3C',
  accent: '#8BC34A',
  background: '#F1F8E9',
  cardBg: '#FFFFFF',
  text: '#212121',
  textSecondary: '#757575',
  divider: '#BDBDBD'
}
```

#### 蓝色主题
```typescript
{
  primary: '#2196F3',
  primaryLight: '#64B5F6',
  primaryDark: '#1976D2',
  accent: '#03A9F4',
  background: '#E3F2FD',
  cardBg: '#FFFFFF',
  text: '#212121',
  textSecondary: '#757575',
  divider: '#BDBDBD'
}
```

## 持久化存储

ThemeManager 自动将主题选择保存到 Preferences 中，应用重启后会自动加载上次选择的主题。

- 存储文件名: `theme_preferences`
- 存储键名: `current_theme`
- 默认主题: `ThemeType.GREEN`（绿色）

### 清除持久化数据

```typescript
// 清除主题持久化数据，恢复默认绿色主题
ThemeManager.instance.clearThemePreferences();
```

## 注意事项

1. **初始化时机**：必须在 EntryAbility 的 onCreate 方法中调用 `ThemeManager.instance.init(this.context)` 进行初始化。

2. **单例模式**：ThemeManager 使用单例模式，全局只有一个实例。

3. **自动持久化**：切换主题时会自动保存到 Preferences，无需手动调用保存方法。

4. **默认主题**：首次启动应用时，默认加载绿色主题。

5. **主题验证**：从持久化存储加载主题时，会自动验证主题值的有效性，无效值会被替换为默认绿色主题。

## API 参考

### ThemeManager

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `instance` | - | `ThemeManager` | 获取单例实例 |
| `init(context)` | `UIAbilityContext` | `void` | 初始化主题管理器 |
| `currentTheme` | - | `ThemeType` | 获取当前主题类型 |
| `currentColors` | - | `ThemeColors` | 获取当前主题颜色配置 |
| `switchTheme(theme)` | `ThemeType` | `void` | 切换主题 |
| `getThemeColors(theme)` | `ThemeType` | `ThemeColors` | 获取指定主题的颜色配置 |
| `getAllThemes()` | - | `ThemeType[]` | 获取所有可用主题列表 |
| `getThemeDisplayName(theme)` | `ThemeType` | `string` | 获取主题显示名称 |
| `clearThemePreferences()` | - | `void` | 清除持久化主题数据 |

### ThemeType 枚举

| 值 | 说明 |
|----|------|
| `GREEN` | 绿色主题（默认） |
| `BLUE` | 蓝色主题 |
| `ORANGE` | 橙色主题 |
| `PURPLE` | 紫色主题 |
| `CYAN` | 青色主题 |

### ThemeColors 接口

| 属性 | 类型 | 说明 |
|------|------|------|
| `primary` | `string` | 主色 |
| `primaryLight` | `string` | 主色浅色 |
| `primaryDark` | `string` | 主色深色 |
| `accent` | `string` | 强调色 |
| `background` | `string` | 背景色 |
| `cardBg` | `string` | 卡片背景色 |
| `text` | `string` | 文本色 |
| `textSecondary` | `string` | 次要文本色 |
| `divider` | `string` | 分割线颜色 |
