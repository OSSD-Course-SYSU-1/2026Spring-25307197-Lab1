/**
 * FlingDetector 使用示例
 * 演示如何使用甩动手势检测器
 */
import { FlingDetector, FlingCard, FlingDirection, FlingEvent } from '../commons/component_lib/Index';

@Entry
@ComponentV2
struct FlingDetectorExample {
  @Local messageList: string[] = [];
  @Local cardCount: number = 5;

  build() {
    Column() {
      // 标题
      Text('甩动手势检测示例')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      // 示例1: 基础甩动检测器
      this.BasicFlingDetectorExample()

      Blank().height(30)

      // 示例2: 可甩出的卡片
      this.FlingCardExample()

      Blank().height(20)

      // 日志显示区域
      this.LogArea()
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }

  // 基础甩动检测器示例
  @Builder
  BasicFlingDetectorExample() {
    Column() {
      Text('示例1: 基础甩动检测')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })

      FlingDetector({
        // 最小甩动速度阈值 (像素/帧)
        minFlingVelocity: 15,
        // 最小甩动距离阈值 (像素)
        minFlingDistance: 100,
        // 允许所有方向的甩动
        direction: PanDirection.All,
        // 甩出事件回调
        onFling: (event: FlingEvent) => {
          this.handleFling(event);
        },
        // 拖拽开始回调
        onDragStart: () => {
          this.addLog('开始拖拽');
        },
        // 拖拽更新回调
        onDragUpdate: (offsetX: number, offsetY: number) => {
          console.log(`拖拽中: offsetX=${offsetX.toFixed(1)}, offsetY=${offsetY.toFixed(1)}`);
        },
        // 拖拽结束回调 (未触发甩出)
        onDragEnd: () => {
          this.addLog('拖拽结束 (未触发甩出)');
        }
      }) {
        // 被检测的内容
        Column() {
          Text('👆 拖拽我')
            .fontSize(20)
            .fontColor(Color.White)
        }
        .width(200)
        .height(120)
        .backgroundColor('#4A90E2')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
  }

  // 可甩出的卡片示例
  @Builder
  FlingCardExample() {
    Column() {
      Text('示例2: 可甩出的卡片')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })

      if (this.cardCount > 0) {
        FlingCard({
          minFlingVelocity: 18,
          flingDuration: 300,
          // 向上甩出 - 例如: 归档操作
          onFlingUp: () => {
            this.addLog('⬆️ 向上甩出 - 归档');
            this.cardCount--;
          },
          // 向下甩出 - 例如: 删除操作
          onFlingDown: () => {
            this.addLog('⬇️ 向下甩出 - 删除');
            this.cardCount--;
          },
          // 向左甩出 - 例如: 拒绝/取消
          onFlingLeft: () => {
            this.addLog('⬅️ 向左甩出 - 拒绝');
            this.cardCount--;
          },
          // 向右甩出 - 例如: 接受/确认
          onFlingRight: () => {
            this.addLog('➡️ 向右甩出 - 确认');
            this.cardCount--;
          }
        }) {
          Column() {
            Text(`卡片 ${this.cardCount}`)
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ bottom: 8 })

            Text('任意方向甩出')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.8)')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width(220)
        .height(140)
        .backgroundColor('#E74C3C')
        .borderRadius(12)
      } else {
        Column() {
          Text('所有卡片已甩出')
            .fontSize(16)
            .fontColor('#999')

          Button('重置')
            .margin({ top: 10 })
            .onClick(() => {
              this.cardCount = 5;
              this.messageList = [];
            })
        }
        .width(220)
        .height(140)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
  }

  // 日志显示区域
  @Builder
  LogArea() {
    Column() {
      Text('操作日志:')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })

      List() {
        ForEach(this.messageList, (message: string, index: number) => {
          ListItem() {
            Text(message)
              .fontSize(14)
              .fontColor('#666')
              .width('100%')
              .padding(8)
              .backgroundColor('#F5F5F5')
              .borderRadius(4)
              .margin({ bottom: 4 })
          }
        }, (message: string, index: number) => index.toString())
      }
      .width('100%')
      .height(150)
      .backgroundColor('#FAFAFA')
      .borderRadius(8)
      .padding(8)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 处理甩动事件
  private handleFling(event: FlingEvent): void {
    const directionText = this.getDirectionText(event.direction);
    this.addLog(
      `${directionText} 甩出 | ` +
      `速度: ${event.velocity.toFixed(1)} | ` +
      `距离: ${Math.sqrt(event.offsetX ** 2 + event.offsetY ** 2).toFixed(1)}px | ` +
      `时长: ${event.duration}ms`
    );
  }

  // 获取方向文本
  private getDirectionText(direction: FlingDirection): string {
    switch (direction) {
      case FlingDirection.UP:
        return '⬆️ 向上';
      case FlingDirection.DOWN:
        return '⬇️ 向下';
      case FlingDirection.LEFT:
        return '⬅️ 向左';
      case FlingDirection.RIGHT:
        return '➡️ 向右';
      default:
        return '❓ 未知';
    }
  }

  // 添加日志
  private addLog(message: string): void {
    const timestamp = new Date().toLocaleTimeString();
    this.messageList.unshift(`[${timestamp}] ${message}`);
    
    // 限制日志数量
    if (this.messageList.length > 20) {
      this.messageList.pop();
    }
  }
}
