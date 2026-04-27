import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { Logger } from './Logger';

export class PreferenceUtil {
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map()
  private dataPreferences: preferences.Preferences | null = null

  private constructor(context: Context, fileName: string) {
    preferences.removePreferencesFromCacheSync(context, fileName)
    this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName })
    Logger.info(`PreferenceUtil: ${fileName} init: ${this.dataPreferences != null}`)
  }

  public static getInstance(context?: Context, fileName: string = 'default') {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      return PreferenceUtil.preferenceRecord.get(fileName)!!
    }
    let ctx = context || getContext() as common.UIAbilityContext
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(ctx, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil)
    return preferenceUtil
  }

  public static put(preference: preferences.Preferences, key: string, value: object | string) {
    if (!preference) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
    }
    try {
      preference.putSync(key, value)
      preference.flushSync()
      Logger.info(`PreferenceUtil: put: ${key} = ${JSON.stringify(value)}`)
    } catch (e) {
      Logger.info(`PreferenceUtil: put error: ${JSON.stringify(e)}`)
    }
  }

  public static get(preference: preferences.Preferences, key: string, defaultValue?: object | string) {
    try {
      let data = preference.getSync(key, defaultValue)
      Logger.info(`PreferenceUtil: get: ${key} = ${JSON.stringify(data)}`)
      return data
    } catch (e) {
      Logger.info(`PreferenceUtil: get error: ${JSON.stringify(e)}`)
      return defaultValue
    }
  }

  public static putToArray(preference: preferences.Preferences, key: string, value: string) {
    if (!preference) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
    }
    let array: Array<string> = PreferenceUtil.get(preference, key) as Array<string> || []
    if (array.indexOf(value) !== -1) {
      return
    }
    array.push(value)
    PreferenceUtil.put(preference, key, array)
  }

  public static removeFromArray(preference: preferences.Preferences, key: string, value: string) {
    if (!preference) {
      Logger.info(`PreferenceUtil: dataPreferences is null`)
    }
    let array: Array<string> = PreferenceUtil.get(preference, key) as Array<string> || []
    array.splice(array.indexOf(value), 1)
    PreferenceUtil.put(preference, key, array)
  }
}