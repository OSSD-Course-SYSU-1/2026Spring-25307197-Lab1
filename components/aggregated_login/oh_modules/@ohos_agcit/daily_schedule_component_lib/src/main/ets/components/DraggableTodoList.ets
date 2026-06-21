import { TodoItem } from '@ohos_agcit/daily_schedule_common_lib';
import { curves } from '@kit.ArkUI';

/**
 * 可拖拽待办列表组件
 * 支持长按拖动、悬浮预览和物理甩动效果
 * 专为待办事项设计
 */
@ComponentV2
export struct DraggableTodoList {
  // 待办事项数据
  @Param todoItems: TodoItem[] = [];
  // 列表项高度
  @Param itemHeight: number = 76;
  // 列表项间距
  @Param itemSpacing: number = 12;
  // 长按触发时间
  @Param longPressDuration: number = 500;
  // 最大标题长度
  @Param maxTitleLen: number = 16;
  // 删除回调
  @Param onDelete: (taskID: string) => void = () => {};
  // 修改回调
  @Param onModify: (taskID: string) => void = () => {};
  // 完成状态改变回调
  @Param onFinishChange: (taskID: string, isFinished: boolean) => void = () => {};
  // 拖拽结束回调
  @Param onDragEndCallback: (fromIndex: number, toIndex: number) => void = () => {};
  // 列表项构建器（自定义外观）
  @BuilderParam customItemBuilder?: (item: TodoItem, index: number, isDragging: boolean) => void;

  // 拖拽状态
  @Local isDragging: boolean = false;
  @Local dragIndex: number = -1;
  @Local dragOffsetY: number = 0;
  @Local velocityY: number = 0;
  @Local targetIndex: number = -1;
  @Local flingOffset: number = 0;
  @Local flingVelocity: number = 0;
  @Local isFlinging: boolean = false;

