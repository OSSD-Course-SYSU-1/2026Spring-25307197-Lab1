# 待办事项甩出发送功能

## 📱 功能介绍

通过甩动手势将待办事项发送到其他设备，实现跨设备协作。

### 核心特性

- ✅ **手势识别**：支持四方向甩出（上、下、左、右）
- ✅ **设备发现**：自动发现同账号下的可用设备
- ✅ **一键发送**：选择设备后自动发送待办
- ✅ **实时接收**：目标设备实时接收并显示
- ✅ **视觉反馈**：流畅的动画和交互效果

## 🚀 快速开始

### 1分钟集成

```typescript
// 1. 导入组件
import { FlingTodoListItem } from '@ohos_agcit/daily_schedule_component_lib';

// 2. 包装待办卡片
FlingTodoListItem({
  todoItem: item,
  onFlingSuccess: () => console.info('发送成功'),
  content: () => {
    // 你的待办卡片UI
  }
});

// 3. 初始化（在EntryAbility中）
const transferUtil = TransferUtil.getInstance();
await transferUtil.init(context, bundleName);
```

详见：[快速开始指南](./快速开始.md)

## 📚 文档

| 文档 | 说明 |
|------|------|
| [快速开始](./快速开始.md) | 1分钟快速集成指南 |
| [使用指南](./甩出发送待办使用指南.md) | 完整功能文档和API说明 |
| [集成示例](./TodoSection集成示例.md) | TodoSection组件集成示例 |

## 🎯 使用流程

```
1. 长按待办卡片
   ↓
2. 快速甩出（任意方向）
   ↓
3. 自动弹出设备选择对话框
   ↓
4. 选择目标设备
   ↓
5. 点击发送
   ↓
6. 待办自动发送到目标设备
```

## 🏗️ 架构说明

### 核心组件

```
┌─────────────────────────────────────┐
│         用户界面层                   │
│  FlingTodoListItem / FlingTodoCard  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         手势检测层                   │
│        FlingDetector                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         设备选择层                   │
│      DeviceSelectDialog             │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         传输控制层                   │
│        TransferUtil                 │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         设备管理层                   │
│     DeviceManagerUtil               │
└─────────────────────────────────────┘
```

### 数据流

```
发送端:
待办数据 → 甩出检测 → 设备选择 → 数据序列化 → 分布式传输

接收端:
分布式接收 → 数据反序列化 → 待办处理 → UI更新
```

## 🔧 配置要求

### 权限配置

在 `module.json5` 中添加：

```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.DISTRIBUTED_DATASYNC",
      "reason": "跨设备同步待办事项"
    }
  ]
}
```

### 环境要求

- HarmonyOS API 10+
- 同一华为账号
- 同一局域网或分布式连接

## 📦 组件API

### FlingTodoListItem

可甩出的待办列表项组件。

**参数：**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| content | BuilderParam | 是 | - | 子组件内容 |
| todoItem | TodoItem | 是 | null | 待办数据 |
| onFlingSuccess | () => void | 否 | () => {} | 发送成功回调 |

**示例：**

```typescript
FlingTodoListItem({
  todoItem: myTodoItem,
  onFlingSuccess: () => {
    console.info('发送成功');
    this.refreshList();
  },
  content: () => {
    // 你的待办卡片UI
    this.myTodoCard(myTodoItem);
  }
});
```

### FlingTodoCard

可甩出的待办卡片组件。

**参数：** 同 FlingTodoListItem

### DeviceSelectDialog

设备选择对话框组件（内部使用，通常不需要直接调用）。

## 🎨 自定义配置

### 调整甩动阈值

修改 `FlingTodoCard.ets` 中的参数：

```typescript
// 最小速度阈值（像素/帧）
private readonly MIN_VELOCITY = 18;

// 最小距离阈值（像素）
private readonly MIN_DISTANCE = 80;
```

### 自定义设备图标

在 `DeviceSelectDialog.ets` 中修改：

```typescript
private getDeviceIcon(deviceType: string): Resource {
  // 自定义设备图标映射
  switch (deviceType) {
    case '0': return $r('sys.symbol.device_phone');
    // ...
  }
}
```

