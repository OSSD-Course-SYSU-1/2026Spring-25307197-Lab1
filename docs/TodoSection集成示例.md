# TodoSection 集成甩出发送功能示例

## 修改步骤

### 1. 修改 TodoSection.ets

在 `TodoSection` 组件中导入并使用 `FlingTodoListItem`：

```typescript
// 在文件顶部添加导入
import { 
  CustomIcon, 
  TodoItem, 
  FlingTodoListItem  // 新增导入
} from '@ohos_agcit/daily_schedule_component_lib';
import { 
  DateUtils, 
  FormatUtil, 
  ThemeController,
  DeviceSelectDialogController  // 新增导入
} from '@ohos_agcit/daily_schedule_common_lib';

@ComponentV2
export struct TodoSection {
  // ... 现有代码 ...
  
  build() {
    Column() {
      // ... 标题部分保持不变 ...
      
      if (this.isExpand) {
        List({ scroller: this.controller, space: 12 }) {
          ForEach(this.todoItems, (item: TodoItem, index: number) => {
            ListItem() {
              // 使用 FlingTodoListItem 包装原有的待办卡片
              FlingTodoListItem({
                todoItem: item,
                onFlingSuccess: () => {
                  // 发送成功后的处理
                  console.info(`待办 ${item.title} 已发送`);
                },
                content: () => {
                  // 原有的待办卡片UI
                  this.todoCardContent(item);
                }
              });
            }
            .transition(TransitionEffect.OPACITY
              .combine(TransitionEffect.translate({ x: 0, y: 100 }))
              .animation({ curve: curves.springMotion(), delay: 30 * index }))
            .swipeAction({
              end: {
                builder: leftSwipeButtonBuilder(() => {
                  this.onDelete(item.taskID)
                }, () => {
                  this.onModify(item.taskID)
                })
              }
            })
          }, (item: TodoItem, index: number) => item.taskID)
          .onMove((from: number, to: number) => {
            let tmp = this.todoItems.splice(from, 1);
            this.todoItems.splice(to, 0, tmp[0]);
            this.dataManager.onAllTasksChange();
          })
        }
        .width('100%')
      }
    }
    // ... 其他代码保持不变 ...
  }
  
  /**
   * 提取待办卡片内容为单独的Builder
   */
  @Builder
  todoCardContent(item: TodoItem) {
    Row() {
      Column() {
        Checkbox()
          .select(item.isFinished)
          .unselectedColor(this.chooseCheckBoxColor(item))
          .selectedColor($r('sys.color.icon_tertiary'))
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .mark({
            strokeColor: $r('sys.color.comp_background_primary_contrary'),
          })
          .onChange((value: boolean) => {
            this.dataManager.updateTaskFinish(item.taskID, value)
          })
          .margin({ top: 11 })
      }
      .height('100%')
      .justifyContent(FlexAlign.Start)

      Column() {
        Text(item.title.length > this.maxLen ? item.title.substring(0, this.maxLen) + '...' : item.title)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(this.chooseTitleColor(item))
          .maxLines(1)
        Blank().height(12)
        Text(FormatUtil.formatDate(item.planTime, FormatUtil.DATE_YYYY_MM_DD_24H_mm))
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.choosePlainTimeColor(item))
      }
      .margin({ left: 6, top: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .padding({ left: 14, right: 14 })
    .height(76)
    .width('100%')
    .backgroundColor(this.themeController.currentColorMode ===
    ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? $r('sys.color.background_tertiary') :
    $r('sys.color.background_primary'))
    .borderRadius(16)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }
  
  // ... 其他方法保持不变 ...
}
```

### 2. 在 EntryAbility 中初始化

```typescript
// EntryAbility.ets
import { DeviceManagerUtil, TransferUtil } from '@ohos_agcit/daily_schedule_common_lib';
import { TodoItem } from '@ohos_agcit/daily_schedule_component_lib';
import { TodoDataManager } from './mock/TodoDataManager';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 初始化设备管理器
    const deviceManager = DeviceManagerUtil.getInstance();
    await deviceManager.init(this.context.applicationInfo.name);
    
    // 初始化传输工具
    const transferUtil = TransferUtil.getInstance();
    await transferUtil.init(this.context, this.context.applicationInfo.name);
    
    // 注册接收回调
    transferUtil.registerReceiveCallback({
      onTodoReceived: (todo: TodoItem, fromDeviceId: string) => {
        console.info(`收到待办: ${todo.title}`);
        // 添加到本地数据管理器
        TodoDataManager.instance.addTask(todo);
      }
    });
  }
  
  onDestroy() {
    TransferUtil.getInstance().release();
    DeviceManagerUtil.getInstance().release();
  }
}
```

