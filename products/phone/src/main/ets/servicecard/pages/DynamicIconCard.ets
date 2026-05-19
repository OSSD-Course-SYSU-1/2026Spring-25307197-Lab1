interface DateData {
  day?: string;
  month?: string;
  weekDay?: string;
}

@Entry
@Component
struct DynamicIconCard {
  @State day: string = '--';
  @State month: string = '--';
  @State weekDay: string = '--';
  @State bgColor: string = '#2196F3';
  
  // 接收卡片数据
  @Prop data: DateData = {};
  
  aboutToAppear(): void {
    // 优先使用传入的数据，如果没有则使用当前日期
    if (this.data && this.data.day && this.data.month && this.data.weekDay) {
      this.day = this.data.day;
      this.month = this.data.month;
      this.weekDay = this.data.weekDay;
      
      // 根据星期设置背景色
      const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
      const dayIndex = weekdays.indexOf(this.data.weekDay.replace('周', ''));
      if (dayIndex >= 0) {
        this.updateBgColor(dayIndex);
      }
    } else {
      this.updateDateInfo();
    }
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
      // 主容器 - 圆形背景
      Stack() {
        // 圆形背景
        Circle()
          .width(90)
          .height(90)
          .fill(this.bgColor)
          .shadow({ radius: 6, color: '#00000040', offsetX: 0, offsetY: 3 })
        
        // 日期显示区域
        Column() {
          // 月份 - 顶部小字
          Text(this.data.month || this.month)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .opacity(0.9)
            .margin({ bottom: 1 })
          
          // 日期 - 中间大字
          Text(this.data.day || this.day)
            .fontSize(28)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 1 })
          
          // 星期 - 底部小字
          Text(this.data.weekDay || this.weekDay)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .opacity(0.9)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width(90)
      .height(90)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}