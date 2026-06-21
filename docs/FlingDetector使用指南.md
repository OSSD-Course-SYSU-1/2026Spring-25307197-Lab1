# FlingDetector 甩动手势检测器使用指南

## 功能概述

`FlingDetector` 组件用于监听拖拽手势的甩动方向和速度，当用户快速向外甩出时触发相应事件。适用于：
- 卡片式界面的快速操作（如Tinder风格的左右滑动）
- 列表项的快速删除/归档
- 手势导航控制
- 游戏控制界面

## 组件说明

### 1. FlingDetector（基础检测器）

基础甩动手势检测器，提供完整的甩动事件信息。

#### 参数配置

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `minFlingVelocity` | number | 15 | 触发甩出事件的最小速度阈值（像素/帧） |
| `minFlingDistance` | number | 100 | 触发甩出事件的最小距离阈值（像素） |
| `direction` | PanDirection | PanDirection.All | 允许的拖拽方向 |
| `longPressDuration` | number | 0 | 长按触发时间（毫秒），0表示不需要长按 |
| `onFling` | (event: FlingEvent) => void | - | 甩出事件回调 |
| `onDragStart` | () => void | - | 拖拽开始回调 |
| `onDragUpdate` | (offsetX, offsetY) => void | - | 拖拽更新回调 |
| `onDragEnd` | () => void | - | 拖拽结束回调（未触发甩出时） |

#### FlingEvent 事件信息

```typescript
interface FlingEvent {
  direction: FlingDirection;    // 甩动方向
  velocity: number;             // 总速度 (像素/帧)
  velocityX: number;            // X方向速度
  velocityY: number;            // Y方向速度
  offsetX: number;              // X方向偏移
  offsetY: number;              // Y方向偏移
  duration: number;             // 拖拽持续时间 (毫秒)
}
```

#### 甩动方向枚举

```typescript
enum FlingDirection {
  NONE = 0,      // 无方向
  UP = 1,        // 向上甩出
  DOWN = 2,      // 向下甩出
  LEFT = 3,      // 向左甩出
  RIGHT = 4      // 向右甩出
}
```

### 2. FlingCard（可甩出的卡片）

带有动画效果的可甩出卡片组件，适合卡片式UI场景。

#### 参数配置

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `minFlingVelocity` | number | 18 | 触发甩出的最小速度阈值 |
| `flingDuration` | number | 300 | 甩出动画持续时间（毫秒） |
| `onFlingUp` | () => void | - | 向上甩出回调 |
| `onFlingDown` | () => void | - | 向下甩出回调 |
| `onFlingLeft` | () => void | - | 向左甩出回调 |
| `onFlingRight` | () => void | - | 向右甩出回调 |

## 使用示例

### 示例1: 基础甩动检测

```typescript
import { FlingDetector, FlingDirection, FlingEvent } from '../commons/component_lib/Index';

FlingDetector({
  minFlingVelocity: 15,
  minFlingDistance: 100,
  direction: PanDirection.All,
  onFling: (event: FlingEvent) => {
    console.log(`甩动方向: ${event.direction}`);
    console.log(`甩动速度: ${event.velocity}`);
    
    // 根据方向执行不同操作
    switch (event.direction) {
      case FlingDirection.LEFT:
        // 处理向左甩出
        break;
      case FlingDirection.RIGHT:
        // 处理向右甩出
        break;
      // ...
    }
  },
  onDragStart: () => {
    console.log('开始拖拽');
  },
  onDragUpdate: (offsetX, offsetY) => {
    // 实时获取拖拽偏移
  },
  onDragEnd: () => {
    console.log('拖拽结束');
  }
}) {
  // 你的内容组件
  Text('拖拽我')
    .width(200)
    .height(100)
}
```

### 示例2: Tinder风格卡片

```typescript
import { FlingCard } from '../commons/component_lib/Index';

FlingCard({
  minFlingVelocity: 20,
  flingDuration: 250,
  onFlingLeft: () => {
    // 拒绝操作
    this.rejectCard();
  },
  onFlingRight: () => {
    // 接受操作
    this.acceptCard();
  }
}) {
  Column() {
    Text('用户名')
    Text('个人简介')
  }
}
.width(300)
.height(400)
```

