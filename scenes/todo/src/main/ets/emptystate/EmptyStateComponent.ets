import { EmptyStateManager } from './EmptyStateManager';
import { EmptyStateTexts } from './EmptyStateConstants';
import { EmptyStateConfig } from './EmptyStateModel';

/**
 * 空状态组件 - 支持趣味文案和自定义功能
 * 可直接集成到现有首页空状态中
 */
@ComponentV2
export struct EmptyStateComponent {
  private manager: EmptyStateManager = EmptyStateManager.instance;
  
  @Local currentText: string = EmptyStateTexts.DEFAULT_TEXT;
  @Local isCustomMode: boolean = false;
  @Local customInputText: string = '';
  @Local showInputSheet: boolean = false;
  
  aboutToAppear(): void {
    // 初始化时获取当前文案
    this.refreshText();
    this.isCustomMode = this.manager.isCustomMode();
    this.customInputText = this.manager.getCustomText();
    // 调试日志
    console.info('[EmptyStateComponent] aboutToAppear - 当前文案:', this.currentText)
    console.info('[EmptyStateComponent] 是否自定义模式:', this.isCustomMode)
  }
  
  /**
   * 刷新显示文案
   */
  private refreshText(): void {
    this.currentText = this.manager.getCurrentText();
  }
  
  build() {
    Column({ space: 12 }) {
      // 空状态图标
      Image($r('app.media.todo_bg'))
        .width(100)
        .height(150)
      
      // 当前文案（可点击切换）
      Text(this.currentText)
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.font_tertiary'))
        .fontSize($r('sys.float.Body_M'))
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .onClick(() => {
          // 点击切换下一个系统文案
          this.manager.switchToSystemMode();
          this.currentText = this.manager.switchToNextSystemText();
          this.isCustomMode = false;
        })
      
      // 点击切换提示
      Text('点击切换')
        .fontSize(12)
        .fontColor($r('sys.color.font_tertiary'))
        .textAlign(TextAlign.Center)
        .onClick(() => {
          // 点击切换下一个系统文案
          this.manager.switchToSystemMode();
          this.currentText = this.manager.switchToNextSystemText();
          this.isCustomMode = false;
        })
      
      // 自定义文案按钮
      Text('自定义')
        .fontSize(12)
        .fontColor($r('sys.color.font_tertiary'))
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.showInputSheet = true;
        })
      
      // 如果是自定义模式，显示恢复系统文案按钮
      if (this.isCustomMode) {
        Text('系统文案')
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.manager.switchToSystemMode();
            this.currentText = this.manager.switchToNextSystemText();
            this.isCustomMode = false;
          })
      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .bindSheet($$this.showInputSheet, this.customInputSheet(), {
      height: SheetSize.FIT_CONTENT,
      preferType: SheetType.BOTTOM,
      showClose: false,
      dragBar: true
    })
  }
  
  /**
   * 自定义文案输入面板
   */
  @Builder
  customInputSheet() {
    Column() {
      // 标题
      Row() {
        Text('自定义空状态文案')
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .height(48)
      
      // 输入框
      Column() {
        TextArea({ 
          placeholder: '输入你喜欢的文案，比如：今天也是摸鱼的一天～',
          text: $$this.customInputText
        })
          .height(80)
          .width('100%')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .borderRadius(12)
          .maxLength(50)
          .fontColor($r('sys.color.font_primary'))
          .placeholderColor($r('sys.color.font_tertiary'))
        
        Text(`${this.customInputText.length}/50`)
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ top: 4 })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ top: 16 })
      
      // 操作按钮
      Row({ space: 12 }) {
        Button('取消')
          .width('45%')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.showInputSheet = false;
            this.customInputText = this.manager.getCustomText();
          })
        
        Button('保存')
          .width('45%')
          .backgroundColor($r('sys.color.interactive_focus'))
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(() => {
            if (this.customInputText.trim() !== '') {
              this.manager.setCustomText(this.customInputText.trim());
              this.currentText = this.manager.getCurrentText();
              this.isCustomMode = true;
              this.showInputSheet = false;
            } else {
              this.getUIContext().getPromptAction().showToast({
                message: '文案不能为空',
                duration: 2000
              });
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 24, bottom: 24 })
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}
