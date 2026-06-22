# 分布式任务流转配置说明

## 一、权限配置

已在 `products/phone/src/main/module.json5` 中添加以下权限：

### 1. 分布式数据同步权限
```json
{
  "name": "ohos.permission.DISTRIBUTED_DATASYNC",
  "reason": "$string:distributed_datasync_reason",
  "usedScene": {
    "abilities": ["EntryAbility"],
    "when": "inuse"
  }
}
```

### 2. 任务管理权限（系统接口）
```json
{
  "name": "ohos.permission.MANAGE_MISSIONS",
  "reason": "$string:manage_missions_reason",
  "usedScene": {
    "abilities": ["EntryAbility"],
    "when": "inuse"
  }
}
```

### 3. 网络信息权限
```json
{
  "name": "ohos.permission.GET_NETWORK_INFO",
  "reason": "$string:get_network_info_reason",
  "usedScene": {
    "abilities": ["EntryAbility"],
    "when": "inuse"
  }
}
```

## 二、核心模块导入

### 1. 分布式任务管理模块
```typescript
import distributedMissionManager from '@ohos.distributedMissionManager';
```

### 2. 分布式设备管理模块
```typescript
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
```

### 3. 权限管理模块
```typescript
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
```

## 三、设备互联能力开启

### 步骤1：申请权限
```typescript
async requestDistributedPermissions(context: common.UIAbilityContext): Promise<void> {
  const atManager = abilityAccessCtrl.createAtManager();
  await atManager.requestPermissionsFromUser(context, [
    'ohos.permission.DISTRIBUTED_DATASYNC',
    'ohos.permission.MANAGE_MISSIONS',
    'ohos.permission.GET_NETWORK_INFO'
  ]);
}
```

### 步骤2：初始化设备管理器
```typescript
const deviceManager = distributedDeviceManager.createDeviceManager(bundleName);
```

### 步骤3：开始发现设备
```typescript
const discoverParam = { 'discoverTargetType': 1 };
const filterOptions = { 'availableStatus': 0 };
deviceManager.startDiscovering(discoverParam, filterOptions);
```

### 步骤4：注册设备状态监听
```typescript
deviceManager.on('deviceStateChange', (data) => {
  if (data.action === distributedDeviceManager.DeviceStateChange.AVAILABLE) {
    console.log('设备上线:', data.device.deviceName);
  } else if (data.action === distributedDeviceManager.DeviceStateChange.UNAVAILABLE) {
    console.log('设备下线:', data.device.deviceName);
  }
});
```

## 四、分布式任务管理使用

### 1. 注册任务状态监听
```typescript
distributedMissionManager.registerMissionListener(
  { deviceId: '' },  // 空字符串表示监听所有设备
  {
    notifyMissionsChanged: (deviceId) => {
      console.log('任务变化，设备ID:', deviceId);
    },
    notifySnapshot: (deviceId, missionId) => {
      console.log('快照变化，设备ID:', deviceId, '任务ID:', missionId);
    },
    notifyNetDisconnect: (deviceId, state) => {
      console.log('网络断开，设备ID:', deviceId, '状态:', state);
    }
  },
  (error) => {
    if (error) {
      console.error('注册任务监听失败:', error);
    }
  }
);
```

### 2. 开始同步远端任务
```typescript
distributedMissionManager.startSyncRemoteMissions(
  {
    deviceId: targetDeviceId,
    fixConflict: false,
    tag: 0
  },
  (error) => {
    if (error) {
      console.error('同步任务失败:', error);
    }
  }
);
```

### 3. 迁移任务（通过任务ID）
```typescript
distributedMissionManager.continueMission(
  {
    srcDeviceId: localDeviceId,
    dstDeviceId: targetDeviceId,
    missionId: missionId,
    wantParam: { 'key': 'value' }
  },
  { 
    onContinueDone: (resultCode) => {
      console.log('迁移完成，结果码:', resultCode);
    }
  },
  (error) => {
    if (error) {
      console.error('迁移失败:', error);
    }
  }
);
```

### 4. 迁移任务（通过包名）
```typescript
distributedMissionManager.continueMission(
  {
    srcDeviceId: localDeviceId,
    dstDeviceId: targetDeviceId,
    bundleName: 'com.example.calendar',
    wantParam: { 'key': 'value' }
  },
  (error) => {
    if (error) {
      console.error('迁移失败:', error);
    }
  }
);
```

### 5. 注册任务流转状态监听
```typescript
distributedMissionManager.on('continueStateChange', (data) => {
  console.log('流转状态:', data.state === 0 ? '激活' : '未激活');
  console.log('流转信息:', data.info);
});
```

## 五、工具类使用

### 使用封装好的工具类
推荐使用已封装的工具类，简化开发流程：

```typescript
import DistributedTaskFlowManager from './DistributedTaskFlowExample';

// 在 Ability 中初始化
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const flowManager = DistributedTaskFlowManager.getInstance();
    flowManager.initialize(this.context, 'com.example.calendar');
  }
  
  onDestroy(): void {
    const flowManager = DistributedTaskFlowManager.getInstance();
    flowManager.release();
  }
}

// 在页面中使用
@Entry
@Component
struct IndexPage {
  build() {
    Column() {
      Button('获取设备列表')
        .onClick(() => {
          const flowManager = DistributedTaskFlowManager.getInstance();
          const devices = flowManager.getAvailableDevices();
          console.log('可用设备:', devices);
        })
      
      Button('迁移任务')
        .onClick(() => {
          const flowManager = DistributedTaskFlowManager.getInstance();
          const devices = flowManager.getAvailableDevices();
          if (devices.length > 0) {
            flowManager.migrateTask(devices[0].deviceId);
          }
        })
    }
  }
}
```

## 六、注意事项

### 1. 权限要求
- `ohos.permission.MANAGE_MISSIONS` 为系统接口，需要系统签名
- `ohos.permission.DISTRIBUTED_DATASYNC` 需要用户动态授权

### 2. 设备要求
- 多设备需登录同一华为账号
- 设备需开启蓝牙和Wi-Fi
- 设备需在分布式组网环境下

### 3. 系统能力
- 分布式任务管理从 API version 9 开始支持
- 需要设备支持 `SystemCapability.Ability.AbilityRuntime.Mission`

### 4. 错误码说明
| 错误码 | 说明 |
|--------|------|
| 16300501 | 系统能力工作异常 |
| 16300502 | 无法获取指定任务ID的任务信息 |
| 16300503 | 远端未安装应用且不支持免安装 |
| 16300504 | 远端未安装应用但支持免安装，请使用免安装标志重试 |
| 16300505 | 操作设备必须是待迁移应用所在设备或待迁移目标设备 |
| 16300506 | 本地流转任务正在进行中 |

## 七、文件清单

### 新增文件
1. `commons/utils/src/main/ets/DistributedMissionManager.ets` - 分布式任务管理工具类
2. `commons/utils/src/main/ets/DeviceConnectivityManager.ets` - 设备互联能力管理工具类
3. `commons/utils/src/main/ets/DistributedTaskFlowExample.ets` - 使用示例和整合管理类

### 修改文件
1. `products/phone/src/main/module.json5` - 添加权限配置
2. `products/phone/src/main/resources/base/element/string.json` - 添加权限说明文本
