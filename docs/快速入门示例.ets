/**
 * 快速入门示例
 * 展示如何快速集成拖拽功能到现有列表
 */
import { DraggableList, DraggableItem } from '@ohos_agcit/daily_schedule_component_lib';

@Entry
@ComponentV2
struct QuickStartExample {
  // 1. 定义数据（必须包含 id 字段）
  @Local items: DraggableItem[] = [
    { id: '1', content: '第一项', color: '#FF6B6B' },
    { id: '2', content: '第二项', color: '#4ECDC4' },
    { id: '3', content: '第三项', color: '#45B7D1' }
  ];

  build() {
    Column() {
      // 2. 使用 DraggableList 组件
      DraggableList({
        items: this.items,
        itemHeight: 80,
        itemSpacing: 12,
        
        // 3. 定义列表项外观
        itemBuilder: (item: DraggableItem, index: number, isDragging: boolean) => {
          Row() {
            Text(item.content)
              .fontSize(16)
              .fontColor(isDragging ? Color.White : Color.Black)
          }
          .width('100%')
          .height('100%')
          .padding(16)
          .backgroundColor(isDragging ? item.color : '#F5F5F5')
          .borderRadius(12)
        },
        
        // 4. 处理拖拽结果
        onDragEnd: (newItems: DraggableItem[]) => {
          this.items = newItems;
        }
      })
      .width('100%')
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}
