import { FlingTodoListItem } from '@ohos_agcit/daily_schedule_component_lib';
import { TodoItem } from '@ohos_agcit/daily_schedule_common_lib';
import { promptAction } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';

// 极小窗口阈值
const MIN_WINDOW_WIDTH: number = 320;

/**
 * 甩出功能测试页面
 * 用于测试 FlingTodoListItem 的手势和动画效果
 */
@Entry
@ComponentV2
struct FlingTestPage {
  @Local todoItems: TodoItem[] = [];
  @Local testResults: string[] = [];
  // 可视区域索引范围（用于优化手势绑定）
  @Local visibleStartIndex: number = 0;
  @Local visibleEndIndex: number = 100;
  // 窗口尺寸状态（用于极小窗口自适应）
  @Local windowWidth: number = 360;
  // 极小窗口判断
  private get isMinimalWindow(): boolean {
    return this.windowWidth < MIN_WINDOW_WIDTH;
  }

  aboutToAppear(): void {
    // 初始化窗口尺寸
    this.initWindowSize();
    // 创建测试数据
    this.todoItems = [
      this.createTodoItem('1', '测试待办1 - 向上甩出归档'),
      this.createTodoItem('2', '测试待办2 - 向右甩出发送'),
      this.createTodoItem('3', '测试待办3 - 快速甩出'),
      this.createTodoItem('4', '测试待办4 - 观察粒子效果'),
      this.createTodoItem('5', '测试待办5 - 观察方向指示器'),
    ];
    
    this.addLog('页面加载完成，共 ' + this.todoItems.length + ' 个测试项');
  }

  // 初始化窗口尺寸
  private initWindowSize(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync();
      this.windowWidth = displayInfo.width;
    } catch (e) {
      console.warn(`[FlingTestPage] Failed to get display info: ${e}`);
    }
  }

  private createTodoItem(id: string, title: string): TodoItem {
    return new TodoItem(
      id,           // taskID
      title,        // title
      new Date(),   // planTime
      0,            // remindTime
      0,            // remindType
      2,            // priorityType (2=高优先级)
      false         // isFinished
    );
  }

  build() {
    Column() {
      // 标题（极小窗口时缩小）
      Text('甩出功能测试')
        .fontSize(this.isMinimalWindow ? 18 : 24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: this.isMinimalWindow ? 10 : 20, bottom: this.isMinimalWindow ? 5 : 10 })

      // 说明（极小窗口时精简，保证核心功能可见）
      if (!this.isMinimalWindow) {
        Column() {
          Text('测试步骤：')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          
          Text('1. 按住待办卡片约0.2秒')
            .fontSize(14)
            .fontColor('#666666')
          Text('2. 看到卡片放大和绿色光晕')
            .fontSize(14)
            .fontColor('#666666')
          Text('3. 快速向上或向右甩出')
            .fontSize(14)
            .fontColor('#666666')
          Text('4. 观察粒子扩散和飞出动画')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('90%')
        .padding(16)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
        .margin({ bottom: 20 })
      }

      // 待办列表
      List({ space: 12 }) {
        ForEach(this.todoItems, (item: TodoItem, index: number) => {
          ListItem() {
            FlingTodoListItem({
              todoItem: item,
              // isVisible: 仅当在可视区域内时才绑定手势，优化性能
              isVisible: index >= this.visibleStartIndex && index <= this.visibleEndIndex,
              onFlingSuccess: () => {
                this.handleFlingSuccess(item);
              },
              onFlingFail: (reason: string) => {
                this.handleFlingFail(item, reason);
              },
              content: () => {
                this.TodoCardBuilder(item, index);
              }
            });
          }
        }, (item: TodoItem) => item.taskID)
      }
      .width('90%')
      .layoutWeight(1)
      .margin({ bottom: 20 })
      // 监听滚动，更新可视区域索引范围（优化手势绑定性能）
      .onScrollIndex((start: number, end: number) => {
        this.visibleStartIndex = Math.max(0, start - 2);
        this.visibleEndIndex = Math.min(this.todoItems.length - 1, end + 2);
      })

      // 日志区域
      Column() {
        Text('操作日志：')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })

        List() {
          ForEach(this.testResults, (log: string, index: number) => {
            ListItem() {
              Text(log)
                .fontSize(12)
                .fontColor('#999999')
                .width('100%')
            }
            .margin({ bottom: 4 })
          }, (log: string, index: number) => index.toString())
        }
        .width('100%')
        .height(150)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .padding(8)
      }
      .width('90%')
      .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    // 安全区适配：避开刘海、挖孔、底部手势栏
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    // 监听窗口尺寸变化，实现极小窗口自适应
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      if (newValue.width !== undefined) {
        const width = newValue.width as number;
        if (width > 0 && Math.abs(width - this.windowWidth) > 10) {
          this.windowWidth = width;
        }
      }
    })
  }

  @Builder
  TodoCardBuilder(item: TodoItem, index: number) {
    Row() {
      // 序号
      Text((index + 1).toString())
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4CAF50')
        .width(40)
        .textAlign(TextAlign.Center)

      // 内容
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('优先级: 高 | 状态: 未完成')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .height(80)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  private handleFlingSuccess(item: TodoItem): void {
    const time = new Date().toLocaleTimeString();
    this.addLog(`[${time}] ✅ 甩出成功: ${item.title}`);
    
    promptAction.showToast({
      message: '甩出成功！已触发发送流程',
      duration: 2000
    });
  }
  
  private handleFlingFail(item: TodoItem, reason: string): void {
    const time = new Date().toLocaleTimeString();
    this.addLog(`[${time}] ❌ 甩出失败: ${item.title} - ${reason}`);
    
    // 限制 Toast 消息长度
    const shortReason = reason.length > 20 ? reason.substring(0, 20) + '...' : reason;
    promptAction.showToast({
      message: `甩出失败：${shortReason}`,
      duration: 2000
    });
  }

  private addLog(message: string): void {
    this.testResults.unshift(message);
    // 只保留最近20条日志
    if (this.testResults.length > 20) {
      this.testResults.pop();
    }
  }
}
