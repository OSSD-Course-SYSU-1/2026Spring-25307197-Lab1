/**
 * 甩出发送动画效果使用说明
 * 
 * 本文档介绍如何使用增强的甩出发送动画效果，提升用户体验。
 */

// ============================================
// 1. 基础用法 - 使用 FlingTodoListItem
// ============================================

import { FlingTodoListItem } from '@ohos_agcit/daily_schedule_component_lib';
import { TodoItem } from '@ohos_agcit/daily_schedule_common_lib';

@ComponentV2
struct BasicUsage {
  @Local todoItems: TodoItem[] = [
    new TodoItem('1', '完成项目报告', new Date(), 0, 0, 2, false),
    new TodoItem('2', '参加会议', new Date(), 0, 0, 1, false),
  ];

  build() {
    List({ space: 12 }) {
      ForEach(this.todoItems, (item: TodoItem) => {
        ListItem() {
          // 使用 FlingTodoListItem 包装待办卡片
          FlingTodoListItem({
            todoItem: item,
            onFlingSuccess: () => {
              console.info(`待办 ${item.title} 发送成功`);
            },
            content: () => {
              // 原始的待办卡片内容
              this.TodoCardBuilder(item);
            }
          });
        }
      }, (item: TodoItem) => item.taskID)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TodoCardBuilder(item: TodoItem) {
    Row() {
      Text(item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(80)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}

// ============================================
// 2. 动画效果说明
// ============================================

/**
 * FlingTodoListItem 自动包含以下动画效果：
 * 
 * 【拖拽阶段】
 * - 卡片轻微放大 (1.02倍)
 * - 绿色光晕阴影，强度随速度变化
 * - 方向指示器显示甩出方向
 * - 速度可视化（颜色变化）：
 *   - 灰色: 速度 < 10 (不够甩出)
 *   - 橙色: 速度 10-18 (接近甩出)
 *   - 绿色: 速度 >= 18 (可以甩出)
 * 
 * 【甩出阶段】
 * - 粒子扩散效果（20个粒子向外扩散）
 * - 卡片沿甩出方向飞出
 * - 透明度渐变消失
 * - 缩放动画
 * 
 * 【发送阶段】
 * - 显示设备选择对话框
 * - 发送状态提示
 * 
 * 【成功阶段】
 * - 成功图标动画（✓）
 * - 涟漪扩散效果
 * - 震动反馈（如果设备支持）
 */

// ============================================
// 3. 自定义动画效果
// ============================================

import { 
  FlingAnimationEffects, 
  DragDirectionIndicator, 
  SendStatusAnimation 
} from '@ohos_agcit/daily_schedule_component_lib';

@ComponentV2
struct CustomAnimationExample {
  @Local showParticle: boolean = false;
  @Local showGlow: boolean = false;
  @Local showSuccess: boolean = false;
  @Local progress: number = 0;

  build() {
    Stack() {
      // 你的内容
      Column() {
        Text('自定义动画示例')
          .fontSize(20)
      }
      .width('100%')
      .height('100%')
      
      // 粒子效果
      FlingAnimationEffects({
        isVisible: this.showParticle,
        centerX: 200,
        centerY: 300,
        animationType: 'particle',
        particleColor: '#4CAF50'
      })
      
      // 光晕效果
      FlingAnimationEffects({
        isVisible: this.showGlow,
        centerX: 200,
        centerY: 300,
        animationType: 'glow',
        particleColor: '#2196F3'
      })
      
      // 进度环
      FlingAnimationEffects({
        isVisible: true,
        centerX: 200,
        centerY: 300,
        animationType: 'progress',
        progress: this.progress,
        particleColor: '#FF9800'
      })
      
      // 成功动画
      FlingAnimationEffects({
        isVisible: this.showSuccess,
        centerX: 200,
        centerY: 300,
        animationType: 'success',
        particleColor: '#4CAF50'
      })
    }
    .width('100%')
    .height('100%')
  }
  
  // 触发粒子效果
  private triggerParticle() {
    this.showParticle = true;
  }
  
  // 触发光晕效果
  private triggerGlow() {
    this.showGlow = true;
  }
  
  // 更新进度
  private updateProgress(value: number) {
    this.progress = value;
  }
  
  // 触发成功动画
  private triggerSuccess() {
    this.showSuccess = true;
  }
}

// ============================================
// 4. 动画参数配置
// ============================================

/**
 * FlingAnimationEffects 参数说明：
 * 
 * @Param isVisible: boolean
 *   - 是否显示动画
 *   - 默认: false
 * 
 * @Param centerX: number
 *   - 动画中心 X 坐标
 *   - 默认: 0
 * 
 * @Param centerY: number
 *   - 动画中心 Y 坐标
 *   - 默认: 0
 * 
 * @Param animationType: 'particle' | 'glow' | 'progress' | 'success'
 *   - 动画类型
 *   - particle: 粒子扩散
 *   - glow: 光晕效果
 *   - progress: 进度环
 *   - success: 成功动画
 *   - 默认: 'particle'
 * 
 * @Param progress: number
 *   - 进度值 (0-1)
 *   - 仅在 animationType='progress' 时有效
 *   - 默认: 0
 * 
 * @Param particleColor: string
 *   - 粒子/光晕颜色
 *   - 默认: '#4CAF50'
 */

/**
 * DragDirectionIndicator 参数说明：
 * 
 * @Param offsetX: number
 *   - 拖拽 X 偏移量
 *   - 默认: 0
 * 
 * @Param offsetY: number
 *   - 拖拽 Y 偏移量
 *   - 默认: 0
 * 
 * @Param isVisible: boolean
 *   - 是否显示指示器
 *   - 默认: false
 * 
 * @Param velocity: number
 *   - 当前速度强度
 *   - 用于显示不同颜色
 *   - 默认: 0
 */

/**
 * SendStatusAnimation 参数说明：
 * 
 * @Param status: 'preparing' | 'sending' | 'success' | 'failed'
 *   - 发送状态
 *   - preparing: 准备中
 *   - sending: 发送中
 *   - success: 发送成功
 *   - failed: 发送失败
 *   - 默认: 'preparing'
 * 
 * @Param isVisible: boolean
 *   - 是否显示
 *   - 默认: false
 */

// ============================================
// 5. 最佳实践
// ============================================

/**
 * 1. 动画性能优化
 *    - 使用硬件加速动画 (animateTo)
 *    - 避免同时触发多个粒子效果
 *    - 及时清理动画定时器
 * 
 * 2. 用户体验建议
 *    - 提供清晰的方向指示
 *    - 使用颜色变化提示速度状态
 *    - 发送成功后给予明确反馈
 *    - 考虑添加震动反馈
 * 
 * 3. 可访问性考虑
 *    - 不要仅依赖颜色传达信息
 *    - 提供文字状态说明
 *    - 考虑动画敏感用户
 * 
 * 4. 错误处理
 *    - 处理动画初始化失败
 *    - 提供降级方案
 *    - 记录动画错误日志
 */

// ============================================
// 6. 完整示例
// ============================================

@Entry
@ComponentV2
struct CompleteExample {
  @Local todoItems: TodoItem[] = [];
  @Local sendStatus: string = 'preparing';
  @Local showStatusAnimation: boolean = false;

  build() {
    Stack() {
      Column() {
        // 标题
        Text('甩出发送演示')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })
        
        // 说明
        Text('快速拖拽卡片并甩出，发送到其他设备')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 20 })
        
        // 待办列表
        List({ space: 12 }) {
          ForEach(this.todoItems, (item: TodoItem) => {
            ListItem() {
              FlingTodoListItem({
                todoItem: item,
                onFlingSuccess: () => {
                  this.handleSendSuccess(item);
                },
                content: () => {
                  this.TodoItemBuilder(item);
                }
              });
            }
          }, (item: TodoItem) => item.taskID)
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding(20)
      
      // 发送状态动画
      SendStatusAnimation({
        status: this.sendStatus,
        isVisible: this.showStatusAnimation
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TodoItemBuilder(item: TodoItem) {
    Row() {
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        
        Text(this.formatDate(item.planTime))
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .height(80)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }

  private handleSendSuccess(item: TodoItem): void {
    console.info(`待办 ${item.title} 发送成功`);
    
    // 显示成功状态
    this.sendStatus = 'success';
    this.showStatusAnimation = true;
    
    // 2秒后隐藏
    setTimeout(() => {
      this.showStatusAnimation = false;
    }, 2000);
  }

  private formatDate(date: Date): string {
    return `${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  aboutToAppear(): void {
    // 初始化数据
    this.todoItems = [
      new TodoItem('1', '完成项目报告', new Date(), 0, 0, 2, false),
      new TodoItem('2', '参加会议', new Date(Date.now() + 3600000), 0, 0, 1, false),
      new TodoItem('3', '回复邮件', new Date(Date.now() + 7200000), 0, 0, 0, false),
    ];
  }
}
