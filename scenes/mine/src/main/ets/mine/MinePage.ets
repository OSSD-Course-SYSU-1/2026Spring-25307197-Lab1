import { BreakpointType, GlobalInfoModel, FlowTransferUtil, FlowDeviceInfo } from '@ohos_agcit/daily_schedule_utils';
import { UserInfo } from 'aggregated_login';
import { MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { AppStorageV2 } from '@kit.ArkUI';
import { ContactItem, MineItem } from '../components/MineItem';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { COMMON_SERVICE, MinePageCommonService } from '../constants/MineUiConstants';
import { promptAction } from '@kit.ArkUI';

@Builder
export function MinePageBuilder() {
  MinePage();
}

@ComponentV2
export struct MinePage {
  vm: MainEntryVM = MainEntryVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private userInfo: UserInfo = UserInfo.instance;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
  
  // 设备选择对话框状态
  @Local showDeviceDialog: boolean = false;
  @Local deviceList: FlowDeviceInfo[] = [];
  @Local isLoading: boolean = false;
  
  // 显示设备选择对话框
  private showDeviceSelectDialog(): void {
    this.isLoading = true;
    this.showDeviceDialog = true;
    
    try {
      const devices = FlowTransferUtil.getInstance().queryOnlineDevices();
      this.deviceList = devices;
      this.isLoading = false;
    } catch (err) {
      this.isLoading = false;
      promptAction.showToast({
        message: '获取设备列表失败',
        duration: 2000
      });
    }
  }
  
  // 选择设备进行流转
  private selectDevice(device: FlowDeviceInfo): void {
    this.showDeviceDialog = false;
    
    // 提示用户使用超级终端面板
    promptAction.showDialog({
      title: '流转至其他设备',
      message: `已准备流转至「${device.deviceName}」\n\n请按以下步骤操作：\n1. 从屏幕右上角向下滑动\n2. 打开「超级终端」面板\n3. 点击「${device.deviceName}」完成流转\n\n流转后，应用将在目标设备上自动恢复当前页面状态。`,
      buttons: [{ text: '知道了', color: '#387BF1' }]
    });
  }

  @Builder
  titleBar() {
    Row() {
      Text('我的')
        .fontSize($r('sys.float.Title_L'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start);
    }
    .height('5%')
    .width('100%')
    .margin({bottom:16})
  }

  build() {
    Column(){
      this.titleBar();
      Scroll() {
        Column() {
          Row() {
            Image(this.userInfo.userAvatar)
              .width(56)
              .height(56)
              .margin({ left: 12 })

            Text(this.userInfo.userName)
              .fontSize($r('sys.float.Subtitle_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ left: 12 })
          }
          .width('100%')
          .height(72)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)
          .onClick(async () => {
            if (this.userInfo.isLogin) {
              this.vm.navStack.pushPathByName('UserInfoPage', undefined);
            } else {
              this.vm.navStack.pushPathByName('QuickLoginPage', undefined);
            }
          });

          Column() {
            ForEach(COMMON_SERVICE, (item: MinePageCommonService, index: number) => {
              MineItem({
                commonService: item,
                appPathStack: this.appPathStack
              })

              if (index < COMMON_SERVICE.length - 1) {
                Divider()
                  .margin({ left: 12, right: 12 })
              }
            },(item: MinePageCommonService)=>JSON.stringify(item))

            Divider()
              .margin({ left: 12, right: 12 })

            // 流转至其他设备
            Row() {
              Image($r('sys.symbol.shareplay'))
                .width(24)
                .height(24)
                .margin({ left: 12 })
              Text('流转至其他设备')
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 16 })
              Blank()
              Image($r('app.media.ic_right_arrow_lined'))
                .width(7)
                .height(14)
                .fillColor($r('sys.color.icon_secondary'))
                .margin({ right: 12 })
            }
            .width('100%')
            .height(46)
            .borderRadius(16)
            .justifyContent(FlexAlign.Start)
            .margin({ top: 12 })
            .onClick(() => {
              this.showDeviceSelectDialog();
            })

            Divider()
              .margin({ left: 12, right: 12, top: 12 })

            ContactItem({
              commonService: {
                icon: 'app.media.app_kefu',
                label: '联系客服',
              },
              appPathStack: this.appPathStack
            })
          }
          .height(250)
          .width('100%')
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)
          .margin({ top: 12 })
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
    .padding({left:'5%', top: px2vp(this.avoidArea.topRectHeight), right:'5%'})
    .backgroundColor($r('sys.color.background_secondary'))
    .bindSheet($$this.showDeviceDialog, this.deviceSelectDialogBuilder(), {
      title: { title: '选择目标设备' },
      height: 400,
      width: '100%'
    })
  }
  
  // 设备选择对话框
  @Builder
  deviceSelectDialogBuilder() {
    Column() {
      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
          
          Text('正在搜索设备...')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.deviceList.length === 0) {
        // 无设备
        Column() {
          Image($r('sys.symbol.shareplay'))
            .width(64)
            .height(64)
            .fillColor($r('sys.color.icon_secondary'))
          
          Text('未发现在线设备')
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 16 })
          
          Text('请确保目标设备已登录同一华为账号\n并开启了Wi-Fi和蓝牙')
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 8 })
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        // 设备列表
        List() {
          ForEach(this.deviceList, (device: FlowDeviceInfo) => {
            ListItem() {
              Row() {
                Image($r('sys.symbol.shareplay'))
                  .width(24)
                  .height(24)
                  .fillColor($r('sys.color.icon_primary'))
                
                Column() {
                  Text(device.deviceName)
                    .fontSize(16)
                    .fontColor($r('sys.color.font_primary'))
                  
                  Text(this.getDeviceTypeText(device.deviceType))
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                .layoutWeight(1)
                
                Image($r('sys.symbol.chevron_right'))
                  .width(20)
                  .height(20)
                  .fillColor($r('sys.color.icon_secondary'))
              }
              .width('100%')
              .height(64)
              .padding({ left: 16, right: 16 })
              .borderRadius(12)
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .onClick(() => {
                this.selectDevice(device);
              })
            }
            .margin({ top: 8 })
          }, (device: FlowDeviceInfo) => device.deviceId)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
      
      // 取消按钮
      Button('取消')
        .width('90%')
        .height(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 16 })
        .onClick(() => {
          this.showDeviceDialog = false;
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16, bottom: 16 })
  }
  
  // 获取设备类型文本
  private getDeviceTypeText(deviceType: string): string {
    switch (deviceType) {
      case '0x00':
        return '未知设备';
      case '0x01':
        return '智能手机';
      case '0x02':
        return '平板电脑';
      case '0x03':
        return '智能电视';
      case '0x04':
        return '智能手表';
      case '0x05':
        return '车载设备';
      case '0x06':
        return 'PC';
      default:
        return '其他设备';
    }
  }
}