  // 滚动控制器
  private scroller: Scroller = new Scroller();
  private lastMoveY: number = 0;
  private lastMoveTime: number = 0;
  private velocityHistory: number[] = [];
  private readonly VELOCITY_HISTORY_SIZE: number = 5;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 主列表
      List({ scroller: this.scroller, space: this.itemSpacing }) {
        ForEach(this.todoItems, (item: TodoItem, index: number) => {
          ListItem() {
            if (this.isDragging && index === this.dragIndex) {
              // 拖拽项占位
              Column()
                .width('100%')
                .height(this.itemHeight)
                .opacity(0.15)
                .borderRadius(16)
                .backgroundColor($r('sys.color.background_tertiary'))
            } else {
              // 正常列表项
              Column() {
                if (this.customItemBuilder) {
                  this.customItemBuilder(item, index, this.isDragging && index === this.dragIndex)
                } else {
                  this.defaultItemBuilder(item, index)
                }
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
        }, (item: TodoItem) => item.taskID)
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(this.isDragging ? HitTestMode.None : HitTestMode.Default)

      // 悬浮预览
      if (this.isDragging && this.dragIndex >= 0 && this.dragIndex < this.todoItems.length) {
        Column() {
          if (this.customItemBuilder) {
            this.customItemBuilder(this.todoItems[this.dragIndex], this.dragIndex, true)
          } else {
            this.defaultItemBuilder(this.todoItems[this.dragIndex], this.dragIndex)
          }
        }
        .width('100%')
        .height(this.itemHeight)
        .scale({ x: 1.05, y: 1.05 })
        .shadow({
          radius: 30,
          color: 'rgba(0, 0, 0, 0.25)',
          offsetX: 0,
          offsetY: 10
        })
        .opacity(0.98)
        .offset({ y: this.dragOffsetY + this.flingOffset })
        .zIndex(999)
        .gesture(
          PanGesture({ direction: PanDirection.Vertical })
            .onActionStart(() => {
              this.lastMoveY = 0;
              this.lastMoveTime = Date.now();
              this.velocityHistory = [];
            })
            .onActionUpdate((event: GestureEvent) => {
              const currentTime = Date.now();
              const deltaTime = currentTime - this.lastMoveTime;

              if (deltaTime > 0) {
                const instantVelocity = (event.offsetY - this.lastMoveY) / deltaTime * 16.67;
                this.velocityHistory.push(instantVelocity);
                if (this.velocityHistory.length > this.VELOCITY_HISTORY_SIZE) {
                  this.velocityHistory.shift();
                }
                this.velocityY = this.velocityHistory.reduce((a, b) => a + b, 0) / this.velocityHistory.length;
              }

              this.lastMoveY = event.offsetY;
              this.lastMoveTime = currentTime;
              this.dragOffsetY = event.offsetY;
              this.updateTargetIndex();
            })
            .onActionEnd(() => {
              this.startFling();
            })
        )
      }
    }
    .width('100%')
    .height('100%')
  }

  // 默认列表项构建器
  @Builder
  defaultItemBuilder(item: TodoItem, index: number) {
    Row() {
      // 复选框
      Column() {
        Checkbox()
          .select(item.isFinished)
          .unselectedColor(this.chooseCheckBoxColor(item))
          .selectedColor($r('sys.color.icon_tertiary'))
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .mark({
            strokeColor: $r('sys.color.comp_background_primary_contrary'),
          })
          .onChange((value: boolean) => {
            this.onFinishChange(item.taskID, value);
          })
          .margin({ top: 11 })
      }
      .height('100%')
      .justifyContent(FlexAlign.Start)

      // 内容
      Column() {
        Text(item.title.length > this.maxTitleLen ? 
          item.title.substring(0, this.maxTitleLen) + '...' : item.title)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(this.chooseTitleColor(item))
          .maxLines(1)

        Blank().height(12)

        Text(item.planTime.toString())
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.choosePlainTimeColor(item))
      }
      .margin({ left: 6, top: 12 })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 拖拽提示图标
      Text('⋮⋮')
        .fontSize(14)
        .fontColor($r('sys.color.font_tertiary'))
        .opacity(0.4)
        .margin({ right: 8 })
    }
    .padding({ left: 14, right: 14 })
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
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
    newTargetIndex = Math.max(0, Math.min(this.todoItems.length - 1, newTargetIndex));

    this.targetIndex = newTargetIndex;
  }

  // 开始物理甩动
  private startFling(): void {
    this.flingVelocity = this.velocityY * 2;
    this.flingOffset = 0;
    this.isFlinging = true;
    this.animateFling();
  }

  // 甩动动画
  private animateFling(): void {
    if (!this.isFlinging) return;

    const targetOffset = this.calcTargetOffset();

    if (Math.abs(this.flingVelocity) < 1 || Math.abs(this.flingOffset - targetOffset) < 5) {
      this.flingOffset = targetOffset;
      this.endDrag();
      return;
    }

    this.flingVelocity *= 0.82;
    this.flingOffset += this.flingVelocity;

    // 边界弹性
    const maxOffset = this.calcMaxFlingOffset();
    const minOffset = -this.calcMinFlingOffset();

    if (this.flingOffset > maxOffset) {
      this.flingOffset = maxOffset + (this.flingOffset - maxOffset) * 0.35;
      this.flingVelocity *= -0.35;
    } else if (this.flingOffset < minOffset) {
      this.flingOffset = minOffset + (this.flingOffset - minOffset) * 0.35;
      this.flingVelocity *= -0.35;
    }

    this.updateTargetIndex();

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
    return (this.todoItems.length - 1 - this.dragIndex) * itemTotalHeight;
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
      this.onDragEndCallback(this.dragIndex, this.targetIndex);
    }

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

    if (index === this.dragIndex) return 0;

    const minIndex = Math.min(this.dragIndex, this.targetIndex);
    const maxIndex = Math.max(this.dragIndex, this.targetIndex);

    if (index >= minIndex && index <= maxIndex) {
      if (this.dragIndex < this.targetIndex) {
        if (index > this.dragIndex) {
          return -itemTotalHeight;
        }
      } else {
        if (index < this.dragIndex) {
          return itemTotalHeight;
        }
      }
    }

    return 0;
  }

  // 选择标题颜色
  private chooseTitleColor(item: TodoItem): ResourceColor {
    if (item.isFinished) {
      return $r('sys.color.font_tertiary')
    }
    return $r('sys.color.icon_primary');
  }

  // 选择时间颜色
  private choosePlainTimeColor(item: TodoItem): ResourceColor {
    if (item.isFinished) {
      return $r('sys.color.font_tertiary')
    }
    return $r('sys.color.icon_primary');
  }

  // 选择复选框颜色
  private chooseCheckBoxColor(item: TodoItem): ResourceColor {
    // 根据优先级返回不同颜色
    if (item.priorityType === 1) { // LOW
      return $r('sys.color.multi_color_04')
    }
    if (item.priorityType === 2) { // MID
      return $r('sys.color.alert')
    }
    if (item.priorityType === 3) { // HIGH
      return $r('sys.color.warning')
    }
    return $r('sys.color.font_tertiary')
  }
}
