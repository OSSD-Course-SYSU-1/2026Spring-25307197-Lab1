import { webview } from '@kit.ArkWeb';
import { ObjectUtil } from '@ohos_agcit/daily_schedule_utils';
import {  MainEntryVM } from '@ohos_agcit/daily_schedule_common_lib';

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreement();
}

@ComponentV2
export struct PrivacyAgreement {
  vm: MainEntryVM = MainEntryVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack()
  controller: webview.WebviewController = new webview.WebviewController();
  privacyAgreementPath : string = this.getUIContext().getHostContext()!.
    resourceManager.getStringSync($r('app.string.privacyAgreementPath'));

  build() {
    NavDestination() {
      Web({ src: this.privacyAgreementPath, controller: this.controller })
        .verticalScrollBarAccess(false)
        .fileAccess(false)
        .geolocationAccess(false)
    }
    .hideTitleBar(true)
    .onReady((cxt: NavDestinationContext) => {
      let param = cxt.pathInfo.param as Record<string, Object>;
      if (ObjectUtil.isNotNull(param)) {
        this.privacyAgreementPath = param.protocolUrl as string;
      }
    })
    .onBackPressed(() => {
      this.vm.navStack.pop();
      return true;
    })
  }
}