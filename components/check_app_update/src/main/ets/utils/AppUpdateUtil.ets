import { bundleManager, common } from '@kit.AbilityKit';
import { updateManager } from '@kit.StoreKit';
import { buffer } from '@kit.ArkTS';


/**
 * 检查是否存在新版本
 * @param context
 * @returns
 */
export function checkUpdate(context: common.UIAbilityContext): Promise<number> {
  return new Promise((resolve) => {
    updateManager.checkAppUpdate(context)
      .then((checkResult: updateManager.CheckUpdateResult) => {
        resolve(checkResult.updateAvailable);
      });
  });
}

/**
 * 拉起应用市场
 * @param context
 */
export function pullUpAppGallery(context: common.UIAbilityContext) {
  bundleManager.getBundleInfoForSelf(0x00000001).then((data) => {
    // 固定链接 + 应用包名
    let link = getProtocolUrl('app_gallery_url') + data.appInfo.name;
    context.openLink(link);
  });
}

function getProtocolUrl(urlKey: string): string {
  try {
    // Read files from /AppScope/resources/rawfile.
    const value: Uint8Array = getContext().resourceManager.getRawFileContentSync('data.json');
    // Return the link to the HUAWEI ID User Authentication Agreement.
    return JSON.parse(buffer.from(value.buffer).toString())[urlKey] as string;
  } catch (error) {
    return '';
  }
}


