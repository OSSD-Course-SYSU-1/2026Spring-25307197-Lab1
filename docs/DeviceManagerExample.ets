/**
 * DeviceManagerUtil 使用示例
 * 
 * 本示例展示如何使用DeviceManagerUtil工具类实现：
 * 1. 初始化设备管理器
 * 2. 扫描附近鸿蒙设备
 * 3. 获取设备列表
 * 4. 监听设备状态变化
 */

import { DeviceManagerUtil, DeviceState, DeviceInfo, deviceManagerUtil } from '@common/common_lib';

@Entry
@Component
struct DeviceManagerDemo {
  @State deviceList: DeviceInfo[] = [];
  @State isScanning: boolean = false;
  @State localDeviceName: string = '';
  @State statusMessage: string = '未初始化';

  private deviceManager: DeviceManagerUtil = deviceManagerUtil;

  async aboutToAppear() {
    // 初始化设备管理器
    await this.initDeviceManager();
  }

  aboutToDisappear() {
    // 页面退出时释放资源
    this.deviceManager.release();
  }

  /**
   * 初始化设备管理器
   */
  async initDeviceManager() {
    const bundleName = 'com.example.rili'; // 替换为你的应用包名
    const success = await this.deviceManager.init(bundleName);
    
    if (success) {
      this.statusMessage = '初始化成功';
      // 获取本地设备信息
      this.localDeviceName = this.deviceManager.getLocalDeviceName();
      // 注册设备状态监听
      this.registerDeviceStateListener();
    } else {
      this.statusMessage = '初始化失败';
    }
  }

  /**
   * 开始扫描设备
   */
  startScan() {
    if (this.isScanning) {
      return;
    }

    this.isScanning = true;
    this.statusMessage = '正在扫描...';

    const success = this.deviceManager.startDiscovering(
      {
        onDeviceFound: (device: DeviceInfo) => {
          // 设备发现回调
          console.info(`发现设备: ${device.deviceName} (${device.deviceId})`);
          // 添加到设备列表（避免重复）
          const exists = this.deviceList.some(d => d.deviceId === device.deviceId);
          if (!exists) {
            this.deviceList = [...this.deviceList, device];
          }
        },
        onDiscoverFailed: (errorCode: number) => {
          // 发现失败回调
          console.error(`设备发现失败: ${errorCode}`);
          this.statusMessage = `扫描失败: ${errorCode}`;
          this.isScanning = false;
        }
      },
      {
        availableStatus: 0, // 发现不可信设备
        authenticationStatus: 0 // 未认证设备
      }
    );

    if (!success) {
      this.isScanning = false;
      this.statusMessage = '启动扫描失败';
    }
  }

  /**
   * 停止扫描设备
   */
  stopScan() {
    this.deviceManager.stopDiscovering();
    this.isScanning = false;
    this.statusMessage = '已停止扫描';
  }

  /**
   * 注册设备状态监听
   */
  registerDeviceStateListener() {
    this.deviceManager.registerDeviceStateListener({
      onDeviceStateChanged: (device: DeviceInfo, state: DeviceState) => {
        switch (state) {
          case DeviceState.ONLINE:
            console.info(`设备上线: ${device.deviceName}`);
            // 更新设备列表
            this.updateDeviceList(device, true);
            break;
          case DeviceState.OFFLINE:
            console.info(`设备下线: ${device.deviceName}`);
            // 从设备列表移除
            this.updateDeviceList(device, false);
            break;
          case DeviceState.CHANGE:
            console.info(`设备信息变更: ${device.deviceName}`);
            break;
        }
      }
    });
  }

  /**
   * 更新设备列表
   */
  updateDeviceList(device: DeviceInfo, isOnline: boolean) {
    if (isOnline) {
      const exists = this.deviceList.some(d => d.deviceId === device.deviceId);
      if (!exists) {
        this.deviceList = [...this.deviceList, device];
      }
    } else {
      this.deviceList = this.deviceList.filter(d => d.deviceId !== device.deviceId);
    }
  }

  /**
   * 刷新设备列表（获取可信设备）
   */
  async refreshDeviceList() {
    const devices = await this.deviceManager.getAvailableDeviceList();
    this.deviceList = devices;
    this.statusMessage = `获取到 ${devices.length} 个设备`;
  }

  build() {
    Column() {
      // 标题
      Text('分布式设备管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      // 状态信息
      Column() {
        Text(`状态: ${this.statusMessage}`)
          .fontSize(14)
          .fontColor(Color.Gray)
        
        if (this.localDeviceName) {
          Text(`本机: ${this.localDeviceName}`)
            .fontSize(14)
            .fontColor(Color.Gray)
            .margin({ top: 5 })
        }
      }
      .margin({ bottom: 20 })

      // 操作按钮
      Row() {
        Button(this.isScanning ? '扫描中...' : '开始扫描')
          .enabled(!this.isScanning)
          .onClick(() => this.startScan())
          .width(120)

        Blank().width(10)

        Button('停止扫描')
          .enabled(this.isScanning)
          .onClick(() => this.stopScan())
          .width(120)
      }
      .margin({ bottom: 10 })

      Row() {
        Button('刷新列表')
          .onClick(() => this.refreshDeviceList())
          .width(120)

        Blank().width(10)

        Button('释放资源')
          .onClick(() => {
            this.deviceManager.release();
            this.statusMessage = '已释放资源';
            this.deviceList = [];
          })
          .width(120)
      }
      .margin({ bottom: 20 })

      // 设备列表
      Text(`发现设备 (${this.deviceList.length})`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })

      List() {
        ForEach(this.deviceList, (device: DeviceInfo) => {
          ListItem() {
            Row() {
              Column() {
                Text(device.deviceName || '未知设备')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                
                Text(`类型: ${device.deviceType}`)
                  .fontSize(12)
                  .fontColor(Color.Gray)
                  .margin({ top: 4 })
                
                Text(`ID: ${device.deviceId.substring(0, 16)}...`)
                  .fontSize(12)
                  .fontColor(Color.Gray)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              // 设备状态图标
              if (device.state === DeviceState.ONLINE) {
                Text('在线')
                  .fontSize(12)
                  .fontColor('#52c41a')
              } else {
                Text('离线')
                  .fontSize(12)
                  .fontColor('#ff4d4f')
              }
            }
            .width('100%')
            .padding(15)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .margin({ bottom: 10 })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
