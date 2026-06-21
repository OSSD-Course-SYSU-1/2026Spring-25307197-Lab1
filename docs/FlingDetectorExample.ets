/**
 * FlingDetector 使用示例
 * 展示如何监听拖拽手势的甩动方向和速度，向外快速甩出时触发发送事件
 */
import { FlingDetector, FlingCard, FlingDirection, FlingEvent } from '@ohos_agcit/daily_schedule_component_lib';

@Entry
@ComponentV2
struct FlingDetectorExample {
  @Local messageLog: string[] = [];
  @Local cardCount: number = 5;

  build() {
    Column() {
      // 标题
      Text('甩动检测示例')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      // 示例1: FlingDetector 基础用法
      Column() {
        Text('示例1: FlingDetector 基础用法')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 10 })

        FlingDetector({
          minFlingVelocity: 15,      // 最小速度阈值
          minFlingDistance: 100,     // 最小距离阈值
          direction: PanDirection.All, // 支持所有方向
          onFling: (event: FlingEvent) => {
            // 甩出事件触发
            const directionStr = this.getDirectionString(event.direction);
            this.addLog(`甩出! 方向: ${directionStr}, 速度: ${event.velocity.toFixed(1)}`);
            
            // 根据方向执行不同操作
            switch (event.direction) {
              case FlingDirection.UP:
                this.handleFlingUp();
                break;
              case FlingDirection.DOWN:
                this.handleFlingDown();
                break;
              case FlingDirection.LEFT:
                this.handleFlingLeft();
                break;
              case FlingDirection.RIGHT:
                this.handleFlingRight();
                break;
            }
          },
          onDragStart: () => {
            this.addLog('开始拖拽');
          },
          onDragUpdate: (offsetX: number, offsetY: number) => {
            // 可在此更新UI反馈
          },
          onDragEnd: () => {
            this.addLog('拖拽结束 (未触发甩出)');
          }
        }) {
          // 被检测的内容
          Column() {
            Text('拖拽我')
              .fontSize(16)
              .fontColor(Color.White)
          }
          .width(200)
          .height(100)
          .backgroundColor('#4A90D9')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
        }
      }
      .margin({ bottom: 30 })

      // 示例2: FlingCard 卡片甩出
      Column() {
        Text('示例2: FlingCard 卡片甩出')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 10 })

        Text(`剩余卡片: ${this.cardCount}`)
          .fontSize(14)
          .margin({ bottom: 10 })

        if (this.cardCount > 0) {
          FlingCard({
            minFlingVelocity: 18,
            flingDuration: 300,
            onFlingUp: () => {
              this.addLog('卡片向上甩出 - 标记为重要');
              this.cardCount--;
            },
            onFlingDown: () => {
              this.addLog('卡片向下甩出 - 稍后处理');
              this.cardCount--;
            },
            onFlingLeft: () => {
              this.addLog('卡片向左甩出 - 删除');
              this.cardCount--;
            },
            onFlingRight: () => {
              this.addLog('卡片向右甩出 - 完成');
              this.cardCount--;
            }
          }) {
            Column() {
              Text('待办事项 #' + this.cardCount)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              
              Text('← 左滑删除 | 右滑完成 →')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 8 })
              
              Text('↑ 上滑重要 | ↓ 下滑稍后')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .width(280)
            .height(120)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .padding(16)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
          }
        } else {
          Text('所有卡片已处理完毕')
            .fontSize(16)
            .fontColor('#999999')
        }
      }
      .margin({ bottom: 30 })

      // 日志区域
      Column() {
        Text('操作日志:')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })

        List() {
          ForEach(this.messageLog, (msg: string, index: number) => {
            ListItem() {
              Text(msg)
                .fontSize(12)
                .fontColor('#666666')
            }
          })
        }
        .width('100%')
        .height(150)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding(8)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }

  // 添加日志
  private addLog(msg: string): void {
    const time = new Date().toLocaleTimeString();
    this.messageLog.unshift(`[${time}] ${msg}`);
    if (this.messageLog.length > 20) {
      this.messageLog.pop();
    }
  }

  // 获取方向字符串
  private getDirectionString(direction: FlingDirection): string {
    switch (direction) {
      case FlingDirection.UP:
        return '↑ 上';
      case FlingDirection.DOWN:
        return '↓ 下';
      case FlingDirection.LEFT:
        return '← 左';
      case FlingDirection.RIGHT:
        return '→ 右';
      default:
        return '无';
    }
  }

  // 甩出方向处理
  private handleFlingUp(): void {
    // 向上甩出 - 发送/提交操作
    this.sendMessage('up');
  }

  private handleFlingDown(): void {
    // 向下甩出 - 取消/丢弃操作
    this.sendMessage('down');
  }

  private handleFlingLeft(): void {
    // 向左甩出 - 删除操作
    this.sendMessage('left');
  }

  private handleFlingRight(): void {
    // 向右甩出 - 确认/发送操作
    this.sendMessage('right');
  }

  private sendMessage(direction: string): void {
    // 实际发送逻辑
    console.info(`发送事件触发，方向: ${direction}`);
  }
}
