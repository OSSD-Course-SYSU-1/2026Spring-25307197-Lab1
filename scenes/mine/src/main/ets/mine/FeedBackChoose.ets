import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';
import {  MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { AppStorageV2 } from '@kit.ArkUI';
import { SingleArrow } from '../components/SettingComponents';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';

@Builder
export function FeedBackChooseBuilder() {
  FeedBackChoose();
}

@ComponentV2
export struct FeedBackChoose {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;

  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    NavDestination() {
      Column({ space: 17 }) {
        SingleArrow({
          text: '反馈问题',
        })
          .onClick(() => {
            this.vm.navStack.pushPathByName('FeedBackPage', undefined);
          });

        SingleArrow({
          text: '反馈记录',
        })
          .onClick(() => {
            this.vm.navStack.pushPathByName('FeedbackRecordPage', undefined);
          });
      }
      .width('100%')
      .height('100%')
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
    }
    .padding({top: px2vp(this.avoidArea.topRectHeight) })
    .backgroundColor($r('sys.color.background_secondary'))
    .title('意见反馈');
  }
}