### 示例3: 仅支持水平甩动

```typescript
FlingDetector({
  direction: PanDirection.Horizontal, // 仅水平方向
  minFlingVelocity: 18,
  onFling: (event: FlingEvent) => {
    if (event.direction === FlingDirection.LEFT) {
      // 上一页
    } else if (event.direction === FlingDirection.RIGHT) {
      // 下一页
    }
  }
}) {
  // 内容
}
```

### 示例4: 长按后才能拖拽

```typescript
FlingDetector({
  longPressDuration: 500, // 长按500ms后才能拖拽
  onFling: (event: FlingEvent) => {
    // 处理甩出
  }
}) {
  // 内容
}
```

## 技术原理

### 速度计算

组件通过以下方式计算甩动速度：

1. **瞬时速度计算**：每次拖拽移动时计算瞬时速度
   ```
   instantVelocity = (currentOffset - lastOffset) / deltaTime * 16.67
   ```
   （假设60fps，每帧约16.67ms）

2. **速度平滑**：使用滑动窗口（默认5帧）计算平均速度，避免抖动

3. **总速度计算**：
   ```
   totalVelocity = √(velocityX² + velocityY²)
   ```

### 触发条件

甩出事件需要同时满足：
- `totalVelocity >= minFlingVelocity` （速度足够快）
- `totalOffset >= minFlingDistance` （距离足够远）

### 方向判定

根据速度分量判断主要方向：
- 如果 `|velocityX| > |velocityY|`，判定为水平方向
- 否则判定为垂直方向

## 最佳实践

### 1. 合理设置阈值

```typescript
// 敏感配置（容易触发）
FlingDetector({
  minFlingVelocity: 10,
  minFlingDistance: 50
})

// 保守配置（不易触发）
FlingDetector({
  minFlingVelocity: 25,
  minFlingDistance: 150
})
```

### 2. 提供视觉反馈

```typescript
@Local isDragging: boolean = false;

FlingDetector({
  onDragStart: () => {
    this.isDragging = true;
  },
  onDragEnd: () => {
    this.isDragging = false;
  }
}) {
  Text('内容')
    .scale(this.isDragging ? 1.1 : 1)  // 拖拽时放大
    .opacity(this.isDragging ? 0.8 : 1) // 拖拽时半透明
}
```

### 3. 结合动画效果

```typescript
FlingCard({
  flingDuration: 200, // 快速甩出
  onFlingLeft: () => {
    animateTo({ duration: 300 }, () => {
      // 执行删除动画
    });
  }
})
```

### 4. 防止误触

```typescript
// 使用长按模式防止误触
FlingDetector({
  longPressDuration: 300, // 长按300ms后才能拖拽
  minFlingVelocity: 20    // 提高速度阈值
})
```

## 常见问题

### Q: 为什么甩动不触发？

A: 检查以下配置：
1. `minFlingVelocity` 是否设置过高
2. `minFlingDistance` 是否设置过大
3. 拖拽速度是否足够快

### Q: 如何只响应特定方向？

A: 使用 `direction` 参数：
```typescript
// 仅垂直方向
FlingDetector({ direction: PanDirection.Vertical })

// 仅水平方向
FlingDetector({ direction: PanDirection.Horizontal })
```

### Q: 如何获取更精确的速度信息？

A: 使用 `FlingEvent` 的详细信息：
```typescript
onFling: (event: FlingEvent) => {
  console.log('X速度:', event.velocityX);
  console.log('Y速度:', event.velocityY);
  console.log('总速度:', event.velocity);
  console.log('持续时间:', event.duration);
}
```

## 性能优化

1. **避免频繁更新**：在 `onDragUpdate` 中避免执行耗时操作
2. **合理设置历史窗口大小**：默认5帧，可根据需要调整
3. **及时清理资源**：在组件销毁时重置状态

## 相关组件

- `DraggableList` - 可拖拽排序列表
- `DraggableTodoList` - 可拖拽待办列表
- `TodoCard` - 待办卡片组件
