import { FormatUtil } from './FormatUtil';
import { i18n } from '@kit.LocalizationKit';
import { preferences } from '@kit.ArkData';

export interface AlmanacInfo {
  yi: string;
  ji: string;
}

export class DateUtils {
  private static readonly ALMANAC_PREFERENCES_NAME = 'almanac_cache';
  private static dataPreferences: preferences.Preferences | null = null;
  public static YEAR: string = 'year';
  public static MONTH: string = 'month';
  public static DATE: string = 'date';
  public static LUNAR_MONTH: Map<string, string> =
    new Map([['0', '正月'], ['1', '二月'], ['2', '三月'], ['3', '四月'], ['4', '五月'], ['5', '六月'], ['6', '七月'],
      ['7', '八月'], ['8', '九月'], ['9', '十月'], ['10', '十一月'], ['11', '十二月']]);
  public static LUNAR_DAY: Map<string, string> =
    new Map([['1', '初一'], ['2', '初二'], ['3', '初三'], ['4', '初四'], ['5', '初五'], ['6', '初六'], ['7', '初七'],
      ['8', '初八'], ['9', '初九'], ['10', '初十']
      , ['11', '十一'], ['12', '十二'], ['13', '十三'], ['14', '十四'], ['15', '十五'], ['16', '十六'], ['17', '十七'],
      ['18', '十八'], ['19', '十九'], ['20', '廿十']
      , ['21', '廿一'], ['22', '廿二'], ['23', '廿三'], ['24', '廿四'], ['25', '廿五'], ['26', '廿六'], ['27', '廿七'],
      ['28', '廿八'], ['29', '廿九'], ['30', '三十']]);

  public static isToday(day: string): boolean {
    return FormatUtil.formatDate(new Date()) === day;
  }

  public static isTomorrow(day: string): boolean {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return FormatUtil.formatDate(tomorrow) === day;
  }

  public static isExpiredDate(inputDate: Date): boolean {
    const today = new Date();

    // 清除时间部分，只比较日期
    const inputDateWithoutTime = new Date(inputDate.getFullYear(), inputDate.getMonth(), inputDate.getDate());
    const todayWithoutTime = new Date(today.getFullYear(), today.getMonth(), today.getDate());

    return inputDateWithoutTime < todayWithoutTime;
  }

  public static isExpired(day: string): boolean {
    const inputDate = new Date(day);
    const today = new Date();

    // 清除时间部分，只比较日期
    const inputDateWithoutTime = new Date(inputDate.getFullYear(), inputDate.getMonth(), inputDate.getDate());
    const todayWithoutTime = new Date(today.getFullYear(), today.getMonth(), today.getDate());

    return inputDateWithoutTime < todayWithoutTime;
  }

  public static getCurrentYear(): number {
    let calendar = i18n.getCalendar('en-US');
    return calendar.get(DateUtils.YEAR);
  }

  public static getCurrentMonth(): number {
    let calendar = i18n.getCalendar('en-US');
    return calendar.get(DateUtils.MONTH);
  }

  public static getCurrentLunarYear(): number {
    let calendar = i18n.getCalendar('zh-Hans', 'chinese');
    return calendar.get(DateUtils.YEAR);
  }

  public static getCurrentLunarMonth(): number {
    let calendar = i18n.getCalendar('zh-Hans', 'chinese');
    return calendar.get(DateUtils.MONTH);
  }

  public static getCurrentLunarDay(): number {
    let calendar = i18n.getCalendar('zh-Hans', 'chinese');
    return calendar.get(DateUtils.DATE);
  }

  public static isCurrentMonth(year: number, month: number): boolean {
    return year === DateUtils.getCurrentYear() && month === DateUtils.getCurrentMonth();
  }

