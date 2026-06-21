import { DeviceManagerUtil, DeviceInfo } from '../utils/DeviceManagerUtil';
import { TransferUtil, TransferResult } from '../utils/TransferUtil';
import { TodoItem } from '../model/TodoItem';
import { BreakpointType } from '../utils/BreakpointType';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, AppStorageV2 } from '@kit.ArkUI';

const LOG_DOMAIN = 0xFF00;
const LOG_TAG = 'DeviceSelectDialog';

// 断点类型枚举
export enum BreakpointTypeEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl'
}

// 全局信息模型
@ObservedV2
export class GlobalInfoModel {
  @Trace currentBreakpoint: string = BreakpointTypeEnum.SM;
}

@ComponentV2
export struct DeviceSelectDialog {
  @Param todoItem: TodoItem | null = null;
  @Param onClose: () => void = () => {};
  @Param onSendSuccess: () => void = () => {};

  @Local deviceList: DeviceInfo[] = [];
  @Local isLoading: boolean = true;
  @Local isSending: boolean = false;
  @Local selectedDeviceId: string = '';
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  private deviceManager: DeviceManagerUtil = DeviceManagerUtil.getInstance();

  aboutToAppear(): void {
    this.loadDevices();
  }

  private async loadDevices(): Promise<void> {
    this.isLoading = true;
    try {
      const devices = await this.deviceManager.getAvailableDeviceList();
      const localDeviceId = this.deviceManager.getLocalDeviceId();
      this.deviceList = devices.filter(d => d.deviceId !== localDeviceId);
      hilog.info(LOG_DOMAIN, LOG_TAG, `Found ${this.deviceList.length} available devices`);
      
      if (this.deviceList.length === 0) {
        promptAction.showToast({ message: '暂无设备' });
      }
    } catch (err) {
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to load devices: ${err}`);
      this.deviceList = [];
      promptAction.showToast({ message: '暂无设备' });
    } finally {
      this.isLoading = false;
    }
  }

  private async sendTodoToDevice(): Promise<void> {
    if (!this.todoItem || !this.selectedDeviceId) {
      return;
    }

    this.isSending = true;

    try {
      const transferUtil = TransferUtil.getInstance();
      const result: TransferResult = await transferUtil.sendTodoToDevice(
        this.todoItem,
        this.selectedDeviceId,
        {
          onSuccess: (_result: TransferResult) => {
            hilog.info(LOG_DOMAIN, LOG_TAG, 'Todo sent successfully');
          },
          onFailed: (failResult: TransferResult) => {
            hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to send todo: ${failResult.errorMsg}`);
          }
        }
      );

      if (result.success) {
        promptAction.showToast({ message: '发送成功' });
        this.onSendSuccess();
        this.onClose();
      } else {
        hilog.error(LOG_DOMAIN, LOG_TAG, `Send failed: ${result.errorMsg}`);
      }
    } catch (err) {
      hilog.error(LOG_DOMAIN, LOG_TAG, `Failed to send todo: ${err}`);
    } finally {
      this.isSending = false;
    }
  }

  build() {
    Column() {
      Row() {
        Text('选择设备')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .height(56)

      Divider()

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color($r('sys.color.icon_primary'))

          Text('正在搜索设备...')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 12 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.deviceList.length === 0) {
        Column() {
          Image($r('sys.media.ohos_ic_public_voice'))
            .width(48)
            .height(48)

          Text('未发现可用设备')
            .fontSize(16)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 12 })

          Text('请确保其他设备已开启并登录同一账号')
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ top: 8 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.deviceList, (device: DeviceInfo) => {
            ListItem() {
              Row() {
                Image(this.getDeviceIcon(device.deviceType))
                  .width(40)
                  .height(40)

                Column() {
                  Text(device.deviceName)
                    .fontSize(16)
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)

                  Text(this.getDeviceTypeText(device.deviceType))
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                .layoutWeight(1)

                if (this.selectedDeviceId === device.deviceId) {
                  Image($r('sys.media.ohos_ic_public_ok'))
                    .width(20)
                    .height(20)
                }
              }
              .width('100%')
              .height(72)
              .padding({ left: 16, right: 16 })
              .backgroundColor(this.selectedDeviceId === device.deviceId
                ? $r('sys.color.comp_background_emphasize')
                : $r('sys.color.background_primary'))
              .borderRadius(12)
              .onClick(() => {
                this.selectedDeviceId = device.deviceId;
              })
            }
            .margin({ top: 8, bottom: 8 })
          }, (device: DeviceInfo) => device.deviceId)
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }

      Divider()

      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.background_tertiary'))
          .borderRadius(24)
          .height(44)
          .layoutWeight(1)
          .onClick(() => {
            this.onClose();
          })

        Blank().width(16)

        Button(this.isSending ? '发送中...' : '发送')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor(this.selectedDeviceId && !this.isSending
            ? $r('sys.color.multi_color_04')
            : $r('sys.color.background_tertiary'))
          .borderRadius(24)
          .height(44)
          .layoutWeight(1)
          .enabled(!!this.selectedDeviceId && !this.isSending)
          .onClick(() => {
            this.sendTodoToDevice();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    // 自适应屏幕宽度：手机90%，平板70%，PC50%
    .width(new BreakpointType<string>('90%', '70%', '50%', '50%').getValue(this.globalInfo.currentBreakpoint))
    .constraintSize({ maxHeight: '80%' })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  private getDeviceIcon(deviceType: string): Resource {
    switch (deviceType) {
      case '0':
        return $r('sys.media.ohos_ic_public_device_phone');
      case '1':
        return $r('sys.media.ohos_ic_public_device_pad');
      case '2':
        return $r('sys.media.ohos_ic_public_device_smartscreen');
      case '3':
        return $r('sys.media.ohos_ic_public_device_watch');
      default:
        return $r('sys.media.ohos_ic_public_device_phone');
    }
  }

  private getDeviceTypeText(deviceType: string): string {
    switch (deviceType) {
      case '0':
        return '手机';
      case '1':
        return '平板';
      case '2':
        return '电视';
      case '3':
        return '手表';
      default:
        return '未知设备';
    }
  }
}

export class DeviceSelectDialogController {
  private dialogController: CustomDialogController | null = null;

  public show(todoItem: TodoItem, onSuccess: () => void): void {
    this.dialogController = new CustomDialogController({
      builder: DeviceSelectDialog({
        todoItem: todoItem,
        onClose: () => {
          this.close();
        },
        onSendSuccess: onSuccess
      }),
      customStyle: true,
      alignment: DialogAlignment.Bottom,
      backgroundColor: Color.Transparent
    });

    this.dialogController.open();
  }

  public close(): void {
    if (this.dialogController) {
      this.dialogController.close();
      this.dialogController = null;
    }
  }
}