## 🧪 测试指南

### 单元测试

```typescript
// 测试甩动检测
describe('FlingDetector', () => {
  it('should detect fling gesture', () => {
    // 模拟甩动手势
    // 验证回调触发
  });
});
```

### 集成测试

1. **设备发现测试**
   - 启动多个设备
   - 验证设备列表显示

2. **发送接收测试**
   - 甩出发送待办
   - 验证目标设备接收

3. **边界测试**
   - 无设备时的提示
   - 网络异常处理

## 🐛 故障排查

### 常见问题

<details>
<summary><b>Q1: 无法发现设备</b></summary>

**检查项：**
- [ ] 设备是否登录同一华为账号
- [ ] 设备是否在同一局域网
- [ ] 是否配置分布式权限
- [ ] 设备管理器是否初始化成功

**解决方案：**
```typescript
// 检查初始化状态
const deviceManager = DeviceManagerUtil.getInstance();
const isInit = await deviceManager.init(bundleName);
console.info('DeviceManager initialized:', isInit);
```
</details>

<details>
<summary><b>Q2: 甩出不触发</b></summary>

**检查项：**
- [ ] 甩动速度是否足够快
- [ ] 甩动距离是否足够长
- [ ] 手势是否被其他组件拦截
- [ ] FlingTodoListItem是否正确包装

**解决方案：**
```typescript
// 降低阈值（在FlingTodoCard.ets中）
private readonly MIN_VELOCITY = 15;  // 从18降到15
private readonly MIN_DISTANCE = 60;  // 从80降到60
```
</details>

<details>
<summary><b>Q3: 发送失败</b></summary>

**检查项：**
- [ ] 目标设备是否在线
- [ ] 数据格式是否正确
- [ ] 网络连接是否正常
- [ ] 查看错误日志

**解决方案：**
```typescript
// 添加错误处理
transferUtil.sendTodoToDevice(todo, deviceId, {
  onSuccess: (result) => {
    console.info('发送成功');
  },
  onFailed: (result) => {
    console.error('发送失败:', result.errorMsg);
    // 显示错误提示
  }
});
```
</details>

## 📊 性能优化

### 优化建议

1. **懒加载设备列表**
   ```typescript
   // 只在甩出时才加载设备
   if (!this.deviceListLoaded) {
     await this.loadDevices();
   }
   ```

2. **缓存设备信息**
   ```typescript
   // 缓存设备列表，避免频繁查询
   private deviceCache: DeviceInfo[] = [];
   private cacheTime: number = 0;
   
   async getDevices() {
     if (Date.now() - this.cacheTime < 30000) {
       return this.deviceCache;
     }
     // 重新加载
   }
   ```

3. **优化动画性能**
   ```typescript
   // 使用硬件加速
   .animation({
     curve: Curve.FastOutSlowIn,
     delay: 0
   })
   ```

## 🔐 安全考虑

### 数据安全

- 数据传输使用分布式数据对象，由系统加密传输
- 不传输敏感信息（如密码、支付信息）
- 设备认证由系统层面保证

### 权限控制

- 最小权限原则：只申请必要权限
- 运行时权限：在使用时才申请
- 权限说明：向用户说明权限用途

## 📈 后续规划

- [ ] 支持批量发送多个待办
- [ ] 支持发送待办分组
- [ ] 支持发送历史记录
- [ ] 支持撤回发送
- [ ] 支持发送状态跟踪
- [ ] 支持离线发送队列

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 开发环境

- DevEco Studio 4.0+
- HarmonyOS SDK API 10+
- Node.js 14+

### 代码规范

- 遵循 ArkTS 编码规范
- 添加必要的注释
- 编写单元测试

## 📄 许可证

本项目采用 Apache 2.0 许可证。

## 📞 联系方式

- 📧 Email: support@example.com
- 💬 Issue: [提交Issue](../../issues)
- 📖 Wiki: [查看Wiki](../../wiki)

---

**Made with ❤️ by HarmonyOS Team**
