import { pullUpAppGallery } from '../utils/AppUpdateUtil';
import { common } from '@kit.AbilityKit';
import { Params } from '../model/Params';
import { DialogUtil } from '@ohos_agcit/daily_schedule_utils';

@Builder
export function findNewVersion(params: Params){
  FindNewVersion({
    params: params
  })
}

@ComponentV2
struct FindNewVersion{
  @Param @Require params: Params;

  build() {
    Column(){
      // todo
      // 0 不存在新版本， 1 存在新版本
      Text(this.params.text === 0 ? '未发现新版本, 开始mock' : '发现新版本')
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .alignSelf(ItemAlign.Start)
        .padding({
          top: 15,
          bottom: 27
        })

      Column({ space: 4 }){
        Row({space: 10}){
          Text('应用')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
          Text('日历日程')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }

        Row({space: 10}){
          Text('版本')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
          Text('1.0.2.303')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }

        Row({space: 10}){
          Text('大小')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
          Text('50MB')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)


      Text('详情')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .padding({
          top: 24,
          bottom: 12
        })

      Text('1、新增 日历日程添加表情\n' +
        '2、优化 日历日程应用闪退问题\n' +
        '3、修复 若干bug')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .alignSelf(ItemAlign.Start)
        .lineHeight(22)


      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Text('以后再说')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.icon_emphasize'))
          .onClick(() => {
            DialogUtil.closeDialog();
          })

        Text('立即更新')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.icon_emphasize'))
          .onClick(() => {
            pullUpAppGallery(DialogUtil.ctx.getHostContext() as common.UIAbilityContext);
          })
      }
      .padding({
        top: 21
      })
    }
    .width('90%')
    .height(310)
    .borderRadius(32)
    .padding({
      left: 24,
      right: 24
    })
    .backgroundColor(this.params.bgColor)
  }
}