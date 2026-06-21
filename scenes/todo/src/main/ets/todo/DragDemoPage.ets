import { DraggableList, DraggableItem } from '@ohos_agcit/daily_schedule_component_lib';

/**
 * 拖拽列表演示页面
 * 展示长按拖动、悬浮预览和物理甩动效果
 */
@Entry
@ComponentV2
struct DragDemoPage {
  // 演示数据
  @Local demoItems: DraggableItem[] = [
    { id: '1', content: '任务一：完成项目文档', color: '#FF6B6B' },
    { id: '2', content: '任务二：代码审查', color: '#4ECDC4' },
    { id: '3', content: '任务三：UI设计优化', color: '#45B7D1' },
    { id: '4', content: '任务四：性能测试', color: '#96CEB4' },
    { id: '5', content: '任务五：用户反馈处理', color: '#FFEAA7' },
    { id: '6', content: '任务六：部署上线', color: '#DDA0DD' },
    { id: '7', content: '任务七：监控告警配置', color: '#98D8C8' },
    { id: '8', content: '任务八：数据备份', color: '#F7DC6F' }
  ];
  
  // 操作提示
  @Local showTip: boolean = true;

  build() {
    Column() {
      // 标题栏
      this.titleBar();
      
      // 操作提示
      if (this.showTip) {
        this.tipBanner();
      }
      
      // 拖拽列表
      DraggableList({
        items: this.demoItems,
        itemHeight: 80,
        itemSpacing: 12,
        longPressDuration: 400,
        previewScale: 1.08,
        previewShadowRadius: 35,
        friction: 0.82,
        elasticity: 0.35,
        itemBuilder: (item: DraggableItem, index: number, isDragging: boolean) => {
          this.demoItemBuilder(item, index, isDragging);
        },
        onDragEnd: (newItems: DraggableItem[]) => {
          this.demoItems = newItems;
        }
      })
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
  
  // 标题栏
  @Builder
  titleBar() {
    Row() {
      Text('拖拽列表演示')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      
      Blank()
      
      // 重置按钮
      Button('重置')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .backgroundColor($r('sys.color.background_tertiary'))
        .height(32)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.resetItems();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_primary'))
  }
  
  // 提示横幅
  @Builder
  tipBanner() {
    Row() {
      Text('💡')
        .fontSize(16)
      
      Text(' 长按列表项可拖动，快速甩动试试物理效果')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .layoutWeight(1)
      
      // 关闭提示
      Text('✕')
        .fontSize(16)
        .fontColor($r('sys.color.font_tertiary'))
        .onClick(() => {
          this.showTip = false;
        })
    }
    .width('100%')
    .height(40)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_tertiary'))
    .borderRadius(8)
    .margin({ left: 16, right: 16, top: 12 })
  }
  
  // 列表项构建器
  @Builder
  demoItemBuilder(item: DraggableItem, index: number, isDragging: boolean) {
    Row() {
      // 序号标识
      Column() {
        Text((index + 1).toString())
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor(item.color)
      .justifyContent(FlexAlign.Center)
      
      // 内容
      Column() {
        Text(item.content)
          .fontSize(16)
          .fontWeight(isDragging ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(isDragging ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      
      // 拖拽图标
      if (!isDragging) {
        Text('⋮⋮')
          .fontSize(16)
          .fontColor($r('sys.color.font_tertiary'))
          .opacity(0.5)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor(isDragging ? 
      $r('sys.color.background_primary') : 
      $r('sys.color.background_primary'))
    .borderRadius(12)
    .border({
      width: isDragging ? 2 : 1,
      color: isDragging ? item.color : $r('sys.color.comp_divider')
    })
  }
  
  // 重置数据
  private resetItems(): void {
    this.demoItems = [
      { id: '1', content: '任务一：完成项目文档', color: '#FF6B6B' },
      { id: '2', content: '任务二：代码审查', color: '#4ECDC4' },
      { id: '3', content: '任务三：UI设计优化', color: '#45B7D1' },
      { id: '4', content: '任务四：性能测试', color: '#96CEB4' },
      { id: '5', content: '任务五：用户反馈处理', color: '#FFEAA7' },
      { id: '6', content: '任务六：部署上线', color: '#DDA0DD' },
      { id: '7', content: '任务七：监控告警配置', color: '#98D8C8' },
      { id: '8', content: '任务八：数据备份', color: '#F7DC6F' }
    ];
  }
}
