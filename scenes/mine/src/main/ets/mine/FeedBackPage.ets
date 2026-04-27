import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';
import {  MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { Feedback, FeedbackItemType } from 'feed_back';
import { PreferenceUtil, PreferConstant } from 'feed_back';
import { AppStorageV2 } from '@kit.ArkUI';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';

@Builder
export function FeedBackPageBuilder() {
  FeedBackPage();
}

@ComponentV2
export struct FeedBackPage {
  @Local feedList: FeedbackItemType = {
    description: '',
    stageImageUris: [],
    phone: '',
    time: ''
  }
  vm: MainEntryVM = MainEntryVM.instance;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    NavDestination() {
      Column() {
        Scroll(){
          Column(){
            Feedback({
              des: 99,
              num: 3,
              butOnClick: (val: FeedbackItemType) => {
                this.feedList = val;
                let info = PreferenceUtil.getInstance().get(PreferConstant.FEEDBACK_RECORD, []) as FeedbackItemType[]
                let arr: FeedbackItemType[] = []
                info.forEach((model: FeedbackItemType) => {
                  arr.push(model)
                })
                arr.push(this.feedList)
                PreferenceUtil.getInstance().put(PreferConstant.FEEDBACK_RECORD, arr)
                this.getUIContext().getPromptAction().showToast({ message: '提交成功', duration: 2000 });
                this.vm.navStack.pop();
              }
            })
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .padding(new BreakpointType<Padding>({
        sm: {
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
        },
        md: {
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
        },
        lg: {
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
        },
      }).getValue(this.globalInfo.currentBreakpoint))
    }
    .title('反馈问题')
    .padding({ top: px2vp(this.avoidArea.topRectHeight)})
    .backgroundColor($r('sys.color.background_secondary'))
      }
}