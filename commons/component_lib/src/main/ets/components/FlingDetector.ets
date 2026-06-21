import { curves } from '@kit.ArkUI';

/**
 * 甩动方向枚举
 */
export enum FlingDirection {
  NONE = 0,      // 无方向
  UP = 1,        // 向上甩出
  DOWN = 2,      // 向下甩出
  LEFT = 3,      // 向左甩出
  RIGHT = 4      // 向右甩出
}

/**
 * 甩动事件信息
 */
export interface FlingEvent {
  direction: FlingDirection;    // 甩动方向
  velocity: number;             // 甩动速度 (像素/帧)
  velocityX: number;            // X方向速度
  velocityY: number;            // Y方向速度
  offsetX: number;              // X方向偏移
  offsetY: number;              // Y方向偏移
  duration: number;             // 拖拽持续时间 (毫秒)
}

/**
 * 甩动检测器组件
 * 监听拖拽手势的甩动方向和速度，向外快速甩出时触发发送事件
 */
@ComponentV2
export struct FlingDetector {
  // 子组件内容
  @BuilderParam content: () => void;

  // 触发甩出事件的最小速度阈值 (像素/帧)
  @Param minFlingVelocity: number = 15;

  // 触发甩出事件的最小偏移距离 (像素)
  @Param minFlingDistance: number = 100;

  // 拖拽方向限制
  @Param panDirection: PanDirection = PanDirection.All;

  // 长按触发时间 (毫秒)，0表示不需要长按
  @Param longPressDuration: number = 0;

  // 甩出事件回调
  @Param onFling: (event: FlingEvent) => void = () => {};

  // 拖拽开始回调
  @Param onDragBegin: () => void = () => {};

  // 拖拽更新回调
  @Param onDragUpdate: (offsetX: number, offsetY: number) => void = () => {};

  // 拖拽结束回调 (未触发甩出时)
  @Param onDragFinish: () => void = () => {};

  // 内部状态
  @Local isDragging: boolean = false;
  @Local dragOffsetX: number = 0;
  @Local dragOffsetY: number = 0;

  // 速度计算相关
  private lastOffsetX: number = 0;
  private lastOffsetY: number = 0;
  private lastMoveTime: number = 0;
  private velocityHistoryX: number[] = [];
  private velocityHistoryY: number[] = [];
  private readonly VELOCITY_HISTORY_SIZE: number = 5;
  private dragStartTime: number = 0;