### 3. 配置权限

在 `module.json5` 中添加：

```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.DISTRIBUTED_DATASYNC",
        "reason": "用于跨设备同步待办事项",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

## 关键改动说明

### 1. 导入新组件
```typescript
import { FlingTodoListItem } from '@ohos_agcit/daily_schedule_component_lib';
import { DeviceSelectDialogController } from '@ohos_agcit/daily_schedule_common_lib';
```

### 2. 包装待办卡片
将原有的待办卡片UI提取为 `@Builder` 方法，然后用 `FlingTodoListItem` 包装：

```typescript
// 原来的代码
ListItem() {
  Row() {
    // 待办卡片UI
  }
}

// 修改后的代码
ListItem() {
  FlingTodoListItem({
    todoItem: item,
    onFlingSuccess: () => {
      // 成功回调
    },
    content: () => {
      this.todoCardContent(item);  // 原有的UI
    }
  });
}
```

### 3. 提取UI为Builder
```typescript
@Builder
todoCardContent(item: TodoItem) {
  Row() {
    // 原有的待办卡片UI代码
  }
}
```

## 完整修改示例

### 修改前
```typescript
ForEach(this.todoItems, (item: TodoItem, index: number) => {
  ListItem() {
    Row() {
      // 完整的待办卡片UI
      Column() {
        Checkbox()...
      }
      Column() {
        Text(item.title)...
      }
    }
  }
})
```

### 修改后
```typescript
ForEach(this.todoItems, (item: TodoItem, index: number) => {
  ListItem() {
    FlingTodoListItem({
      todoItem: item,
      onFlingSuccess: () => {
        console.info(`待办已发送: ${item.title}`);
      },
      content: () => {
        this.todoCardContent(item);
      }
    });
  }
})

@Builder
todoCardContent(item: TodoItem) {
  Row() {
    // 完整的待办卡片UI（从原位置移过来）
    Column() {
      Checkbox()...
    }
    Column() {
      Text(item.title)...
    }
  }
}
```

## 测试步骤

1. **编译运行**：确保代码编译通过并运行
2. **测试甩出手势**：
   - 长按待办卡片
   - 快速甩出（任意方向）
   - 应该弹出设备选择对话框
3. **测试设备发现**：
   - 确保其他设备已登录同一账号
   - 设备列表应显示可用设备
4. **测试发送功能**：
   - 选择目标设备
   - 点击发送
   - 检查目标设备是否收到待办

## 常见问题

### Q: 甩出不触发设备选择对话框？
A: 检查以下几点：
- 确保已初始化 DeviceManagerUtil 和 TransferUtil
- 检查甩动速度是否达到阈值（默认18像素/帧）
- 查看日志输出是否有错误信息

### Q: 设备列表为空？
A: 检查以下几点：
- 确保其他设备已登录同一华为账号
- 检查网络连接状态
- 确保配置了分布式权限

### Q: 发送失败？
A: 检查以下几点：
- 目标设备是否在线
- 查看日志输出的错误信息
- 检查数据格式是否正确

## 性能优化建议

1. **懒加载设备列表**：只在甩出时才加载设备列表
2. **缓存设备信息**：避免频繁查询设备列表
3. **优化动画性能**：使用硬件加速动画
4. **合理设置阈值**：根据实际使用调整甩动阈值

## 扩展功能

### 自定义甩出处理
```typescript
FlingTodoListItem({
  todoItem: item,
  onFlingSuccess: () => {
    // 自定义成功处理
    this.showSuccessToast();
    this.refreshList();
  },
  content: () => {
    this.todoCardContent(item);
  }
});
```

### 批量发送
```typescript
// 可以扩展支持批量发送多个待办
const selectedItems = this.getSelectedItems();
transferUtil.sendBatchTodoToDevice(selectedItems, targetDeviceId);
```

## 总结

通过简单的包装，就可以为现有的待办列表添加甩出发送功能，无需大幅修改现有代码结构。核心是：
1. 导入新组件
2. 用 FlingTodoListItem 包装现有UI
3. 初始化传输工具
4. 配置必要权限
