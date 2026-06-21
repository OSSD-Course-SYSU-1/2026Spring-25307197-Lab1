import { FlingTodoCard, FlingTodoListItem } from './FlingTodoCard';
import { TodoItem, DeviceManagerUtil, TransferUtil } from '@ohos_agcit/daily_schedule_common_lib';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const LOG_DOMAIN = 0xFF00;
const LOG_TAG = 'FlingTransferDemo';

/**
 * 甩出发送待办演示页面
 * 展示如何使用甩动手势将待办事项发送到其他设备
 */
@Entry
@ComponentV2
struct FlingTransferDemo {
  // 待办事项列表
  @Local todoItems: TodoItem[] = [];
  
  // 上下文
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  
  aboutToAppear(): void {
    // 初始化
    this.initTransfer();
    
    // 创建示例待办事项
    this.todoItems = [
      new TodoItem('1', '完成项目报告', new Date(), 0, 0, 2, false),
      new TodoItem('2', '参加会议', new Date(Date.now() + 3600000), 0, 0, 1, false),
      new TodoItem('3', '回复邮件', new Date(Date.now() + 7200000), 0, 0, 0, false),
    ];
  }
  
  /**
   * 初始化传输工具
   */
  private async initTransfer(): Promise<void> {
    try {
      const bundleName = this.context.applicationInfo.name;
      
      // 初始化设备管理器
      const deviceManager = DeviceManagerUtil.getInstance();
      await deviceManager.init(bundleName);
      
      // 初始化传输工具
      const transferUtil = TransferUtil.getInstance();
      await transferUtil.init(this.context, bundleName);
      
      // 注册接收回调
      transferUtil.registerReceiveCallback({
        onTodoReceived: (todo: TodoItem, fromDeviceId: string) => {
          hilog.info(LOG_DOMAIN, LOG_TAG, `Received todo: ${todo.title} from ${fromDeviceId}`);
          // 添加到列表
          this.todoItems.push(todo);
        }
      });
      
      hilog.info(LOG_DOMAIN, LOG_TAG, 'Transfer initialized successfully');
    } catch (err) {
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to init transfer: ${err}`);
    }
  }
  
  build() {
    Column() {
      // 标题
      Row() {
        Text('甩出发送待办演示')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .height(60)
      
      // 说明文本
      Column() {
        Text('使用说明')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        
        Text('1. 长按待办卡片开始拖拽')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 8 })
        
        Text('2. 快速甩出（任意方向）')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 4 })
        
        Text('3. 选择目标设备')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 4 })
        
        Text('4. 待办将自动发送到选中设备')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 4 })
      }
      .width('90%')
      .padding(16)
      .backgroundColor($r('sys.color.background_tertiary'))
      .borderRadius(12)
      .margin({ top: 16, bottom: 16 })
      
      // 待办列表
      List({ space: 12 }) {
        ForEach(this.todoItems, (item: TodoItem, index: number) => {
          ListItem() {
            FlingTodoListItem({
              todoItem: item,
              onFlingSuccess: () => {
                hilog.info(LOG_DOMAIN, LOG_TAG, `Todo ${item.title} sent successfully`);
              },
              content: () => {
                this.todoItemBuilder(item);
              }
            });
          }
        }, (item: TodoItem) => item.taskID)
      }
      .width('90%')
      .layoutWeight(1)
      .padding({ top: 8, bottom: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
  
  /**
   * 待办事项卡片构建器
   */
  @Builder
  todoItemBuilder(item: TodoItem) {
    Row() {
      Column() {
        Checkbox()
          .select(item.isFinished)
          .selectedColor($r('sys.color.icon_tertiary'))
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .onChange((value: boolean) => {
            item.isFinished = value;
          })
      }
      .height('100%')
      .justifyContent(FlexAlign.Center)
      
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontColor(item.isFinished ? $r('sys.color.font_tertiary') : $r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
        
        Text(this.formatDate(item.planTime))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
      
      // 优先级标识
      Text(this.getPriorityText(item.priorityType))
        .fontSize(12)
        .fontColor(this.getPriorityColor(item.priorityType))
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(this.getPriorityBgColor(item.priorityType))
        .borderRadius(4)
    }
    .width('100%')
    .height(76)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(12)
  }
  
  /**
   * 格式化日期
   */
  private formatDate(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
  
  /**
   * 获取优先级文本
   */
  private getPriorityText(priority: number): string {
    switch (priority) {
      case 0:
        return '低';
      case 1:
        return '中';
      case 2:
        return '高';
      default:
        return '';
    }
  }
  
  /**
   * 获取优先级颜色
   */
  private getPriorityColor(priority: number): ResourceColor {
    switch (priority) {
      case 0:
        return $r('sys.color.multi_color_04');
      case 1:
        return $r('sys.color.alert');
      case 2:
        return $r('sys.color.warning');
      default:
        return $r('sys.color.font_primary');
    }
  }
  
  /**
   * 获取优先级背景色
   */
  private getPriorityBgColor(priority: number): ResourceColor {
    switch (priority) {
      case 0:
        return 'rgba(0, 150, 136, 0.1)';
      case 1:
        return 'rgba(255, 152, 0, 0.1)';
      case 2:
        return 'rgba(244, 67, 54, 0.1)';
      default:
        return 'transparent';
    }
  }
}