  public static getCurrentLunarDayDesc(year: number, month: number, day: number,
    descConverter?: (lunarMonth: number, lunarDay: number) => string | undefined): string | undefined {
    let calendar = i18n.getCalendar('en-US');
    let today = new Date(calendar.getTimeInMillis());
    calendar.setTime(new Date(today.getFullYear(), today.getMonth(), today.getDate()));
    let diffDays: number = calendar.compareDays(new Date(year, month, day));
    let lunarCalendar = i18n.getCalendar('zh-Hans', 'chinese');
    lunarCalendar.add(DateUtils.DATE, diffDays);
    let lunarDay = lunarCalendar.get(DateUtils.DATE);
    let lunarMonth = lunarCalendar.get(DateUtils.MONTH);
    if (descConverter) {
      return descConverter(lunarMonth, lunarDay);
    }
    if (lunarDay === 1) {
      return DateUtils.LUNAR_MONTH.get(lunarMonth + '')
    }
    return DateUtils.LUNAR_DAY.get(lunarDay + '')
  }

  public static getLunarMonthDesc(year: number, month: number, day: number): string | undefined {
    let calendar = i18n.getCalendar('en-US');
    let today = new Date(calendar.getTimeInMillis());
    calendar.setTime(new Date(today.getFullYear(), today.getMonth(), today.getDate()));
    let diffDays: number = calendar.compareDays(new Date(year, month, day));
    let lunarCalendar = i18n.getCalendar('zh-Hans', 'chinese');
    lunarCalendar.add(DateUtils.DATE, diffDays);
    return DateUtils.LUNAR_MONTH.get(lunarCalendar.get(DateUtils.MONTH) + '')
  }

