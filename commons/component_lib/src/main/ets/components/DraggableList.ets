import { curves } from '@kit.ArkUI';

/**
 * 可拖拽列表项数据模型
 */
export interface DraggableItem {
  id: string;
  content: string;
  color: ResourceColor;
}

/**
 * 可拖拽列表组件
 * 支持长按拖动、悬浮预览和物理甩动效果
 */
@ComponentV2
export struct DraggableList {
  // 数据源
  @Param items: DraggableItem[] = [];
  // 长按触发时间（毫秒）
  @Param longPressDuration: number = 400;
  // 悬浮预览缩放比例
  @Param previewScale: number = 1.05;
  // 悬浮预览阴影深度
  @Param previewShadowRadius: number = 30;
  // 物理甩动摩擦系数
  @Param friction: number = 0.85;
  // 物理甩动弹性系数
  @Param elasticity: number = 0.4;
  // 列表项高度
  @Param itemHeight: number = 80;
  // 列表项间距
  @Param itemSpacing: number = 12;
  // 列表项构建器
  @BuilderParam itemBuilder: (item: DraggableItem, index: number, isDragging: boolean) => void = this.defaultItemBuilder;
  // 拖拽结束回调
  @Param onReorder: (items: DraggableItem[]) => void = () => {};
  
  // 默认列表项构建器
  @Builder
  defaultItemBuilder(item: DraggableItem, index: number, isDragging: boolean) {
    Text(item.content)
  }

  // 内部状态
  @Local isDragging: boolean = false;
  @Local dragIndex: number = -1;
  @Local dragOffsetY: number = 0;
  @Local velocityY: number = 0;
  @Local targetIndex: number = -1;
  @Local flingOffset: number = 0;
  @Local flingVelocity: number = 0;
  @Local isFlinging: boolean = false;
  
