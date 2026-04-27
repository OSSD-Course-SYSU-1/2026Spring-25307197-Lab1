# 效率（日程清单）应用模板快速入门

## 目录
- [功能介绍](#功能介绍)
- [约束和限制](#约束和限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)


## 功能介绍

您可以基于此模板直接定制应用，从而降低您的开发难度，提高您的开发效率。

本模板为日程类应用提供了常用功能的开发样例，模板主要分首页、日历、我的三大模块：

1、首页：展示待办事项（按日期时间顺序），添加待办、按顺序展示

2、日历：展示年、月、周、日维度的日历，可以选择日期

3、我的：提供登录、意见反馈、联系客服等功能，包括隐私协议、隐私设置


本模板已集成账号服务，只需做少量配置和定制即可快速实现华为账号一键登录。


| 首页                                                        | 日历                                                         | 我的                                                          |
|-----------------------------------------------------------|------------------------------------------------------------|-------------------------------------------------------------|
| <img src="screenshots/homepage.png" alt="首页" width="300"> | <img src="screenshots/calendar.png" alt="我的" width="300"/> | <img src="screenshots/mine.png" alt="setting" width="300"/> |



本模板主要页面及核心功能如下所示：

```ts
日历日程模板
 |-- 首页
 |    |-- 已过期
 |    |-- 今天
 |    |-- 明天
 |    |-- 已完成
 |-- 日历
 |    |-- 年 
 |    |-- 月
 |    |-- 周
 |    |-- 日
 |    |-- 日期展示 
 |    |    └-- 弹窗日期选择
 └-- 我的
      |-- 用户信息
      |    |-- 华为账号一键登录
      |    └-- 头像昵称修改
      └-- 意见反馈
      |    |-- 反馈问题
      |    |    |-- 问题描述
      |    |    |-- 问题截图
      |    |    └-- 联系方式
      |    └-- 反馈记录
      |-- 设置
      |    |-- 个人信息
      |    |    |-- 头像修改
      |    |    └-- 昵称修改
      |    |-- 隐私设置
      |    |-- 检测版本
      |    |-- 清除缓存
      |    |-- 关于我们
      |    └-- 退出登录
      └-- 联系客服
```


本模板工程代码结构如下所示：

```ts
DailySchedule
  |- commons                                       // 公共层
  |   |- common_lib/src/main/ets/                  
  |   |    |- constants                            // 常量
  |   |    |     CheckInEnums.ets                // 版本更新常量  
  |   |    |     CommonContants.ets                // 常用常量
  |   |    |     CommonEnums.ets                   // 数字常量
  |   |    |- utils                                // 工具包
  |   |    |     AccountUtil.ets                   // 账户工具
  |   |    |     BreakpointType.ets                // 断点存储工具
  |   |    |     DateUtil.ets                      // 日期工具
  |   |    |     FileUtil.ets                      // 文件工具  
  |   |    |     DialogUtil.ets                    // 对话框工具
  |   |    |     FormatUtil.ets                    // 格式工具
  |   |    |     Logger.ets                        // 日志工具
  |   |    |     RouterModule.ets                  // 路由工具
  |   |    └- viewmodel                            // 视图工具
  |              MainEntryVM.ets                   // 主入口视图模型 
  |  
  |- component_lib/src/main/ets/                   // 公共组件
  |   |    |- components                       
  |   |    |     CustomIcon.ets                    // 图标组件
  |   |    |- model                                // 模型
  |   |    |     AvoidArea.ets                     // 避开区域
  |   |    └- types                                // 类型定义
  |   |          CustomIconOptions.ets             // 组件图标类型
  |   |
  |- network/src/main/ets/                         // 网络
  |   |    └- types                                // 类型定义
  |   |          ResponseTypes.ets                  // 回复类型    
  |   |   
  |   └- utils/src/main/ets                        // 工具类
  |        |- constants   
  |        |     DateConstants.ets                 // 日期格式化常量     
  |        |- model
  |        |     GlobalInfoModel.ets               // 存储全局变量 
  |        |     NotificationConfig.ets            // 通知工具类,默认配置参数                   
  |        |     NotificationOptions.ets           // 通知工具类,描述通知的请求参数                  
  |        └- utils                                
  |              AppUtil.ets                       // App相关工具类  
  |              BreakpointSystem.ets              // 一多适配工具类  
  |              DateUtil.ets                      // 日期处理工具类
  |              DialogUtil.ets                    // 弹窗工具类
  |              LogUtil.ets                       // 日志工具类   
  |              NotificationUtil.ets              // 通知工具类 
  |              ObjectUtil.ets                    // 对象工具类   
  |              ReadDataUtil.ets                  // 读取数据工具类   
  |              StringUtil.ets                    // 字符串工具类
  |              WantUtil.ets                      // 跳转设置页面工具类
  |              WindowUtil.ets                    // 窗口工具类
  |
  |- components                                    // 公共组件
  |   |- check_app_update/src/main/ets             // 检测应用是否更新
  |   |    |- components  
  |   |    |     FindNewVersion.ets                // 发现新版本弹窗视图
  |   |    |- model  
  |   |    |     Params                            // 向视图中传递的参数        
  |   |    └- utils  
  |   |          AppUpdateUtil.ets                 // 检测应用新版本工具类
  |   |
  |   |- feed_back/src/main/ets                    // 意见反馈
  |   |    |- components  
  |   |    |     FeedBack.ets                      // 意见反馈视图
  |   |    |- model  
  |   |    |     FeedBackRecordModel.ets           // 意见反馈模型        
  |   |    └- utils  
  |   |          FileSelect.ets                    // 图片选择
  |   |          Logger.ets                        // 日志
  |   |          PreferenceUtil.ets                // 持久化
  |   |
  |   |- aggregated_login/src/main/ets                        // 登录
  |   |    |- common  
  |   |    |     Constants.ets                     // 常量
  |   |    |     LoginConstants.ets                // 登录常量  
  |   |    |- components  
  |   |    |     AggregatedLogini.ets              // 登录
  |   |    |     AgreePrivacyBox.ets               // 隐私协议
  |   |    |     OtherLoginPage.ets                // 其他登录页    
  |   |    |     RightArrow.ets                    // 右箭头
  |   |    |- model  
  |   |    |     UserInfo.ets                      // 用户模型
  |   |    |     Index.ets                         // 数据模型
  |   |    |- utils  
  |   |    |     LoginSheetUtils.ets               // 登录页表格       
  |   |    |     PopViewUtils.ets                  // 弹出视图   
  |   |    |     Utils.ets                         // 综合工具  
  |   |    |     WXApiUtils.ets                    // 微信工具    
  |   |    |- viewmodel  
  |   |    |     AggregatedLoginVM.ets             // 登录数据模型        
  |   |    └- Views  
  |   |          AggregatedLoginPage.ets           // 综合登录页面
  |   |          LogOutDialog.ets                  // 登出会话框
  |   |          ProtocolWebView.ets               // 网页视图工具
  |   |          QuickLoginPage.ets                // 快捷登录页
  |   |          UserInfoPage.ets                  // 用户信息页
  |   |      
  |
  └- products/phone                               
      └---src/main/ets                             // 主包
           |- constants
           |     Constants.ets                     // 下标常量
           |- controller        
           |     SettingController.ets             // 设置页面控制器                
           |     ThemeController.ets               // 主题控制器                       
           |- entryability
           |     EntryAbility.ets                  // 程序入口     
           |- entrybackupability
           |     EntryBackAbility.ets              // 程序备份扩展能力                                                                                                                            
           └- pages
                 MainEntry.ets                     // 首页入口           
```

## 约束和限制
### 环境
- DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- HarmonyOS版本：HarmonyOS 5.0.3(15) 及以上
### 权限
- 网络权限：ohos.permission.INTERNET
- 获取网络信息: ohos.permission.GET_NETWORK_INFO
- 身份认证权限: ohos.permission.ACCESS_BIOMETRIC


## 快速入门
### 配置工程
在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建应用，将包名配置到模板中。

   a. 参考[创建HarmonyOS应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-app-0000002247955506)为应用创建APP ID，并将APP ID与应用进行关联。

   b. 返回应用列表页面，查看应用的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建应用的包名。

2. 配置华为账号服务。

   a. 将应用的client ID配置到products/phone模块的src/main/module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 申请华为账号一键登录的权限，详细参考：[申请账号权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-config-permissions)。

3. 为应用进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。
4. 添加手工签名所用证书对应的公钥指纹，详细参考：[配置应用证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-cert-fingerprint-0000002278002933)。


### 运行调试工程
1. 连接调试手机和PC。

2. 菜单选择“Run > Run 'phone' ”或者“Run > Debug 'phone' ”，运行或调试模板工程。

## 示例效果

## 开源许可协议
该代码经过[Apache 2.0 授权许可](https://www.apache.org/licenses/LICENSE-2.0)。