/**
 * 日志工具类
 * 提供统一的日志打印接口
 */
import { hilog } from '@kit.PerformanceAnalysisKit';

const LOGGER_DOMAIN: number = 0xFF00;
const LOGGER_TAG: string = 'FlowTransfer';

/**
 * Logger 日志工具类
 */
export class Logger {
  private static domain: number = LOGGER_DOMAIN;
  private static tag: string = LOGGER_TAG;

  /**
   * 设置日志标签
   */
  static setTag(tag: string): void {
    Logger.tag = tag;
  }

  /**
   * 打印 DEBUG 级别日志
   */
  static debug(tag: string, message: string): void {
    hilog.debug(Logger.domain, tag, '%{public}s', message);
  }

  /**
   * 打印 INFO 级别日志
   */
  static info(tag: string, message: string): void {
    hilog.info(Logger.domain, tag, '%{public}s', message);
  }

  /**
   * 打印 WARN 级别日志
   */
  static warn(tag: string, message: string): void {
    hilog.warn(Logger.domain, tag, '%{public}s', message);
  }

  /**
   * 打印 ERROR 级别日志
   */
  static error(tag: string, message: string): void {
    hilog.error(Logger.domain, tag, '%{public}s', message);
  }

  /**
   * 打印 FATAL 级别日志
   */
  static fatal(tag: string, message: string): void {
    hilog.fatal(Logger.domain, tag, '%{public}s', message);
  }
}

export default Logger;
