/**
 * 甩动手势检测演示页面
 * 展示 FlingDetector 和 FlingCard 的实际使用
 */
import { FlingDetector, FlingCard, FlingDirection, FlingEvent } from './FlingDetector';

@Entry
@ComponentV2
struct FlingDemo {
  @Local messageList: string[] = [];
  @Local cardCount: number = 5;
  @Local currentOffset: number = 0;

  build() {
    Column() {
      // 标题栏
      this.TitleBar()

      Scroll() {
        Column() {
          // 示例1: 基础甩动检测器
          this.BasicFlingExample()

          Blank().height(30)

          // 示例2: 可甩出的卡片
          this.FlingCardExample()

          Blank().height(30)

          // 示例3: 仅水平方向
          this.HorizontalFlingExample()

          Blank().height(20)

          // 日志区域
          this.LogArea()
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 标题栏
  @Builder
  TitleBar() {
    Row() {
      Text('甩动手势检测演示')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width('100%')
    .height(56)
    .backgroundColor('#4A90E2')
    .justifyContent(FlexAlign.Center)
  }

  // 基础甩动检测器示例
  @Builder
  BasicFlingExample() {
    Column() {
      Text('示例1: 基础甩动检测')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 15 })

      Column() {
        FlingDetector({
          minFlingVelocity: 15,
          minFlingDistance: 100,
          panDirection: PanDirection.All,
          onFling: (event: FlingEvent) => {
            this.handleFling(event);
          },
          onDragBegin: () => {
            this.addLog('👆 开始拖拽');
          },
          onDragUpdate: (offsetX: number, offsetY: number) => {
            // 可选：实时更新UI
          },
          onDragFinish: () => {
            this.addLog('👋 拖拽结束 (未触发甩出)');
          }
        }) {
          Column() {
            Text('👆 任意方向甩出')
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)

            Text('快速拖拽并释放')
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.8)')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .width(220)
      .height(130)
      .backgroundColor('#4A90E2')
      .borderRadius(16)
      .shadow({
        radius: 8,
        color: 'rgba(74, 144, 226, 0.3)',
        offsetX: 0,
        offsetY: 4
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // 可甩出的卡片示例
  @Builder
  FlingCardExample() {
    Column() {
      Text('示例2: 可甩出的卡片')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 15 })

      if (this.cardCount > 0) {
        Stack() {
          // 底部卡片（下一张）
          if (this.cardCount > 1) {
            Column() {
              Text(`卡片 ${this.cardCount - 1}`)
                .fontSize(16)
                .fontColor('#999')
            }
            .width(220)
            .height(160)
            .backgroundColor('#E0E0E0')
            .borderRadius(16)
            .scale({ x: 0.95, y: 0.95 })
          }

          // 顶部卡片（当前）
          Column() {
            FlingCard({
              minFlingVelocity: 18,
              flingDuration: 280,
              onFlingUp: () => {
                this.addLog('⬆️ 向上甩出 - 归档');
                this.cardCount--;
              },
              onFlingDown: () => {
                this.addLog('⬇️ 向下甩出 - 删除');
                this.cardCount--;
              },
              onFlingLeft: () => {
                this.addLog('⬅️ 向左甩出 - 拒绝');
                this.cardCount--;
              },
              onFlingRight: () => {
                this.addLog('➡️ 向右甩出 - 接受');
                this.cardCount--;
              }
            }) {
              Column() {
                Text(`卡片 ${this.cardCount}`)
                  .fontSize(20)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)

                Text('任意方向甩出')
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.8)')
                  .margin({ top: 8 })

                // 操作提示
                Row() {
                  Text('❌')
                    .fontSize(24)
                  Blank()
                  Text('✅')
                    .fontSize(24)
                }
                .width('80%')
                .margin({ top: 20 })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
            }
          }
          .width(220)
          .height(160)
          .backgroundColor('#E74C3C')
          .borderRadius(16)
        }
        .width(220)
        .height(160)
        .alignContent(Alignment.Center)
      } else {
        Column() {
          Text('✅ 所有卡片已处理')
            .fontSize(16)
            .fontColor('#666')

          Button('重新开始')
            .margin({ top: 15 })
            .backgroundColor('#4A90E2')
            .onClick(() => {
              this.cardCount = 5;
              this.messageList = [];
              this.addLog('🔄 重新开始');
            })
        }
        .width(220)
        .height(160)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(16)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // 仅水平方向示例
  @Builder
  HorizontalFlingExample() {
    Column() {
      Text('示例3: 仅水平方向')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 15 })

      Column() {
        FlingDetector({
          minFlingVelocity: 15,
          minFlingDistance: 80,
          panDirection: PanDirection.Horizontal, // 仅水平方向
          onFling: (event: FlingEvent) => {
            if (event.direction === FlingDirection.LEFT) {
              this.addLog('⬅️ 向左滑动 - 上一页');
            } else if (event.direction === FlingDirection.RIGHT) {
              this.addLog('➡️ 向右滑动 - 下一页');
            }
          },
          onDragBegin: () => {
            this.addLog('👆 开始水平拖拽');
          },
          onDragFinish: () => {
            this.addLog('👋 水平拖拽结束');
          }
        }) {
          Column() {
            Text('↔️ 左右滑动')
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)

            Text('仅响应水平方向')
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.8)')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .width(220)
      .height(130)
      .backgroundColor('#9B59B6')
      .borderRadius(16)
      .shadow({
        radius: 8,
        color: 'rgba(155, 89, 182, 0.3)',
        offsetX: 0,
        offsetY: 4
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // 日志区域
  @Builder
  LogArea() {
    Column() {
      Row() {
        Text('操作日志')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)

        Blank()

        Text(`共 ${this.messageList.length} 条`)
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (this.messageList.length > 0) {
        List() {
          ForEach(this.messageList, (message: string, index: number) => {
            ListItem() {
              Text(message)
                .fontSize(13)
                .fontColor('#333')
                .width('100%')
                .padding(10)
                .backgroundColor(Color.White)
                .borderRadius(8)
                .margin({ bottom: 6 })
            }
          }, (message: string, index: number) => index.toString())
        }
        .width('100%')
        .height(180)
        .scrollBar(BarState.Auto)
      } else {
        Column() {
          Text('暂无操作记录')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(8)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  // 处理甩动事件
  private handleFling(event: FlingEvent): void {
    const directionText = this.getDirectionText(event.direction);
    const distance = Math.sqrt(event.offsetX ** 2 + event.offsetY ** 2);

    this.addLog(
      `${directionText} | 速度:${event.velocity.toFixed(1)} | 距离:${distance.toFixed(0)}px`
    );
  }

  // 获取方向文本
  private getDirectionText(direction: FlingDirection): string {
    switch (direction) {
      case FlingDirection.UP:
        return '⬆️ 向上甩出';
      case FlingDirection.DOWN:
        return '⬇️ 向下甩出';
      case FlingDirection.LEFT:
        return '⬅️ 向左甩出';
      case FlingDirection.RIGHT:
        return '➡️ 向右甩出';
      default:
        return '❓ 未知方向';
    }
  }

  // 添加日志
  private addLog(message: string): void {
    const timestamp = new Date().toLocaleTimeString();
    this.messageList.unshift(`[${timestamp}] ${message}`);

    // 限制日志数量
    if (this.messageList.length > 30) {
      this.messageList.pop();
    }
  }
}
