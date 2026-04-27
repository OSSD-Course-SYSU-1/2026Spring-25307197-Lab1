
@Component
export struct CardListComponent {
  @BuilderParam customBuilderParam: () => void = this.customBuilder;
  readonly fullWidthPercent = '100%';
  readonly fullHeightPercent = '100%';

  @Builder
  customBuilder() {
    // custom builder
  }

  build() {
    Column({ space: FlexAlign.Start }) {
      Column() {
        this.customBuilderParam();
      }
      .width(this.fullWidthPercent)
      .layoutWeight(1)
      .margin({ top: 8 })
    }
    .backgroundColor(Color.White)
    .padding(12)
    .height(this.fullHeightPercent)
    .width(this.fullWidthPercent)
  }
}