  // 最终速度
  private velocityX: number = 0;
  private velocityY: number = 0;

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .height('100%')
    .gesture(
      this.longPressDuration > 0
        ? LongPressGesture({ repeat: false, duration: this.longPressDuration })
            .onAction(() => {
              this.startDrag();
            })
        : PanGesture({ direction: this.panDirection })
            .onActionStart((event: GestureEvent) => {
              this.startDrag();
            })
            .onActionUpdate((event: GestureEvent) => {
              this.updateDrag(event);
            })
            .onActionEnd(() => {
              this.endDrag();
            })
    )
    .parallelGesture(
      this.longPressDuration > 0
        ? PanGesture({ direction: this.panDirection })
          .onActionStart((event: GestureEvent) => {
            if (this.isDragging) {
              this.lastOffsetX = 0;
              this.lastOffsetY = 0;
              this.lastMoveTime = Date.now();
              this.velocityHistoryX = [];
              this.velocityHistoryY = [];
            }
          })
          .onActionUpdate((event: GestureEvent) => {
            if (this.isDragging) {
              this.updateDrag(event);
            }
          })
          .onActionEnd(() => {
            if (this.isDragging) {
              this.endDrag();
            }
          })
        : PanGesture({ direction: PanDirection.All })
            .onActionStart(() => {})
    )
  }

  // 开始拖拽
  private startDrag(): void {
    this.isDragging = true;
    this.dragOffsetX = 0;
    this.dragOffsetY = 0;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
    this.lastMoveTime = Date.now();
    this.dragStartTime = Date.now();
    this.velocityHistoryX = [];
    this.velocityHistoryY = [];
    this.velocityX = 0;
    this.velocityY = 0;
    this.onDragBegin();
  }

  // 更新拖拽
  private updateDrag(event: GestureEvent): void {
    const currentTime = Date.now();
    const deltaTime = currentTime - this.lastMoveTime;

    if (deltaTime > 0) {
      // 计算瞬时速度 (像素/帧, 假设60fps, 每帧约16.67ms)
      const instantVelocityX = (event.offsetX - this.lastOffsetX) / deltaTime * 16.67;
      const instantVelocityY = (event.offsetY - this.lastOffsetY) / deltaTime * 16.67;

      // 更新速度历史
      this.velocityHistoryX.push(instantVelocityX);
      this.velocityHistoryY.push(instantVelocityY);

      if (this.velocityHistoryX.length > this.VELOCITY_HISTORY_SIZE) {
        this.velocityHistoryX.shift();
        this.velocityHistoryY.shift();
      }

      // 计算平均速度
      this.velocityX = this.velocityHistoryX.reduce((a, b) => a + b, 0) / this.velocityHistoryX.length;
      this.velocityY = this.velocityHistoryY.reduce((a, b) => a + b, 0) / this.velocityHistoryY.length;
    }

    this.lastOffsetX = event.offsetX;
    this.lastOffsetY = event.offsetY;
    this.lastMoveTime = currentTime;

    this.dragOffsetX = event.offsetX;
    this.dragOffsetY = event.offsetY;

    this.onDragUpdate(event.offsetX, event.offsetY);
  }

  // 结束拖拽
  private endDrag(): void {
    if (!this.isDragging) return;

    // 计算总速度
    const totalVelocity = Math.sqrt(this.velocityX * this.velocityX + this.velocityY * this.velocityY);
    const totalOffset = Math.sqrt(this.dragOffsetX * this.dragOffsetX + this.dragOffsetY * this.dragOffsetY);
    const duration = Date.now() - this.dragStartTime;

    // 判断是否触发甩出事件
    const isFling = totalVelocity >= this.minFlingVelocity && totalOffset >= this.minFlingDistance;

    if (isFling) {
      // 确定甩动方向
      const direction = this.determineFlingDirection();

      // 触发甩出事件
      const flingEvent: FlingEvent = {
        direction: direction,
        velocity: totalVelocity,
        velocityX: this.velocityX,
        velocityY: this.velocityY,
        offsetX: this.dragOffsetX,
        offsetY: this.dragOffsetY,
        duration: duration
      };

      this.onFling(flingEvent);
    } else {
      this.onDragFinish();
    }

    // 重置状态
    this.isDragging = false;
    this.dragOffsetX = 0;
    this.dragOffsetY = 0;
  }

  // 确定甩动方向
  private determineFlingDirection(): FlingDirection {
    const absX = Math.abs(this.velocityX);
    const absY = Math.abs(this.velocityY);

    // 判断主要方向
    if (absX > absY) {
      // 水平方向为主
      return this.velocityX > 0 ? FlingDirection.RIGHT : FlingDirection.LEFT;
    } else {
      // 垂直方向为主
      return this.velocityY > 0 ? FlingDirection.DOWN : FlingDirection.UP;
    }
  }
}

/**
 * 可甩出的卡片组件
 * 支持四个方向的甩出操作
 */
@ComponentV2
export struct FlingCard {
  // 卡片内容
  @BuilderParam content: () => void;

  // 触发甩出事件的最小速度阈值
  @Param minFlingVelocity: number = 18;

  // 甩出动画持续时间
  @Param flingDuration: number = 300;

  // 向上甩出回调
  @Param onFlingUp: () => void = () => {};

  // 向下甩出回调
  @Param onFlingDown: () => void = () => {};

  // 向左甩出回调
  @Param onFlingLeft: () => void = () => {};

  // 向右甩出回调
  @Param onFlingRight: () => void = () => {};

  // 内部状态
  @Local isDragging: boolean = false;
  @Local dragOffsetX: number = 0;
  @Local dragOffsetY: number = 0;
  @Local isFlingOut: boolean = false;
  @Local flingDirection: FlingDirection = FlingDirection.NONE;
  @Local opacityValue: number = 1;

