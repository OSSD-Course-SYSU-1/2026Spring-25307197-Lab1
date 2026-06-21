# TransferUtil 使用指南

TransferUtil 是一个用于实现待办事项跨设备发送功能的工具类,基于 HarmonyOS 分布式数据对象能力实现。

## 功能特性

- ✅ 单个待办事项跨设备发送
- ✅ 批量待办事项跨设备发送
- ✅ 接收其他设备发送的待办事项
- ✅ 传输进度和状态回调
- ✅ 自动序列化和反序列化

## 前置条件

### 1. 权限配置

在 `module.json5` 中已配置以下权限:

```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.DISTRIBUTED_DATASYNC",
      "reason": "$string:distributed_datasync_reason",
      "usedScene": {
        "abilities": ["EntryAbility"],
        "when": "inuse"
      }
    },
    {
      "name": "ohos.permission.GET_DISTRIBUTED_DEVICE_INFO",
      "reason": "$string:get_distributed_device_info_reason",
      "usedScene": {
        "abilities": ["EntryAbility"],
        "when": "inuse"
      }
    }
  ]
}
```

### 2. 设备要求

- 两台设备需登录同一华为账号
- 两台设备需开启 Wi-Fi 和蓝牙
- 两台设备需安装同一应用
- 建议两台设备接入同一局域网

## 使用方法

### 1. 初始化

```typescript
import { TransferUtil, transferUtil } from '@common/common_lib';
import { common } from '@kit.AbilityKit';

// 在 Ability 的 onCreate 或 aboutToAppear 中初始化
async function initTransfer(context: common.UIAbilityContext) {
  const bundleName = context.abilityInfo.bundleName;
  const success = await transferUtil.init(context, bundleName);
  if (success) {
    console.log('TransferUtil 初始化成功');
  }
}
```

### 2. 发送单个待办事项

```typescript
import { TodoItem } from '@common/component_lib';

// 创建待办事项
const todoItem = new TodoItem(
  'task_001',
  '完成项目报告',
  new Date(),
  0, // 不重复
  1, // 提醒
  2, // 高优先级
  false
);

// 发送到目标设备
const targetDeviceId = 'xxxxx'; // 从设备列表获取
transferUtil.sendTodoToDevice(todoItem, targetDeviceId, {
  onProgress: (state, progress) => {
    console.log(`传输进度: ${progress}%`);
  },
  onSuccess: (result) => {
    console.log('发送成功:', result.deviceId);
  },
  onFailed: (result) => {
    console.error('发送失败:', result.errorMsg);
  }
});
```

### 3. 批量发送待办事项

```typescript
const todoItems: TodoItem[] = [
  // ... 多个待办事项
];

transferUtil.sendBatchTodoToDevice(todoItems, targetDeviceId, {
  onSuccess: (result) => {
    console.log(`成功发送 ${todoItems.length} 个待办事项`);
  },
  onFailed: (result) => {
    console.error('批量发送失败:', result.errorMsg);
  }
});
```

### 4. 接收待办事项

```typescript
// 注册接收回调
transferUtil.registerReceiveCallback({
  onTodoReceived: (todoItem, fromDeviceId) => {
    console.log(`收到待办: ${todoItem.title}`);
    console.log(`来自设备: ${fromDeviceId}`);
    
    // 处理接收到的待办事项
    // 例如: 保存到本地数据库、更新UI等
    handleReceivedTodo(todoItem);
  },
  onBatchReceived: (todoItems, fromDeviceId) => {
    console.log(`收到 ${todoItems.length} 个待办事项`);
    
    // 批量处理
    todoItems.forEach(item => handleReceivedTodo(item));
  }
});
```

### 5. 设备发现与选择

```typescript
import { DeviceManagerUtil, deviceManagerUtil } from '@common/common_lib';

// 开始设备发现
deviceManagerUtil.startDiscovering({
  onDeviceFound: (device) => {
    console.log(`发现设备: ${device.deviceName}`);
    // 将设备添加到设备列表供用户选择
    addDeviceToList(device);
  },
  onDiscoverFailed: (errorCode) => {
    console.error('设备发现失败:', errorCode);
  }
});

// 获取可用设备列表
const devices = deviceManagerUtil.getAvailableDeviceListSync();
console.log(`可用设备数量: ${devices.length}`);
```

## 完整示例

### 发送端

```typescript
import { TransferUtil, DeviceManagerUtil, transferUtil, deviceManagerUtil } from '@common/common_lib';
import { TodoItem } from '@common/component_lib';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct SendTodoPage {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  
  async aboutToAppear() {
    // 初始化
    await transferUtil.init(this.context, this.context.abilityInfo.bundleName);
    await deviceManagerUtil.init(this.context.abilityInfo.bundleName);
    
    // 开始设备发现
    deviceManagerUtil.startDiscovering({
      onDeviceFound: (device) => {
        console.log('发现设备:', device.deviceName);
      }
    });
  }
  
  // 发送待办
  async sendTodo() {
    const todo = new TodoItem('001', '测试待办', new Date(), 0, 1, 2, false);
    const devices = deviceManagerUtil.getAvailableDeviceListSync();
    
    if (devices.length > 0) {
      await transferUtil.sendTodoToDevice(todo, devices[0].deviceId, {
        onSuccess: () => console.log('发送成功'),
        onFailed: (result) => console.error('发送失败:', result.errorMsg)
      });
    }
  }
  
  build() {
    Column() {
      Button('发送待办')
        .onClick(() => this.sendTodo())
    }
  }
}
```

