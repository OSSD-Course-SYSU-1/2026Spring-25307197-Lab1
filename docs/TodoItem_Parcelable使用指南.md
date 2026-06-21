# TodoItem Parcelable 序列化使用指南

## 概述

`TodoItem` 类已实现 `rpc.Parcelable` 接口，支持跨设备数据传输。本指南介绍如何使用该功能进行数据序列化和跨设备传输。

## 实现说明

### 核心接口

TodoItem 实现了以下 Parcelable 接口方法：

- `marshalling(messageSequence: rpc.MessageSequence): boolean` - 序列化方法
- `unmarshalling(messageSequence: rpc.MessageSequence): boolean` - 反序列化方法

### 数据类型映射

| 属性 | 类型 | 序列化方法 | 反序列化方法 |
|------|------|-----------|-------------|
| taskID | string | writeString() | readString() |
| title | string | writeString() | readString() |
| planTime | Date | writeLong(getTime()) | new Date(readLong()) |
| repetitionType | number | writeInt() | readInt() |
| reminderType | number | writeInt() | readInt() |
| priorityType | number | writeInt() | readInt() |
| isFinished | boolean | writeBoolean() | readBoolean() |

## 使用示例

### 1. 基本序列化和反序列化

```typescript
import rpc from '@ohos.rpc';
import { TodoItem } from '@ohos_agcit/daily_schedule_component_lib';

// 创建待办事项
const todo = new TodoItem(
  'task_001',
  '完成项目报告',
  new Date('2024-12-31'),
  1, // repetitionType
  2, // reminderType
  3, // priority
  false
);

// 序列化
const data = rpc.MessageSequence.create();
const result = data.writeParcelable(todo);
console.info('序列化结果:', result);

// 反序列化
const restoredTodo = new TodoItem('', '', new Date(), 0, 0, 0, false);
data.readParcelable(restoredTodo);
console.info('反序列化后的标题:', restoredTodo.title);
```

### 2. 跨设备数据传输（使用 Caller/Callee）

#### 发送方（Caller）

```typescript
import { common } from '@kit.AbilityKit';
import rpc from '@ohos.rpc';

async function sendTodoToDevice(context: common.UIAbilityContext, todo: TodoItem) {
  try {
    // 获取目标设备的 Caller 对象
    const caller = await context.startAbilityByCall({
      bundleName: 'com.example.todoapp',
      abilityName: 'TodoReceiverAbility',
      deviceId: 'target_device_id' // 目标设备ID
    });

    // 发送待办事项数据
    await caller.call('receive_todo', todo);
    console.info('待办事项发送成功');
  } catch (error) {
    console.error('发送失败:', JSON.stringify(error));
  }
}
```

#### 接收方（Callee）

```typescript
import UIAbility from '@ohos.app.ability.UIAbility';
import rpc from '@ohos.rpc';

const RECEIVE_TODO_METHOD = 'receive_todo';

function receiveTodoCallback(data: rpc.MessageSequence): rpc.Parcelable {
  // 从序列化数据中读取待办事项
  const receivedTodo = new TodoItem('', '', new Date(), 0, 0, 0, false);
  data.readParcelable(receivedTodo);
  
  console.info('收到待办事项:', receivedTodo.title);
  
  // 处理待办事项（保存到数据库等）
  // saveTodoToDatabase(receivedTodo);
  
  // 返回确认结果
  const response = new TodoItem('', '', new Date(), 0, 0, 0, false);
  response.taskID = receivedTodo.taskID;
  response.title = '已接收';
  return response;
}

export default class TodoReceiverAbility extends UIAbility {
  onCreate(want, launchParam) {
    // 注册接收回调
    try {
      this.callee.on(RECEIVE_TODO_METHOD, receiveTodoCallback);
      console.info('待办事项接收监听注册成功');
    } catch (error) {
      console.error('注册监听失败:', JSON.stringify(error));
    }
  }

  onDestroy() {
    // 取消注册
    try {
      this.callee.off(RECEIVE_TODO_METHOD);
    } catch (error) {
      console.error('取消监听失败:', JSON.stringify(error));
    }
  }
}
```

### 3. 批量数据传输

```typescript
import rpc from '@ohos.rpc';

// 序列化待办事项数组
function serializeTodoList(todoList: TodoItem[]): rpc.MessageSequence {
  const data = rpc.MessageSequence.create();
  data.writeInt(todoList.length); // 写入数量
  
  for (const todo of todoList) {
    data.writeParcelable(todo);
  }
  
  return data;
}

// 反序列化待办事项数组
function deserializeTodoList(data: rpc.MessageSequence): TodoItem[] {
  const count = data.readInt(); // 读取数量
  const todoList: TodoItem[] = [];
  
  for (let i = 0; i < count; i++) {
    const todo = new TodoItem('', '', new Date(), 0, 0, 0, false);
    data.readParcelable(todo);
    todoList.push(todo);
  }
  
  return todoList;
}
```

### 4. 结合分布式数据管理

