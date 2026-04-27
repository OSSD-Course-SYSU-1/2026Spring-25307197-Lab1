import { BreakpointType, GlobalInfoModel, readDataFromRawFile } from '@ohos_agcit/daily_schedule_utils';
import { AppStorageV2 } from '@kit.ArkUI';
import { MergeArrow } from '../components/SettingComponents';
import {  MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';

/**
 * 关于我们
 */
@Builder
export function PrivacySettingBuilder() {
  PrivacySetting();
}

@ComponentV2
export struct PrivacySetting {
  vm: MainEntryVM = MainEntryVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    NavDestination(){
      Column(){
        Scroll() {
          Column({ space: 12 }){
            MergeArrow({
              text1: '用户协议',
              text1Click: () => {
                let privacyUrl = readDataFromRawFile<string>('data.json', 'privacy_url');
                if (privacyUrl !== undefined) {
                  const params: Record<string, Object> = { 'protocolUrl':  privacyUrl};
                  this.vm.navStack.pushPathByName('PrivacyAgreement', params);
                }
              },
              text2: '隐私政策',
              text2Click: () => {
                let privacyUrl = readDataFromRawFile<string>('data.json', 'privacy_url');
                if (privacyUrl !== undefined) {
                  const params: Record<string, Object> = { 'protocolUrl':  privacyUrl};
                  this.vm.navStack.pushPathByName('PrivacyAgreement', params);
                }
              },
            })

            MergeArrow({
              text1: '第三方信息共享清单',
              text1Click: () => {
                let privacyUrl = readDataFromRawFile<string>('data.json', 'privacy_url');
                if (privacyUrl !== undefined) {
                  const params: Record<string, Object> = { 'protocolUrl':  privacyUrl};
                  this.vm.navStack.pushPathByName('PrivacyAgreement', params);
                }
              },
              text2: '个人信息收集清单',
              text2Click: () => {
                let privacyUrl = readDataFromRawFile<string>('data.json', 'privacy_url');
                if (privacyUrl !== undefined) {
                  const params: Record<string, Object> = { 'protocolUrl':  privacyUrl};
                  this.vm.navStack.pushPathByName('PrivacyAgreement', params);
                }
              },
            })
          }
          .width('100%')
        }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
      }
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
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: px2vp(this.avoidArea.topRectHeight)  })
    .title('隐私设置')
  }
}