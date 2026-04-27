import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';
import { FeedbackItemType, PreferConstant, PreferenceUtil } from 'feed_back';
import { AppStorageV2 } from '@kit.ArkUI';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';

@Builder
export function FeedbackRecordPageBuilder() {
  FeedbackRecordPage();
}

@ComponentV2
export struct FeedbackRecordPage {
  @Local feedbackList: FeedbackItemType[] = []
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;


  aboutToAppear(): void {
    this.initData();
  }

  initData() {
    const rawData = PreferenceUtil.getInstance().get(PreferConstant.FEEDBACK_RECORD, []);
    this.feedbackList = (Array.isArray(rawData) ? rawData : []);
  }

  build() {
    NavDestination(){
      Column() {
        Column() {
          if (this.feedbackList.length > 0) {
            List() {
              ForEach(this.feedbackList, (item: FeedbackItemType) => {
                ListItem() {
                  Column() {
                    Text(item.time)
                      .fontSize($r('sys.float.Body_S'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                    Text('问题描述')
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 12, bottom: 8 })
                    Text(item.description)
                      .fontSize($r('sys.float.Body_S'))
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                      .lineHeight(20)
                    Text('问题截图')
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 12, bottom: 8 })
                    Row() {
                      ForEach(item.stageImageUris,
                        (item1: string) => {
                          Image(item1).width(80).height(80).margin({ right: 8 })
                        }, (item1: string, index: number) => item1 + index)
                    }
                  }
                  .backgroundColor($r('sys.color.comp_background_list_card'))
                  .padding(12)
                  .margin({ bottom: 12 })
                  .width('100%')
                  .borderRadius(16)
                  .alignItems(HorizontalAlign.Start)
                }
              }, (item: FeedbackItemType) => JSON.stringify(item))
            }.scrollBar(BarState.Off)
          } else {
            Column() {
              Text('您还没有提交反馈记录')
                .width('100%')
                .height('100%')
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
            }.width('100%').height(120)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .height('100%')
        .width('100%')
        .padding(new BreakpointType<Padding>({
          sm: {
            top: 10,
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8'),
          },
          md: {
            top: 10,
            left: $r('sys.float.padding_level12'),
            right: $r('sys.float.padding_level12'),
          },
          lg: {
            top: 10,
            left: $r('sys.float.padding_level16'),
            right: $r('sys.float.padding_level16'),
          },
        }).getValue(this.globalInfo.currentBreakpoint))
      }.height('100%').width('100%')
    }
    .title('反馈记录')
    .padding({ top: px2vp(this.avoidArea.topRectHeight)})
    .backgroundColor($r('sys.color.background_secondary'))
  }
}