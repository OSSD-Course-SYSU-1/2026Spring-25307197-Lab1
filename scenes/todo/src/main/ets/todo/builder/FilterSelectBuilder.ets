import { SheetCallbacks } from '../../types/Types';
import { CustomIcon } from '@ohos_agcit/daily_schedule_component_lib';
import { ButtonSelectComponent } from '../components/ButtonSelectComponent';
import { TodoDataManager } from '../../mock/TodoDataManager';
import { FilterInfo, ExtInfo } from '../../mock/TitleDataManager';

@Builder
export function filterSelectBuilder(callbacks: SheetCallbacks) {
  FilterSelectComponent({
    onConfirm: callbacks.onConfirm,
    onClose: callbacks.onClose
  });
}

@ComponentV2
struct FilterSelectComponent {
  statusManager: FilterInfo = FilterInfo.instance
  dataManager: TodoDataManager = TodoDataManager.instance
  extInfo: ExtInfo = ExtInfo.instance
  @Param statusLabel: string[] = ['全部', '已完成', '已过期']
  @Param priorityLabel: string[] = ['全部', '无', '低优先级', '中优先级', '高优先级']
  @Param onConfirm: () => void = () => {
  }
  @Param onClose: () => void = () => {
  }

  build() {
    Column() {
      Row() {
        CustomIcon({
          resource: $r('sys.symbol.xmark'),
          size: 40,
          fontSize: 20,
          fontColor: $r('sys.color.font_primary'),
          onClick: this.onClose
        })
        Text('筛选')
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .margin({ left: '2.5%' })
        Blank()
        CustomIcon({
          resource: $r('sys.symbol.checkmark'),
          size: 40,
          fontSize: 20,
          fontColor: $r('sys.color.font_primary'),
          onClick: this.onConfirm
        })
      }
      .padding('5%')
      .width('100%')

      Column() {
        Column() {
          Text('状态').fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium)
        }
        .height(40)
        .justifyContent(FlexAlign.Center)

        ButtonSelectComponent({
          selectIndex: this.statusManager.statusIndex,
          buttonLabel: this.statusLabel,
          areaHeight: 60,
          changeIndex: (newIndex: number) => {
            this.statusManager.statusIndex = newIndex
          }
        })
        Column() {
          Text('优先级').fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Medium)
        }
        .height(40)
        .justifyContent(FlexAlign.Center)

        ButtonSelectComponent({
          selectIndex: this.statusManager.priorityIndex,
          buttonLabel: this.priorityLabel,
          areaHeight: 100,
          changeIndex: (newIndex: number) => {
            this.statusManager.priorityIndex = newIndex
          }
        })

        // 甩出发送功能开关（在筛选菜单中也可访问）
        Column() {
          Row() {
            Text('甩出发送')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
            
            Blank()
            
            Toggle({ type: ToggleType.Switch, isOn: this.extInfo.isShareDragEnable })
              .onChange((isOn: boolean) => {
                this.extInfo.isShareDragEnable = isOn
              })
              .selectedColor($r('sys.color.multi_color_04'))
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .padding('5%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}