```typescript
import distributedObject from '@ohos.data.distributedObject';

// 创建分布式数据对象
const sessionId = 'todo_session_' + Date.now();
const distributedTodo = distributedObject.createDistributedObject(sessionId, {
  taskID: '',
  title: '',
  planTime: 0,
  repetitionType: 0,
  reminderType: 0,
  priorityType: 0,
  isFinished: false
});

// 将 TodoItem 同步到分布式对象
function syncTodoToDistributed(todo: TodoItem) {
  distributedTodo.taskID = todo.taskID;
  distributedTodo.title = todo.title;
  distributedTodo.planTime = todo.planTime.getTime();
  distributedTodo.repetitionType = todo.repetitionType;
  distributedTodo.reminderType = todo.reminderType;
  distributedTodo.priorityType = todo.priorityType;
  distributedTodo.isFinished = todo.isFinished;
}

// 监听分布式对象变化
distributedTodo.on('change', (sessionId, fields) => {
  console.info('分布式数据变化:', fields);
  // 从分布式对象恢复 TodoItem
  const syncedTodo = new TodoItem(
    distributedTodo.taskID,
    distributedTodo.title,
    new Date(distributedTodo.planTime),
    distributedTodo.repetitionType,
    distributedTodo.reminderType,
    distributedTodo.priorityType,
    distributedTodo.isFinished
  );
  console.info('同步的待办事项:', syncedTodo.title);
});
```

## 最佳实践

### 1. 错误处理

```typescript
import rpc from '@ohos.rpc';

function safeSerializeTodo(todo: TodoItem): rpc.MessageSequence | null {
  try {
    const data = rpc.MessageSequence.create();
    const result = data.writeParcelable(todo);
    if (result) {
      return data;
    } else {
      console.error('序列化失败');
      return null;
    }
  } catch (error) {
    console.error('序列化异常:', JSON.stringify(error));
    return null;
  }
}

function safeDeserializeTodo(data: rpc.MessageSequence): TodoItem | null {
  try {
    const todo = new TodoItem('', '', new Date(), 0, 0, 0, false);
    const result = data.readParcelable(todo);
    if (result) {
      return todo;
    } else {
      console.error('反序列化失败');
      return null;
    }
  } catch (error) {
    console.error('反序列化异常:', JSON.stringify(error));
    return null;
  }
}
```

### 2. 性能优化

- **批量传输**: 多个待办事项应合并为一个消息发送，减少通信次数
- **数据压缩**: 对于大量数据，可考虑压缩后再传输
- **异步处理**: 序列化和网络传输应在子线程执行，避免阻塞UI

### 3. 数据验证

```typescript
function validateTodoItem(todo: TodoItem): boolean {
  if (!todo.taskID || todo.taskID.trim() === '') {
    console.error('taskID 不能为空');
    return false;
  }
  
  if (!todo.title || todo.title.trim() === '') {
    console.error('title 不能为空');
    return false;
  }
  
  if (!(todo.planTime instanceof Date) || isNaN(todo.planTime.getTime())) {
    console.error('planTime 不是有效的日期');
    return false;
  }
  
  return true;
}

// 在序列化前验证
function serializeWithValidation(todo: TodoItem): rpc.MessageSequence | null {
  if (!validateTodoItem(todo)) {
    return null;
  }
  return safeSerializeTodo(todo);
}
```

### 4. 版本兼容性

为支持未来的数据结构变更，可添加版本号：

```typescript
export class TodoItemV2 implements rpc.Parcelable {
  // 添加版本号
  private version: number = 2;
  
  // 原有属性...
  taskID: string = '';
  title: string = '';
  // ...
  
  // 新增属性
  tags: string[] = [];
  
  marshalling(messageSequence: rpc.MessageSequence): boolean {
    messageSequence.writeInt(this.version);
    messageSequence.writeString(this.taskID);
    messageSequence.writeString(this.title);
    // ... 其他属性
    messageSequence.writeStringArray(this.tags); // 新增属性
    return true;
  }
  
  unmarshalling(messageSequence: rpc.MessageSequence): boolean {
    const version = messageSequence.readInt();
    this.taskID = messageSequence.readString();
    this.title = messageSequence.readString();
    // ... 其他属性
    
    // 根据版本号处理新增属性
    if (version >= 2) {
      this.tags = messageSequence.readStringArray();
    }
    
    return true;
  }
}
```

## 注意事项

1. **Date 类型处理**: Date 对象在序列化时会转换为时间戳（long），反序列化时重新构造 Date 对象
2. **空值处理**: 确保所有属性都有有效值，避免 null 或 undefined
3. **内存管理**: 使用完 MessageSequence 后，系统会自动回收资源
4. **线程安全**: 序列化操作应在同一线程中完成，避免多线程并发访问
5. **数据大小**: MessageSequence 默认容量为 200KB，大数据需调整容量

## 相关文档

- [HarmonyOS RPC 开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/rpc-development-V5)
- [分布式数据管理](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/distributed-data-service-V5)
- [跨设备通信](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/cross-device-communication-V5)
