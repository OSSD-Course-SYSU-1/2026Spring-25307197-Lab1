@ComponentV2
export struct SegmentButton {
  @Param tabOptions: string[] = [];
  @Param buttonWidth: number | Resource | string = '100%';
  @Param activeButtonHeight: number | Resource | string = 35;
  @Param buttonHeight: number | Resource | string = 36;
  @Param buttonRadius: number | Resource = 16;
  @Param buttonBgColor: number | Resource | string = '#ddd';
  @Param textFontColor: number | Resource | string = '#000';
  @Param textActiveBgColor: number | Resource | string = 'blue';
  @Param textActiveFontColor: number | Resource | string = '#fff';
  @Param controller: SegmentController = new SegmentController(0);

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Text() {
      }
      .borderRadius(this.buttonRadius)
      .backgroundColor(this.textActiveBgColor)
      .width(`${1 / this.tabOptions.length * 100}%`)
      .height(this.activeButtonHeight)
      .offset({
        left: `${1 * this.controller.activeIndex / this.tabOptions.length * 100}%`
      })
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })

      Row() {
        ForEach(this.tabOptions, (item: string, index: number) => {
          Text(item)
            .height(this.buttonHeight)
            .layoutWeight(1)
            .fontColor(this.controller.activeIndex === index ? this.textActiveFontColor : this.textFontColor)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.controller.updateActiveIndex(index);
            })
        }, (item: string) => item)
      }
    }
    .width(this.buttonWidth)
    .height(this.buttonHeight)
    .borderRadius(this.buttonRadius)
    .backgroundColor(this.buttonBgColor)
  }
}

@ObservedV2
export class SegmentController {
  @Trace activeIndex: number;
  @Trace callback: Function | null;

  constructor(activeIndex: number = 0, callback?: Function) {
    this.activeIndex = activeIndex;
    this.callback = callback || null;
  }

  updateActiveIndex(index: number) {
    this.activeIndex = index;
    this.callback && this.callback(index)
  }
}