import { hilog } from '@kit.PerformanceAnalysisKit';
import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';
import { common } from '@kit.AbilityKit';
import { readDataFromRawFile } from '@ohos_agcit/daily_schedule_utils';
import { dealAllError,ErrorCode } from '../common/LoginConstants';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { UserInfo } from '../model/UserInfo';
import {  MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { NavParam, PrivacyContent } from '../model/Index';


@Builder
export function QuickLoginPageBuilder() {
  QuickLoginPage();
}

@ComponentV2
export struct QuickLoginPage {
  vm: MainEntryVM = MainEntryVM.instance;
  logTag: string = 'QuickLoginPage';
  domainId: number = 0x0000;
  privacyText: loginComponentManager.PrivacyText[] = [
    {
      text: '已阅读并同意',
      type: loginComponentManager.TextType.PLAIN_TEXT,
    },
    {
      text: '《用户协议》',
      type: loginComponentManager.TextType.RICH_TEXT,
      tag: '',
    }, {
    text: '《隐私政策》',
    type: loginComponentManager.TextType.RICH_TEXT,
    tag: '',
  }, {
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }, {
    text: '《华为账号用户认证协议》',
    type: loginComponentManager.TextType.RICH_TEXT,
    tag: this.getProtocolUrl(),
  }, {
    text: '。',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }];
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        if (error) {
          if (this.isSelected) {
            // mock登录
            this.userInfo.logIn();
            this.userInfo.phone = this.quickLoginAnonymousPhone;
            this.vm.navStack.pop();
          } else {
            this.showPopUp = true;
          }
        } else{
          this.handleLoginWithHuaweiIDButton(error, response);
          if (error) {
            dealAllError(error);
          }
        }
      });
  @Local quickLoginAnonymousPhone: string = '';
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local isSelected: boolean = false;
  @Local showPopUp: boolean = false;
  @Local enableStatus: boolean = true;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private userInfo: UserInfo = UserInfo.instance;

  // 跳转到其他登录方式页面
  jumpToOtherLogin() {
    const params: NavParam = {
      isSheet: false,
      icon: $r('app.media.app_icon'),
      themeColor: '#FFAA00',
      privacyContent: this.getPrivacyContent(),
      loginTypes: this.getLoginTypes(),
      isPersistence: false
    };
    this.vm.navStack.pushPathByName('OtherLoginPage', params);
  }

  // 获取隐私协议内容
  getPrivacyContent(): PrivacyContent[] {
    return [
      {
        privacyLabel: '《用户协议》',
        privacyUrl: this.getUserAgreementUrl(),
        privacyTag: '用户协议'
      }, {
      privacyLabel: '《隐私政策》',
      privacyUrl: this.getPrivacyPolicyUrl(),
      privacyTag: '隐私政策'
    }, {
      privacyLabel: '《华为账号用户认证协议》',
      privacyUrl: this.getProtocolUrl(),
      privacyTag: '华为账号用户认证协议'
    }
    ] as PrivacyContent[];
  }

  // 获取支持的登录方式
  getLoginTypes() {
    // 这里可以根据需要配置支持的第三方登录方式
    return [
    // 可以添加微信、QQ等登录方式
    // new Channel(LoginType.WECHAT, '微信', { appId: 'your_app_id' }, $r('app.media.wx_count'))
    ];
  }

  // 获取用户协议URL
  getUserAgreementUrl(): string {
    let userAgreementUrl = readDataFromRawFile<string>('data.json', 'user_agreement_url');
    return userAgreementUrl ? userAgreementUrl : '';
  }

  // 获取隐私政策URL
  getPrivacyPolicyUrl(): string {
    let privacyPolicyUrl = readDataFromRawFile<string>('data.json', 'privacy_policy_url');
    return privacyPolicyUrl ? privacyPolicyUrl : '';
  }

  handleLoginWithHuaweiIDButton(error: BusinessError | undefined, response: loginComponentManager.HuaweiIDCredential) {
    this.enableStatus = false;
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        this.showPopUp = true;
      } else {
        this.getUIContext().getPromptAction().showToast({
          message: JSON.stringify(error)
        })
      }
      this.enableStatus = true;
      return;
    }
    try {
      if (this.isSelected) {
        if (response) {
          hilog.info(this.domainId, this.logTag, 'Succeeded in clicking LoginWithHuaweiIDButton.');
          const authCode = response.authorizationCode;
          const openID = response.openID;
          const unionID = response.unionID;
          const idToken = response.idToken;
          // todo 待实现
          this.userInfo.logIn();
          this.userInfo.phone = this.quickLoginAnonymousPhone === '' ? this.userInfo.phone : this.quickLoginAnonymousPhone;
          this.vm.navStack.pop();
        }
      } else {
        this.showPopUp = true;
      }
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      promptAction.showToast({
        message: JSON.stringify(error)
      })
    } finally {
      this.enableStatus = true;
    }
  }

  jumpToPrivacyWebView(privacyText: loginComponentManager.PrivacyText) {
    const hasNet: boolean = connection.hasDefaultNetSync();
    if (!hasNet) {
      this.getUIContext().getPromptAction().showToast({
        message: '网络未连接，请检查网络设置'
      })
      return;
    }
    if (privacyText.tag && privacyText.tag !== '') {
      const systemLanguage: string = (getContext() as common.UIExtensionContext).config.language ?? '';
      hilog.info(this.domainId, this.logTag, `systemLanguage is ${systemLanguage}`);
      const params: Record<string, Object> = { 'protocolUrl': privacyText.tag + systemLanguage };
      this.vm.navStack?.pushPathByName('PrivacyAgreement', params);
    }
  }

  getProtocolUrl(): string {
    let privacyUrl = readDataFromRawFile<string>('data.json', 'privacy_url');
    return privacyUrl ? privacyUrl : '';
  }

  build() {
    NavDestination() {
      Column() {
        Scroll(){
          Column(){
            Column() {
              Row() {
                Image($r('app.media.app_icon'))
                  .width(100)
                  .aspectRatio(1)
                  .draggable(false)
                  .copyOption(CopyOptions.None)
                  .borderRadius(20)
                  .onComplete(() => {
                    hilog.info(this.domainId, this.logTag, 'Succeeded in loading appIcon.');
                  })
                  .padding({
                    top: 10,
                  })
                  .onError(() => {
                    hilog.error(this.domainId, this.logTag, 'Failed to load appIcon.');
                  });
              }
              .padding({
                top: 100,
              });

              Column() {
                Text(this.quickLoginAnonymousPhone)
                  .fontSize(36)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Bold)
                  .lineHeight(48)
                  .height(48)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .constraintSize({ maxWidth: '100%', minHeight: 48 });

                Text('华为账号绑定号码')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(16)
                  .height(16)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .constraintSize({ maxWidth: '100%' })
                  .margin({ top: 8 });
              }
              .margin({ top: 50 })
            }
            .height('30%')
            .align(Alignment.Bottom)
            .width('100%');

            Column() {
              Column() {
                LoginWithHuaweiIDButton({
                  params: {
                    style: loginComponentManager.Style.BUTTON_CUSTOM,
                    customButtonParams: {backgroundColor: '#FFAA00'},
                    extraStyle: {
                      buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                        show: true,
                      })
                    },
                    loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                  },
                  controller: this.controller,
                }).id('login_with_huaweiId_button')
              }
              .height(40)
              .width('100%')
              .margin({ top: 130 });

              Button('其他方式登录')
                .width('100%')
                .height(40)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_L'))
                .margin({ top: 20 })
                .onClick(() => {
                  this.jumpToOtherLogin();
                });

              Blank()

              Flex({
                justifyContent: FlexAlign.Center,
                alignItems: ItemAlign.Start,
              })
              {
                Row() {
                  Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
                    .width(24)
                    .height(24)
                    .focusable(true)
                    .focusOnTouch(true)
                    .selectedColor($r('sys.color.comp_background_emphasize'))
                    .select(this.isSelected)
                    .enabled(this.enableStatus)
                    .margin({ top: 0 })
                    .onChange((value: boolean) => {
                      hilog.info(this.domainId, this.logTag, `agreementChecked: ${value}`);
                      if (value) {
                        this.isSelected = true;
                        this.showPopUp = false;
                        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                      } else {
                        this.isSelected = false;
                        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                      }
                    });
                }
                .padding({ right: 12 })
                .bindPopup(this.showPopUp, {
                  message: '请先阅读并同意协议',
                  onStateChange: (event) => {
                    this.showPopUp = event.isVisible;
                  },
                  mask: false,
                });

                Row() {
                  Text() {
                    if (this.privacyText && this.privacyText.length > 0) {
                      ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                        if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                          Span(item?.text)
                            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                            .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                            .fontWeight(FontWeight.Regular)
                            .fontSize($r('sys.float.ohos_id_text_size_body3'));
                        } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                          Span(item?.text)
                            .fontColor($r('sys.color.ohos_id_color_text_primary'))
                            .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                            .fontWeight(FontWeight.Medium)
                            .fontSize($r('sys.float.ohos_id_text_size_body3'))
                            .focusable(true)
                            .focusOnTouch(true)
                            .enabled(this.enableStatus)
                            .id('quickLoginProtocolUrlSpan')
                            .onClick(() => {
                              hilog.info(this.domainId, this.logTag, 'Click protocol url');
                              if (this.enableStatus) {
                                try {
                                  this.vm.navStack?.pushPathByName('PrivacyAgreement', undefined);
                                  this.jumpToPrivacyWebView(item);
                                } catch (error) {
                                  const code: number = error.code;
                                  const message: string = error.message;
                                  hilog.error(this.domainId, this.logTag,
                                    `Failed to jump privacy webview. errCode is ${code}, errMessage is ${message}`);
                                }
                              }
                            });
                        }
                      }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`);
                    }
                  };
                }
                .constraintSize({ minHeight: 24 });
              }
              .width('100%')
              .margin({ bottom: 30 });
            }
            .width('100%')
            .height('70%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({
              bottom: 30
            })
          }
          .height('100%')
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .padding({
        left: '4%',
        right: '4%',
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: px2vp(this.avoidArea.topRectHeight)  })
    .onReady((cxt: NavDestinationContext) => {
      this.obtainAnonymousPhone();
    })
    .onBackPressed(() => {
      this.vm.navStack.pop();
      return true;
    })
    .hideTitleBar(false);
  }

  public async obtainAnonymousPhone() {
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      const response: authentication.AuthorizationWithHuaweiIDResponse = await controller.executeRequest(authRequest)
      let openID = response.data?.openID || '';
      let unionID = response.data?.unionID || '';
      this.quickLoginAnonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
    } catch (error) {
      this.getUIContext().getPromptAction().showToast({
        message: '获取匿名手机号失败，使用mock登录'
      })
      this.quickLoginAnonymousPhone = 'a00****0000';
    }
  }
}