  public static getDayAlmanac(year: number, month: number, day: number): AlmanacInfo {
    let lunarCalendar = i18n.getCalendar('zh-Hans', 'chinese');
    lunarCalendar.setTime(new Date(year, month, day));
    let lunarYear = lunarCalendar.get('year');
    let lunarMonth = lunarCalendar.get('month');
    let lunarDay = lunarCalendar.get('date');

    let tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    let diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    let yearGan = (lunarYear - 1) % 10;
    let yearZhi = (lunarYear - 1) % 12;
    let monthGan = (yearGan * 2 + lunarMonth) % 10;
    let monthZhi = (lunarMonth + 2) % 12;
    let baseDate = new Date(1900, 0, 31);
    let currentDate = new Date(year, month, day);
    let dayDiff = Math.floor((currentDate.getTime() - baseDate.getTime()) / (24 * 60 * 60 * 1000));
    let dayGan = (dayDiff % 10 + 10) % 10;
    let dayZhi = (dayDiff % 12 + 12) % 12;

    let jianChu = ['建', '除', '满', '平', '定', '执', '破', '危', '成', '收', '开', '闭'];
    let jianChuIndex = (dayZhi - monthZhi + 12) % 12;
    let yiItems: string[] = [];
    let jiItems: string[] = [];

    switch (jianChu[jianChuIndex]) {
      case '建':
        yiItems = ['出行', '上任', '会友', '求医', '祭祀'];
        jiItems = ['动土', '开仓', '嫁娶', '移徙'];
        break;
      case '除':
        yiItems = ['祭祀', '祈福', '求嗣', '纳采', '嫁娶', '出行', '解除', '修造', '动土', '破土'];
        jiItems = ['开市', '立券', '交易', '纳财'];
        break;
      case '满':
        yiItems = ['祭祀', '祈福', '求嗣', '开光', '出行', '解除', '上梁', '盖屋', '修造'];
        jiItems = ['动土', '破土', '栽种'];
        break;
      case '平':
        yiItems = ['祭祀', '修造', '动土', '涂泥', '余事勿取'];
        jiItems = ['祈福', '求嗣', '开光', '出行', '嫁娶'];
        break;
      case '定':
        yiItems = ['祭祀', '祈福', '求嗣', '纳采', '嫁娶', '开市', '交易', '立券', '纳畜'];
        jiItems = ['出行', '修造', '动土', '移徙'];
        break;
      case '执':
        yiItems = ['祭祀', '祈福', '求嗣', '斋醮', '纳采', '嫁娶', '修造'];
        jiItems = ['开市', '立券', '交易', '纳财', '出行', '移徙'];
        break;
      case '破':
        yiItems = ['祭祀', '求医', '治病', '破屋', '坏垣', '余事勿取'];
        jiItems = ['诸事不宜'];
        break;
      case '危':
        yiItems = ['祭祀', '祈福', '求嗣', '开光', '出行', '解除', '修造', '动土'];
        jiItems = ['嫁娶', '开市', '立券', '交易', '纳财'];
        break;
      case '成':
        yiItems = ['祭祀', '祈福', '求嗣', '纳采', '嫁娶', '开市', '交易', '立券', '出行', '修造'];
        jiItems = ['动土', '破土'];
        break;
      case '收':
        yiItems = ['祭祀', '祈福', '求嗣', '纳采', '嫁娶', '开市', '交易', '立券', '纳畜'];
        jiItems = ['出行', '修造', '动土'];
        break;
      case '开':
        yiItems = ['祭祀', '祈福', '求嗣', '开光', '出行', '开市', '交易', '立券', '修造', '动土'];
        jiItems = ['嫁娶', '移徙', '安葬'];
        break;
      case '闭':
        yiItems = ['祭祀', '捕捉', '畋猎', '纳畜', '余事勿取'];
        jiItems = ['出行', '开市', '交易', '修造', '动土'];
        break;
    }

    let dayGanZhi = tianGan[dayGan] + diZhi[dayZhi];
    if (['甲子', '乙丑', '丙寅', '丁卯', '戊辰', '己巳', '庚午', '辛未', '壬申', '癸酉'].includes(dayGanZhi)) {
      yiItems.push('祈福', '求嗣');
    }

    if (lunarMonth === 0 && lunarDay === 1) {
      yiItems = ['祈福', '求嗣', '祭祀', '拜年', '出行'];
      jiItems = ['动土', '破土', '安葬'];
    } else if (lunarMonth === 4 && lunarDay === 5) {
      yiItems = ['祭祀', '祈福', '求嗣', '出行', '解除'];
      jiItems = ['嫁娶', '开市', '动土'];
    } else if (lunarMonth === 7 && lunarDay === 15) {
      yiItems = ['祭祀', '祈福', '求嗣', '出行', '赏月'];
      jiItems = ['动土', '破土'];
    }

    let uniqueYiItems: string[] = [];
    for (let i = 0; i < yiItems.length && uniqueYiItems.length < 8; i++) {
      if (!uniqueYiItems.includes(yiItems[i])) {
        uniqueYiItems.push(yiItems[i]);
      }
    }
    let uniqueJiItems: string[] = [];
    for (let i = 0; i < jiItems.length && uniqueJiItems.length < 6; i++) {
      if (!uniqueJiItems.includes(jiItems[i])) {
        uniqueJiItems.push(jiItems[i]);
      }
    }

    return { yi: uniqueYiItems.join(' '), ji: uniqueJiItems.join(' ') };
  }

  public static initAlmanacCache(context: Context): void {
    DateUtils.dataPreferences = preferences.getPreferencesSync(context, {
      name: DateUtils.ALMANAC_PREFERENCES_NAME
    });
  }

  public static saveAlmanac(year: number, month: number, day: number, almanac: AlmanacInfo): void {
    if (!DateUtils.dataPreferences) {
      return;
    }
    let key = `almanac_${year}${String(month + 1).padStart(2, '0')}${String(day).padStart(2, '0')}`;
    let value = JSON.stringify(almanac);
    DateUtils.dataPreferences.putSync(key, value);
    DateUtils.dataPreferences.flushSync();
  }

  public static getCacheAlmanac(year: number, month: number, day: number): AlmanacInfo | null {
    if (!DateUtils.dataPreferences) {
      return null;
    }
    let key = `almanac_${year}${String(month + 1).padStart(2, '0')}${String(day).padStart(2, '0')}`;
    let value = DateUtils.dataPreferences.getSync(key, '') as string;
    if (!value) {
      return null;
    }
    try {
      return JSON.parse(value) as AlmanacInfo;
    } catch (e) {
      return null;
    }
  }
}