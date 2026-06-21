import { curves } from '@kit.ArkUI';

/**
 * 粒子效果参数
 */
interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  opacity: number;
  color: string;
}

/**
 * 甩出动画效果组件
 * 提供粒子扩散、光晕、进度环等视觉效果
 */
@ComponentV2
export struct FlingAnimationEffects {
  // 是否显示动画
  @Param isVisible: boolean = false;
  
  // 动画中心位置
  @Param centerX: number = 0;
  @Param centerY: number = 0;
  
  // 动画类型
  @Param animationType: 'particle' | 'glow' | 'progress' | 'success' = 'particle';
  
  // 进度值 (0-1)
  @Param progress: number = 0;
  
  // 粒子颜色
  @Param particleColor: string = '#4CAF50';
  
  // 内部状态
  @Local particles: Particle[] = [];
  @Local glowOpacity: number = 0;
  @Local glowRadius: number = 0;
  @Local successScale: number = 0;
  @Local successOpacity: number = 0;
  @Local ringRotation: number = 0;
  
  private animationTimer: number = -1;
  
  aboutToAppear(): void {
    if (this.isVisible) {
      this.startAnimation();
    }
  }
  
  aboutToDisappear(): void {
    this.stopAnimation();
  }
  
  /**
   * 监听 isVisible 变化
   */
  @Monitor('isVisible')
  onVisibilityChange(): void {
    if (this.isVisible) {
      this.startAnimation();
    } else {
      this.stopAnimation();
    }
  }
  
