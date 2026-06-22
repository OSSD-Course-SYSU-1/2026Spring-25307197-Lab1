/**
 * 设备选择弹窗组件
 * 用于显示在线设备列表，支持用户选择目标设备进行任务流转
 */
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { DeviceInfo } from '../utils/DistributedTransferUtil';

const DOMAIN = 0x0000;
const TAG = 'DeviceSelectDialog';

// 设备类型描述
function getDeviceTypeDesc(deviceType: number): string {
  switch (deviceType) {
    case 0x00:
      return '未知设备';
    case 0x01:
      return '手机';
    case 0x02:
      return '平板';
    case 0x03:
      return '智慧屏';
    case 0x04:
      return '智能手表';
    case 0x05:
      return '车机';
    case 0x06:
      return 'PC';
    default:
      return '其他设备';
  }
}

@CustomDialog
export struct DeviceSelectDialog {
  controller: CustomDialogController;
  // 设备选择回调
  onDeviceSelected: (device: DeviceInfo) => void = () => {};
  // 设备列表
  @State deviceList: DeviceInfo[] = [];
  // 加载状态
  @State isLoading: boolean = true;
  // 错误信息
  @State errorMsg: string = '';
  
  aboutToAppear(): void {
    this.loadDevices();
  }
  
  // 加载在线设备列表
  private async loadDevices(): Promise<void> {
    try {
      this.isLoading = true;
      this.errorMsg = '';
      
      const bundleName = getContext(this).applicationInfo.name;
      const deviceManager = distributedDeviceManager.createDeviceManager(bundleName);
      
      // 获取可用设备列表
      const availableDevices = deviceManager.getAvailableDeviceListSync();
      
      hilog.info(DOMAIN, TAG, `发现 ${availableDevices.length} 台在线设备`);
      
      // 获取本地设备networkId
      const localNetworkId = deviceManager.getLocalDeviceNetworkId();
      
      // 转换为自定义设备信息格式并过滤本地设备
      this.deviceList = [];
      for (let i = 0; i < availableDevices.length; i++) {
        const device = availableDevices[i];
        if (device.networkId !== localNetworkId) {
          const info: DeviceInfo = {
            deviceId: device.deviceId,
            deviceName: device.deviceName,
            deviceType: Number(device.deviceType),
            networkId: device.networkId ?? ''
          };
          this.deviceList.push(info);
        }
      }
      
      if (this.deviceList.length === 0) {
        this.errorMsg = '未发现可流转的在线设备';
      }
      
      // 释放设备管理器
      distributedDeviceManager.releaseDeviceManager(deviceManager);
      
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, `获取设备列表失败: ${e.message}`);
      this.errorMsg = `获取设备列表失败: ${e.message}`;
    } finally {
      this.isLoading = false;
    }
  }
  
  build() {
    Column() {
      // 标题
      Row() {
        Text('选择目标设备')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 24, right: 24 })
      .justifyContent(FlexAlign.Start)
      
      Divider()
        .width('100%')
        .height(1)
      
      // 内容区域
      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color($r('sys.color.icon_emphasize'))
          
          Text('正在搜索在线设备...')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        
      } else if (this.errorMsg) {
        // 错误提示
        Column() {
          Image($r('sys.symbol.checkmark_circle_fill'))
            .width(64)
            .height(64)
            .fillColor($r('sys.color.font_secondary'))
          
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 16 })
            .textAlign(TextAlign.Center)
          
          Button('重新搜索')
            .fontSize(14)
            .margin({ top: 16 })
            .onClick(() => {
              this.loadDevices();
            })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 24, right: 24 })
        
      } else {
        // 设备列表
        List() {
          ForEach(this.deviceList, (device: DeviceInfo) => {
            ListItem() {
              this.DeviceItemBuilder(device)
            }
          }, (device: DeviceInfo) => device.deviceId)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({
          strokeWidth: 1,
          color: $r('sys.color.comp_divider')
        })
      }
      
      // 底部按钮
      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.background_secondary'))
          .width('100%')
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .height(400)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
  }
  
  // 设备列表项
  @Builder
  DeviceItemBuilder(device: DeviceInfo) {
    Row() {
      // 设备图标
      Image($r('sys.symbol.phone'))
        .width(48)
        .height(48)
        .fillColor($r('sys.color.icon_emphasize'))
      
      // 设备信息
      Column() {
        Text(device.deviceName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(getDeviceTypeDesc(device.deviceType))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })
      
      // 右箭头
      Image($r('sys.symbol.chevron_right'))
        .width(20)
        .height(20)
        .fillColor($r('sys.color.font_secondary'))
    }
    .width('100%')
    .height(72)
    .padding({ left: 24, right: 24 })
    .onClick(() => {
      hilog.info(DOMAIN, TAG, `选择设备: ${device.deviceName}`);
      this.controller.close();
      this.onDeviceSelected(device);
    })
  }
}