### 接收端

```typescript
import { TransferUtil, transferUtil } from '@common/common_lib';
import { TodoItem } from '@common/component_lib';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct ReceiveTodoPage {
  @State receivedTodos: TodoItem[] = [];
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  
  async aboutToAppear() {
    // 初始化
    await transferUtil.init(this.context, this.context.abilityInfo.bundleName);
    
    // 注册接收回调
    transferUtil.registerReceiveCallback({
      onTodoReceived: (todo, fromDevice) => {
        console.log(`收到待办: ${todo.title}`);
        this.receivedTodos.push(todo);
      },
      onBatchReceived: (todos, fromDevice) => {
        console.log(`收到 ${todos.length} 个待办`);
        this.receivedTodos.push(...todos);
      }
    });
  }
  
  build() {
    Column() {
      List() {
        ForEach(this.receivedTodos, (todo: TodoItem) => {
          ListItem() {
            Text(todo.title)
          }
        })
      }
    }
  }
}
```

## API 说明

### TransferUtil

#### 方法

| 方法名 | 参数 | 返回值 | 说明 |
|--------|------|--------|------|
| `getInstance()` | 无 | `TransferUtil` | 获取单例实例 |
| `init(context, bundleName)` | `UIAbilityContext, string` | `Promise<boolean>` | 初始化工具 |
| `sendTodoToDevice(todoItem, deviceId, callback?)` | `TodoItem, string, TransferCallback?` | `Promise<TransferResult>` | 发送单个待办 |
| `sendBatchTodoToDevice(todoItems, deviceId, callback?)` | `TodoItem[], string, TransferCallback?` | `Promise<TransferResult>` | 批量发送待办 |
| `registerReceiveCallback(callback)` | `ReceiveCallback` | `void` | 注册接收回调 |
| `joinSession(sessionId)` | `string` | `boolean` | 加入分布式会话 |
| `leaveSession()` | 无 | `void` | 退出分布式会话 |
| `getTransferState()` | 无 | `TransferState` | 获取传输状态 |
| `getSessionId()` | 无 | `string` | 获取会话ID |
| `release()` | 无 | `void` | 释放资源 |

### 回调接口

#### TransferCallback

```typescript
interface TransferCallback {
  onProgress?: (state: TransferState, progress: number) => void;
  onSuccess?: (result: TransferResult) => void;
  onFailed?: (result: TransferResult) => void;
}
```

#### ReceiveCallback

```typescript
interface ReceiveCallback {
  onTodoReceived?: (todoItem: TodoItem, fromDeviceId: string) => void;
  onBatchReceived?: (todoItems: TodoItem[], fromDeviceId: string) => void;
}
```

## 注意事项

1. **初始化顺序**: 必须先调用 `init()` 方法初始化,才能使用其他功能
2. **设备发现**: 发送前需要先通过 DeviceManagerUtil 发现并选择目标设备
3. **资源释放**: 不使用时调用 `release()` 释放资源
4. **错误处理**: 建议所有操作都添加错误处理回调
5. **数据大小**: 单次传输数据不宜过大,建议单次批量不超过 100 条待办
6. **网络状态**: 确保设备网络状态良好,传输过程中网络中断会导致失败

## 常见问题

### Q: 发送失败怎么办?

A: 检查以下几点:
- 两台设备是否登录同一华为账号
- 两台设备是否开启 Wi-Fi 和蓝牙
- 目标设备是否在线
- 是否已申请分布式权限

### Q: 接收不到数据?

A: 确认:
- 接收端是否已调用 `registerReceiveCallback()`
- 两台设备是否在同一个分布式会话中
- 发送端是否成功调用 `sendTodoToDevice()`

### Q: 如何处理传输冲突?

A: TransferUtil 基于 HarmonyOS 分布式数据对象,系统会自动处理数据冲突,采用"最后写入胜出"策略。

## 技术原理

TransferUtil 基于 HarmonyOS 分布式数据对象 (distributedDataObject) 实现:

1. **序列化**: TodoItem 已实现 `rpc.Parcelable` 接口,支持自动序列化
2. **传输**: 通过分布式软总线在设备间传输数据
3. **同步**: 使用 sessionId 建立设备间的同步关系
4. **监听**: 通过 on('change') 和 on('status') 监听数据变化

## 相关文档

- [HarmonyOS 分布式数据对象开发指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/distributed-data-object-V5)
- [HarmonyOS 分布式设备管理开发指导](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/distributed-device-manager-V5)
