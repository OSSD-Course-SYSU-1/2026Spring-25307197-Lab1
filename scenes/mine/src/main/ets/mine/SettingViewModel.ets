import { promptAction } from '@kit.ArkUI';
import { FileUtils } from '@ohos_agcit/daily_schedule_common_lib';

@ObservedV2
export class SettingViewModel {
  @Trace cacheSize: string = '0';
  @Trace isLoading: boolean = false;


  getCacheSize(): void {
    FileUtils.getCache().then((size: number) => {
      console.info('SettingVM', '获取到缓存大小:', size, '字节');
      this.cacheSize = (size / 1024 / 1024).toFixed(2);
    }).catch((err: Error) => {
      console.error('SettingVM', '获取缓存大小错误:', err.message);
      this.cacheSize = '0';
    });
  }

  // 清除缓存
  clearCache(): void {
    console.info('SettingVM', '开始清除缓存');
    FileUtils.clearCache();
    promptAction.showToast({ message: '清除缓存成功' });
    this.cacheSize = '0';
  }

  getCacheLabel(): string {
    return `${this.cacheSize}M`;
  }
}