  // 速度计算相关
  private lastOffsetX: number = 0;
  private lastOffsetY: number = 0;
  private lastMoveTime: number = 0;
  private velocityHistoryX: number[] = [];
  private velocityHistoryY: number[] = [];
  private readonly VELOCITY_HISTORY_SIZE: number = 5;
  private velocityX: number = 0;
  private velocityY: number = 0;

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .height('100%')
    .offset({ x: this.dragOffsetX, y: this.dragOffsetY })
    .opacity(this.opacityValue)
    .scale({
      x: this.isDragging ? 1.02 : 1,
      y: this.isDragging ? 1.02 : 1
    })
    .shadow(this.isDragging ? {
      radius: 25,
      color: 'rgba(0, 0, 0, 0.3)',
      offsetX: 0,
      offsetY: 8
    } : undefined)
    .gesture(
      PanGesture({ direction: PanDirection.All })
        .onActionStart(() => {
          this.startDrag();
        })
        .onActionUpdate((event: GestureEvent) => {
          this.updateDrag(event);
        })
        .onActionEnd(() => {
          this.endDrag();
        })
    )
  }

  private startDrag(): void {
    this.isDragging = true;
    this.dragOffsetX = 0;
    this.dragOffsetY = 0;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
    this.lastMoveTime = Date.now();
    this.velocityHistoryX = [];
    this.velocityHistoryY = [];
    this.velocityX = 0;
    this.velocityY = 0;
  }

  private updateDrag(event: GestureEvent): void {
    const currentTime = Date.now();
    const deltaTime = currentTime - this.lastMoveTime;

    if (deltaTime > 0) {
      const instantVelocityX = (event.offsetX - this.lastOffsetX) / deltaTime * 16.67;
      const instantVelocityY = (event.offsetY - this.lastOffsetY) / deltaTime * 16.67;

      this.velocityHistoryX.push(instantVelocityX);
      this.velocityHistoryY.push(instantVelocityY);

      if (this.velocityHistoryX.length > this.VELOCITY_HISTORY_SIZE) {
        this.velocityHistoryX.shift();
        this.velocityHistoryY.shift();
      }

      this.velocityX = this.velocityHistoryX.reduce((a, b) => a + b, 0) / this.velocityHistoryX.length;
      this.velocityY = this.velocityHistoryY.reduce((a, b) => a + b, 0) / this.velocityHistoryY.length;
    }

    this.lastOffsetX = event.offsetX;
    this.lastOffsetY = event.offsetY;
    this.lastMoveTime = currentTime;

    this.dragOffsetX = event.offsetX;
    this.dragOffsetY = event.offsetY;
  }

  private endDrag(): void {
    const totalVelocity = Math.sqrt(this.velocityX * this.velocityX + this.velocityY * this.velocityY);
    const totalOffset = Math.sqrt(this.dragOffsetX * this.dragOffsetX + this.dragOffsetY * this.dragOffsetY);

    // 判断是否触发甩出
    if (totalVelocity >= this.minFlingVelocity && totalOffset >= 80) {
      const absX = Math.abs(this.velocityX);
      const absY = Math.abs(this.velocityY);
      let direction: FlingDirection;

      if (absX > absY) {
        direction = this.velocityX > 0 ? FlingDirection.RIGHT : FlingDirection.LEFT;
      } else {
        direction = this.velocityY > 0 ? FlingDirection.DOWN : FlingDirection.UP;
      }

      this.flingDirection = direction;
      this.isFlingOut = true;

      // 执行甩出动画
      this.animateFlingOut(direction);
    } else {
      // 回弹动画
      this.animateBounceBack();
    }
  }

  private animateFlingOut(direction: FlingDirection): void {
    const screenWidth = 500; // 可根据实际情况调整
    const screenHeight = 1000;

    let targetX = 0;
    let targetY = 0;

    switch (direction) {
      case FlingDirection.LEFT:
        targetX = -screenWidth;
        break;
      case FlingDirection.RIGHT:
        targetX = screenWidth;
        break;
      case FlingDirection.UP:
        targetY = -screenHeight;
        break;
      case FlingDirection.DOWN:
        targetY = screenHeight;
        break;
    }

    animateTo({
      duration: this.flingDuration,
      curve: curves.springMotion(0.6, 0.8),
      onFinish: () => {
        this.triggerFlingCallback(direction);
        // 重置状态
        this.resetState();
      }
    }, () => {
      this.dragOffsetX = targetX;
      this.dragOffsetY = targetY;
      this.opacityValue = 0;
    });
  }

  private animateBounceBack(): void {
    animateTo({
      duration: 250,
      curve: curves.springMotion(0.6, 0.8)
    }, () => {
      this.dragOffsetX = 0;
      this.dragOffsetY = 0;
      this.isDragging = false;
    });
  }

  private triggerFlingCallback(direction: FlingDirection): void {
    switch (direction) {
      case FlingDirection.UP:
        this.onFlingUp();
        break;
      case FlingDirection.DOWN:
        this.onFlingDown();
        break;
      case FlingDirection.LEFT:
        this.onFlingLeft();
        break;
      case FlingDirection.RIGHT:
        this.onFlingRight();
        break;
    }
  }

  private resetState(): void {
    this.isDragging = false;
    this.isFlingOut = false;
    this.dragOffsetX = 0;
    this.dragOffsetY = 0;
    this.opacityValue = 1;
    this.flingDirection = FlingDirection.NONE;
  }
}