  build() {
    Stack() {
      if (this.isVisible) {
        if (this.animationType === 'particle') {
          this.ParticleEffect()
        } else if (this.animationType === 'glow') {
          this.GlowEffect()
        } else if (this.animationType === 'progress') {
          this.ProgressRing()
        } else if (this.animationType === 'success') {
          this.SuccessAnimation()
        }
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }
  
  /**
   * 粒子扩散效果
   */
  @Builder
  ParticleEffect() {
    Stack() {
      ForEach(this.particles, (particle: Particle, index: number) => {
        Circle()
          .width(particle.size)
          .height(particle.size)
          .fill(particle.color)
          .opacity(particle.opacity)
          .position({
            x: this.centerX + particle.x - particle.size / 2,
            y: this.centerY + particle.y - particle.size / 2
          })
      }, (particle: Particle, index: number) => `particle_${index}`)
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * 光晕效果
   */
  @Builder
  GlowEffect() {
    Stack() {
      // 外层光晕
      Circle()
        .width(this.glowRadius * 2)
        .height(this.glowRadius * 2)
        .fill(this.particleColor)
        .opacity(this.glowOpacity * 0.3)
        .position({
          x: this.centerX - this.glowRadius,
          y: this.centerY - this.glowRadius
        })
      
      // 内层光晕
      Circle()
        .width(this.glowRadius)
        .height(this.glowRadius)
        .fill(this.particleColor)
        .opacity(this.glowOpacity * 0.6)
        .position({
          x: this.centerX - this.glowRadius / 2,
          y: this.centerY - this.glowRadius / 2
        })
      
      // 核心光点
      Circle()
        .width(20)
        .height(20)
        .fill('#FFFFFF')
        .opacity(this.glowOpacity)
        .position({
          x: this.centerX - 10,
          y: this.centerY - 10
        })
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * 进度环动画
   */
  @Builder
  ProgressRing() {
    Stack() {
      // 背景环
      Circle()
        .width(80)
        .height(80)
        .stroke('rgba(255, 255, 255, 0.2)')
        .strokeWidth(6)
        .fill(Color.Transparent)
        .position({
          x: this.centerX - 40,
          y: this.centerY - 40
        })
      
      // 进度环
      Circle()
        .width(80)
        .height(80)
        .stroke(this.particleColor)
        .strokeWidth(6)
        .fill(Color.Transparent)
        .position({
          x: this.centerX - 40,
          y: this.centerY - 40
        })
      
      // 旋转装饰
      Column() {
        Text(`${Math.round(this.progress * 100)}%`)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width(60)
      .height(60)
      .justifyContent(FlexAlign.Center)
      .borderRadius(30)
      .backgroundColor(this.particleColor)
      .opacity(0.9)
      .position({
        x: this.centerX - 30,
        y: this.centerY - 30
      })
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * 成功动画效果
   */
  @Builder
  SuccessAnimation() {
    Stack() {
      // 涟漪扩散
      Circle()
        .width(100 * this.successScale)
        .height(100 * this.successScale)
        .stroke(this.particleColor)
        .strokeWidth(3)
        .fill(Color.Transparent)
        .opacity(this.successOpacity * (1 - this.successScale))
        .position({
          x: this.centerX - 50 * this.successScale,
          y: this.centerY - 50 * this.successScale
        })
      
      // 成功图标
      Column() {
        Text('✓')
          .fontSize(32)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width(60)
      .height(60)
      .justifyContent(FlexAlign.Center)
      .borderRadius(30)
      .backgroundColor(this.particleColor)
      .opacity(this.successOpacity)
      .scale({ x: this.successScale, y: this.successScale })
      .position({
        x: this.centerX - 30,
        y: this.centerY - 30
      })
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * 启动动画
   */
  private startAnimation(): void {
    if (this.animationType === 'particle') {
      this.startParticleAnimation();
    } else if (this.animationType === 'glow') {
      this.startGlowAnimation();
    } else if (this.animationType === 'success') {
      this.startSuccessAnimation();
    }
  }
  
  /**
   * 停止动画
   */
  private stopAnimation(): void {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
      this.animationTimer = -1;
    }
  }
  
  /**
   * 粒子动画
   */
  private startParticleAnimation(): void {
    // 创建粒子
    this.particles = [];
    const particleCount = 20;
    
    for (let i = 0; i < particleCount; i++) {
      const angle = (Math.PI * 2 / particleCount) * i + Math.random() * 0.5;
      const speed = 3 + Math.random() * 3;
      
      this.particles.push({
        x: 0,
        y: 0,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        size: 4 + Math.random() * 6,
        opacity: 1,
        color: this.particleColor
      });
    }
    
    // 更新粒子位置
    let frame = 0;
    const maxFrames = 40;
    
    this.animationTimer = setInterval(() => {
      frame++;
      
      this.particles = this.particles.map((particle: Particle) => {
        // 创建新粒子对象而不是使用 spread
        const newParticle: Particle = {
          x: particle.x + particle.vx,
          y: particle.y + particle.vy,
          vx: particle.vx,
          vy: particle.vy,
          opacity: Math.max(0, 1 - frame / maxFrames),
          size: particle.size * 0.98,
          color: particle.color
        };
        return newParticle;
      });
      
      if (frame >= maxFrames) {
        this.stopAnimation();
        // isVisible 由父组件控制，不需要在这里设置
      }
    }, 16);
  }
  
  /**
   * 光晕动画
   */
  private startGlowAnimation(): void {
    let frame = 0;
    const maxFrames = 30;
    
    this.animationTimer = setInterval(() => {
      frame++;
      const progress = frame / maxFrames;
      
      // 光晕扩散
      this.glowRadius = progress * 100;
      this.glowOpacity = Math.sin(progress * Math.PI);
      
      if (frame >= maxFrames) {
        this.stopAnimation();
        // isVisible 由父组件控制，不需要在这里设置
      }
    }, 16);
  }
  
  /**
   * 成功动画
   */
  private startSuccessAnimation(): void {
    let frame = 0;
    const maxFrames = 25;
    
    this.animationTimer = setInterval(() => {
      frame++;
      const progress = frame / maxFrames;
      
      // 缩放和透明度
      this.successScale = Math.min(1, progress * 1.5);
      this.successOpacity = Math.sin(progress * Math.PI * 0.5);
      
      if (frame >= maxFrames) {
        // isVisible 由父组件控制，不需要在这里设置
        this.stopAnimation();
      }
    }, 16);
  }
}

/**
 * 拖拽方向指示器
 */
@ComponentV2
export struct DragDirectionIndicator {
  // 拖拽偏移
  @Param offsetX: number = 0;
  @Param offsetY: number = 0;
  
  // 是否显示
  @Param isVisible: boolean = false;
  
  // 速度强度 (用于显示颜色)
  @Param velocity: number = 0;
  
  build() {
    if (this.isVisible && (this.offsetX !== 0 || this.offsetY !== 0)) {
      Stack() {
        // 方向箭头
        Column() {
          Text('→')
            .fontSize(24)
            .fontColor(this.getIndicatorColor())
            .fontWeight(FontWeight.Bold)
            .rotate({ angle: this.getDirectionAngle() })
        }
        .width(50)
        .height(50)
        .justifyContent(FlexAlign.Center)
        .borderRadius(25)
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .shadow({
          radius: 10,
          color: 'rgba(0, 0, 0, 0.2)',
          offsetX: 0,
          offsetY: 2
        })
      }
      .position({
        x: this.offsetX - 25,
        y: this.offsetY - 25
      })
    }
  }
  
  /**
   * 获取方向角度
   */
  private getDirectionAngle(): number {
    if (this.offsetX === 0 && this.offsetY === 0) {
      return 0;
    }
    return Math.atan2(this.offsetY, this.offsetX) * 180 / Math.PI;
  }
  
  /**
   * 获取指示器颜色
   */
  private getIndicatorColor(): string {
    // 根据速度强度显示不同颜色
    if (this.velocity >= 18) {
      return '#4CAF50'; // 绿色 - 可以甩出
    } else if (this.velocity >= 10) {
      return '#FF9800'; // 橙色 - 接近甩出阈值
    } else {
      return '#9E9E9E'; // 灰色 - 速度不够
    }
  }
}

/**
 * 发送状态动画组件
 */
@ComponentV2
export struct SendStatusAnimation {
  // 状态: 'preparing' | 'sending' | 'success' | 'failed'
  @Param status: string = 'preparing';
  
  // 是否显示
  @Param isVisible: boolean = false;
  
  @Local rotation: number = 0;
  @Local animScale: number = 1;
  @Local animOpacity: number = 1;
  
  private animationTimer: number = -1;
  
  aboutToAppear(): void {
    if (this.isVisible && this.status === 'sending') {
      this.startSendingAnimation();
    }
  }
  
  aboutToDisappear(): void {
    this.stopAnimation();
  }
  
  build() {
    if (this.isVisible) {
      Column() {
        if (this.status === 'preparing') {
          this.PreparingView()
        } else if (this.status === 'sending') {
          this.SendingView()
        } else if (this.status === 'success') {
          this.SuccessView()
        } else if (this.status === 'failed') {
          this.FailedView()
        }
      }
      .width(120)
      .height(120)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('rgba(0, 0, 0, 0.7)')
      .borderRadius(60)
      .opacity(this.animOpacity)
      .scale({ x: this.animScale, y: this.animScale })
    }
  }
  
  @Builder
  PreparingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#FFFFFF')
      
      Text('准备发送')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .margin({ top: 8 })
    }
  }
  
  @Builder
  SendingView() {
    Column() {
      Stack() {
        // 外圈旋转
        Circle()
          .width(50)
          .height(50)
          .stroke('#4CAF50')
          .strokeWidth(3)
          .fill(Color.Transparent)
          .rotate({ angle: this.rotation })
        
        // 内圈反向旋转
        Circle()
          .width(35)
          .height(35)
          .stroke('#FFFFFF')
          .strokeWidth(2)
          .fill(Color.Transparent)
          .rotate({ angle: -this.rotation * 1.5 })
      }
      .width(50)
      .height(50)
      
      Text('发送中...')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .margin({ top: 8 })
    }
  }
  
  @Builder
  SuccessView() {
    Column() {
      Text('✓')
        .fontSize(40)
        .fontColor('#4CAF50')
        .fontWeight(FontWeight.Bold)
      
      Text('发送成功')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .margin({ top: 8 })
    }
  }
  
  @Builder
  FailedView() {
    Column() {
      Text('✗')
        .fontSize(40)
        .fontColor('#F44336')
        .fontWeight(FontWeight.Bold)
      
      Text('发送失败')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .margin({ top: 8 })
    }
  }
  
  private startSendingAnimation(): void {
    this.animationTimer = setInterval(() => {
      this.rotation += 5;
    }, 16);
  }
  
  private stopAnimation(): void {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
      this.animationTimer = -1;
    }
  }
}
