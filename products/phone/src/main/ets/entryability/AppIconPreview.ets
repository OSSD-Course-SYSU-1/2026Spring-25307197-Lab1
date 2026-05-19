@Entry
@Component
struct AppIconPreview {
  @State day: string = '--';
  @State month: string = '--';
  @State weekDay: string = '--';
  @State bgColor: string = '#2196F3';
  
  aboutToAppear(): void {
    this.updateDateInfo();
  }
  
  updateDateInfo(): void {
    const now = new Date();
    const month = now.getMonth() + 1;
    const date = now.getDate();
    const dayOfWeek = now.getDay();
    const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
    
    // 设置日期（最大字体）
    this.day = date < 10 ? `0${date}` : `${date}`;
    
    // 设置月份（较小字体）
    this.month = `${month}月`;
    
    // 设置星期（较小字体）
    this.weekDay = `周${weekdays[dayOfWeek]}`;
    
    // 根据星期几设置不同的背景颜色
    this.updateBgColor(dayOfWeek);
  }
  
  updateBgColor(dayOfWeek: number): void {
    // 根据星期几设置不同的颜色
    const colors = [
      '#FF5722', // 周日 - 橙色
      '#2196F3', // 周一 - 蓝色
      '#4CAF50', // 周二 - 绿色
      '#9C27B0', // 周三 - 紫色
      '#FF9800', // 周四 - 琥珀色
      '#F44336', // 周五 - 红色
      '#607D8B'  // 周六 - 蓝灰色
    ];
    
    this.bgColor = colors[dayOfWeek];
  }
  
  build() {
    Column() {
      // 标题
      Text('动态日历图标预览')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      // 动态图标显示
      Stack() {
        // 圆形背景
        Circle()
          .width(100)
          .height(100)
          .fill(this.bgColor)
          .shadow({ radius: 8, color: '#00000040', offsetX: 0, offsetY: 4 })
        
        // 日期显示区域
        Column() {
          // 月份 - 顶部小字
          Text(this.month)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .opacity(0.9)
            .margin({ bottom: 2 })
          
          // 日期 - 中间大字
          Text(this.day)
            .fontSize(32)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 2 })
          
          // 星期 - 底部小字
          Text(this.weekDay)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .opacity(0.9)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width(100)
      .height(100)
      .margin({ bottom: 20 })
      
      // 信息显示
      Column() {
        Text(`当前日期: ${new Date().toLocaleDateString()}`)
          .fontSize(14)
          .margin({ bottom: 5 })
        
        Text(`月份: ${this.month}`)
          .fontSize(14)
          .margin({ bottom: 5 })
        
        Text(`日期: ${this.day}`)
          .fontSize(14)
          .margin({ bottom: 5 })
        
        Text(`星期: ${this.weekDay}`)
          .fontSize(14)
          .margin({ bottom: 5 })
        
        Text(`背景色: ${this.bgColor}`)
          .fontSize(14)
      }
      .padding(10)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .width('80%')
      
      // 更新按钮
      Button('更新日期')
        .margin({ top: 20 })
        .onClick(() => {
          this.updateDateInfo();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}