  // 列表滚动控制器
  private scroller: Scroller = new Scroller();
  // 上一次移动位置
  private lastMoveY: number = 0;
  private lastMoveTime: number = 0;
  // 速度历史记录（用于更准确的速度计算）
  private velocityHistory: number[] = [];
  private readonly VELOCITY_HISTORY_SIZE: number = 5;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 主列表
      List({ scroller: this.scroller, space: this.itemSpacing }) {
        ForEach(this.items, (item: DraggableItem, index: number) => {
          ListItem() {
            if (this.isDragging && index === this.dragIndex) {
              // 拖拽项占位（半透明）
              Column()
                .width('100%')
                .height(this.itemHeight)
                .opacity(0.2)
                .borderRadius(12)
                .backgroundColor($r('sys.color.background_tertiary'))
            } else {
              // 正常列表项
              Column() {
                this.itemBuilder(item, index, this.isDragging && index === this.dragIndex)
              }
              .width('100%')
              .height(this.itemHeight)
              .gesture(
                LongPressGesture({ repeat: false, duration: this.longPressDuration })
                  .onAction(() => {
                    this.startDrag(index);
                  })
              )
              .transition(
                TransitionEffect.OPACITY
                  .combine(TransitionEffect.translate({ y: this.calcItemTransitionOffset(index) }))
                  .animation({ curve: curves.springMotion(0.6, 0.8), duration: 300 })
              )
            }
          }
        }, (item: DraggableItem) => item.id)
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(this.isDragging ? HitTestMode.None : HitTestMode.Default)
      
      // 悬浮预览
      if (this.isDragging && this.dragIndex >= 0 && this.dragIndex < this.items.length) {
        Column() {
          this.itemBuilder(this.items[this.dragIndex], this.dragIndex, true)
        }
        .width('100%')
        .height(this.itemHeight)
        .scale({ x: this.previewScale, y: this.previewScale })
        .shadow({
          radius: this.previewShadowRadius,
          color: 'rgba(0, 0, 0, 0.3)',
          offsetX: 0,
          offsetY: 10
        })
        .opacity(0.98)
        .offset({ y: this.dragOffsetY + this.flingOffset })
        .zIndex(999)
        .gesture(
          PanGesture({ direction: PanDirection.Vertical })
            .onActionStart((event: GestureEvent) => {
              this.lastMoveY = 0;
              this.lastMoveTime = Date.now();
              this.velocityHistory = [];
            })
            .onActionUpdate((event: GestureEvent) => {
              const currentTime = Date.now();
              const deltaTime = currentTime - this.lastMoveTime;
              
              if (deltaTime > 0) {
                // 计算瞬时速度
                const instantVelocity = (event.offsetY - this.lastMoveY) / deltaTime * 16.67;
                
                // 更新速度历史
                this.velocityHistory.push(instantVelocity);
                if (this.velocityHistory.length > this.VELOCITY_HISTORY_SIZE) {
                  this.velocityHistory.shift();
                }
                
                // 计算平均速度
                this.velocityY = this.velocityHistory.reduce((a, b) => a + b, 0) / this.velocityHistory.length;
              }
              
              this.lastMoveY = event.offsetY;
              this.lastMoveTime = currentTime;
              
              // 更新拖拽偏移
              this.dragOffsetY = event.offsetY;
              
              // 计算目标位置
              this.updateTargetIndex();
            })
            .onActionEnd(() => {
              // 触发物理甩动
              this.startFling();
            })
        )
      }
    }
    .width('100%')
    .height('100%')
  }
  
  // 开始拖拽
  private startDrag(index: number): void {
    this.isDragging = true;
    this.dragIndex = index;
    this.dragOffsetY = 0;
    this.velocityY = 0;
    this.targetIndex = index;
    this.flingOffset = 0;
    this.flingVelocity = 0;
    this.isFlinging = false;
  }
  
  // 更新目标索引
  private updateTargetIndex(): void {
    if (this.dragIndex < 0) return;
    
    const currentOffset = this.dragOffsetY + this.flingOffset;
    const itemTotalHeight = this.itemHeight + this.itemSpacing;
    const deltaIndex = Math.round(currentOffset / itemTotalHeight);
    
    let newTargetIndex = this.dragIndex + deltaIndex;
    newTargetIndex = Math.max(0, Math.min(this.items.length - 1, newTargetIndex));
    
    this.targetIndex = newTargetIndex;
  }
  
  // 开始物理甩动
  private startFling(): void {
    // 初始速度（基于拖动速度）
    this.flingVelocity = this.velocityY * 2;
    this.flingOffset = 0;
    this.isFlinging = true;
    
    // 使用animateTo进行甩动动画
    this.animateFling();
  }
  
  // 甩动动画
  private animateFling(): void {
    if (!this.isFlinging) return;
    
    const maxOffset = this.calcMaxFlingOffset();
    const targetOffset = this.calcTargetOffset();
    
    // 如果速度很小或已经接近目标，直接结束
    if (Math.abs(this.flingVelocity) < 1 || Math.abs(this.flingOffset - targetOffset) < 5) {
      this.flingOffset = targetOffset;
      this.endDrag();
      return;
    }
    
    // 应用摩擦力
    this.flingVelocity *= this.friction;
    
    // 更新偏移
    this.flingOffset += this.flingVelocity;
    
    // 边界弹性
    if (this.flingOffset > maxOffset) {
      this.flingOffset = maxOffset + (this.flingOffset - maxOffset) * this.elasticity;
      this.flingVelocity *= -this.elasticity;
    } else if (this.flingOffset < -this.calcMinFlingOffset()) {
      const minOffset = -this.calcMinFlingOffset();
      this.flingOffset = minOffset + (this.flingOffset - minOffset) * this.elasticity;
      this.flingVelocity *= -this.elasticity;
    }
    
    // 更新目标索引
    this.updateTargetIndex();
    
    // 继续动画
    setTimeout(() => {
      this.animateFling();
    }, 16);
  }
  
  // 计算目标偏移
  private calcTargetOffset(): number {
    if (this.dragIndex < 0 || this.targetIndex < 0) return 0;
    
    const itemTotalHeight = this.itemHeight + this.itemSpacing;
    return (this.targetIndex - this.dragIndex) * itemTotalHeight;
  }
  
  // 计算最大甩动偏移
  private calcMaxFlingOffset(): number {
    if (this.dragIndex < 0) return 0;
    
    const itemTotalHeight = this.itemHeight + this.itemSpacing;
    return (this.items.length - 1 - this.dragIndex) * itemTotalHeight;
  }
  
  // 计算最小甩动偏移
  private calcMinFlingOffset(): number {
    if (this.dragIndex < 0) return 0;
    
    const itemTotalHeight = this.itemHeight + this.itemSpacing;
    return this.dragIndex * itemTotalHeight;
  }
  
  // 结束拖拽
  private endDrag(): void {
    this.isFlinging = false;
    
    if (this.dragIndex !== this.targetIndex && this.targetIndex >= 0) {
      // 执行数据交换
      const newItems = [...this.items];
      const draggedItem = newItems[this.dragIndex];
      
      // 移除原位置项
      newItems.splice(this.dragIndex, 1);
      // 在新位置插入
      newItems.splice(this.targetIndex, 0, draggedItem);
      
      // 触发回调
      this.onReorder(newItems);
    }
    
    // 重置状态
    this.isDragging = false;
    this.dragIndex = -1;
    this.targetIndex = -1;
    this.dragOffsetY = 0;
    this.flingOffset = 0;
    this.velocityY = 0;
    this.flingVelocity = 0;
  }
  
  // 计算列表项过渡偏移
  private calcItemTransitionOffset(index: number): number {
    if (!this.isDragging || this.dragIndex < 0 || this.targetIndex < 0) return 0;
    
    const itemTotalHeight = this.itemHeight + this.itemSpacing;
    
    // 被拖拽项不偏移
    if (index === this.dragIndex) return 0;
    
    // 计算其他项的偏移
    const minIndex = Math.min(this.dragIndex, this.targetIndex);
    const maxIndex = Math.max(this.dragIndex, this.targetIndex);
    
    if (index >= minIndex && index <= maxIndex) {
      if (this.dragIndex < this.targetIndex) {
        // 向下拖拽，中间项向上移动
        if (index > this.dragIndex) {
          return -itemTotalHeight;
        }
      } else {
        // 向上拖拽，中间项向下移动
        if (index < this.dragIndex) {
          return itemTotalHeight;
        }
      }
    }
    
    return 0;
  }
}
