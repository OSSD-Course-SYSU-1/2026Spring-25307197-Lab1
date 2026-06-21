# DeviceManagerUtil 分布式设备管理工具类

## 功能概述

DeviceManagerUtil 是一个封装了 HarmonyOS 分布式设备管理能力的工具类，提供以下核心功能：

- **设备扫描**：扫描附近的鸿蒙设备
- **设备列表获取**：获取可信设备列表
- **设备状态监听**：监听设备上下线状态变化
- **本地设备信息**：获取本地设备信息

## 权限配置

在 `module.json5` 中添加以下权限：

```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.DISTRIBUTED_DATASYNC",
        "reason": "$string:distributed_datasync_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.GET_DISTRIBUTED_DEVICE_INFO",
        "reason": "$string:get_distributed_device_info_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

## API 说明

### 导入方式

```typescript
import { 
  DeviceManagerUtil, 
  DeviceState, 
  DeviceInfo, 
  deviceManagerUtil 
} from '@common/common_lib';
```

### 主要类型定义

#### DeviceState - 设备状态枚举

```typescript
enum DeviceState {
  ONLINE = 1,    // 设备上线
  OFFLINE = 2,   // 设备下线
  CHANGE = 3     // 设备信息变更
}
```

#### DeviceInfo - 设备信息接口

```typescript
interface DeviceInfo {
  deviceId: string;      // 设备ID
  deviceName: string;    // 设备名称
  deviceType: string;    // 设备类型
  networkId?: string;    // 设备网络ID
  state?: DeviceState;   // 设备状态
}
```

#### DeviceDiscoveryCallback - 设备发现回调

```typescript
interface DeviceDiscoveryCallback {
  onDeviceFound?: (device: DeviceInfo) => void;      // 发现设备回调
  onDiscoverFailed?: (errorCode: number) => void;    // 发现失败回调
}
```

#### DeviceStateCallback - 设备状态回调

```typescript
interface DeviceStateCallback {
  onDeviceStateChanged?: (device: DeviceInfo, state: DeviceState) => void;
}
```

#### DiscoveryFilterOptions - 发现过滤选项

```typescript
interface DiscoveryFilterOptions {
  availableStatus?: number;        // 设备可信状态 0-不可信 1-可信
  discoverDistance?: number;       // 发现距离(cm)
  authenticationStatus?: number;   // 认证状态 0-未认证 1-已认证
  authorizationType?: number;      // 授权类型
}
```

### 主要方法

#### 1. 获取实例

```typescript
// 方式一：使用单例实例（推荐）
const deviceManager = deviceManagerUtil;

// 方式二：获取单例
const deviceManager = DeviceManagerUtil.getInstance();
```

#### 2. 初始化

```typescript
async function init() {
  const bundleName = 'com.example.yourapp';
  const success = await deviceManager.init(bundleName);
  if (success) {
    console.log('初始化成功');
  }
}
```

#### 3. 开始扫描设备

```typescript
function startScan() {
  deviceManager.startDiscovering(
    {
      onDeviceFound: (device) => {
        console.log(`发现设备: ${device.deviceName}`);
      },
      onDiscoverFailed: (errorCode) => {
        console.error(`扫描失败: ${errorCode}`);
      }
    },
    {
      availableStatus: 0,  // 发现不可信设备
      authenticationStatus: 0  // 未认证设备
    }
  );
}
```

#### 4. 停止扫描

```typescript
deviceManager.stopDiscovering();
```

#### 5. 获取设备列表

```typescript
// 同步获取
const devices = deviceManager.getAvailableDeviceListSync();

// 异步获取
const devices = await deviceManager.getAvailableDeviceList();
```

#### 6. 注册设备状态监听

```typescript
deviceManager.registerDeviceStateListener({
  onDeviceStateChanged: (device, state) => {
    switch (state) {
      case DeviceState.ONLINE:
        console.log(`设备上线: ${device.deviceName}`);
        break;
      case DeviceState.OFFLINE:
        console.log(`设备下线: ${device.deviceName}`);
        break;
    }
  }
});
```

#### 7. 取消设备状态监听

```typescript
deviceManager.unregisterDeviceStateListener();
```

#### 8. 获取本地设备信息

```typescript
const deviceId = deviceManager.getLocalDeviceId();
const deviceName = deviceManager.getLocalDeviceName();
const deviceType = deviceManager.getLocalDeviceType();
const networkId = deviceManager.getLocalDeviceNetworkId();
```

#### 9. 释放资源

```typescript
deviceManager.release();
```

## 完整使用示例

```typescript
import { deviceManagerUtil, DeviceState, DeviceInfo } from '@common/common_lib';

@Entry
@Component
struct DevicePage {
  @State deviceList: DeviceInfo[] = [];
  private deviceManager = deviceManagerUtil;

  async aboutToAppear() {
    // 初始化
    await this.deviceManager.init('com.example.app');
    
    // 注册状态监听
    this.deviceManager.registerDeviceStateListener({
      onDeviceStateChanged: (device, state) => {
        console.log(`设备状态变化: ${device.deviceName}, ${state}`);
      }
    });
    
    // 开始扫描
    this.startDiscovery();
  }

  startDiscovery() {
    this.deviceManager.startDiscovering({
      onDeviceFound: (device) => {
        this.deviceList = [...this.deviceList, device];
      }
    });
  }

  aboutToDisappear() {
    this.deviceManager.release();
  }

  build() {
    Column() {
      // UI 实现
    }
  }
}
```

## 注意事项

1. **权限申请**：使用前确保已申请 `DISTRIBUTED_DATASYNC` 和 `GET_DISTRIBUTED_DEVICE_INFO` 权限

2. **初始化顺序**：必须先调用 `init()` 初始化后才能使用其他方法

3. **资源释放**：页面销毁时务必调用 `release()` 释放资源

4. **扫描时长**：设备扫描默认持续 2 分钟，超时自动停止

5. **设备去重**：设备发现回调可能多次触发同一设备，需自行去重

6. **网络要求**：设备需连接同一局域网或开启蓝牙

## 设备类型说明

| 类型值 | 说明 |
|-------|------|
| 0 | UNKNOWN - 未知设备 |
| 14 | PHONE - 手机 |
| 17 | TABLET - 平板 |
| 156 | TV - 智慧屏 |
| 131 | CAR - 车机 |
| 109 | WATCH - 手表 |

## 错误码说明

| 错误码 | 说明 |
|-------|------|
| 201 | 权限验证失败 |
| 401 | 参数错误 |
| 11600101 | 执行功能失败 |
| 11600104 | 发现不可用 |
