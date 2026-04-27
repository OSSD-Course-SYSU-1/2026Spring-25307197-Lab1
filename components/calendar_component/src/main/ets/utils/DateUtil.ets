import { i18n } from '@kit.LocalizationKit';

export class DateUtils {
  public static YEAR: string = 'year';
  public static MONTH: string = 'month';
  public static DATE: string = 'date';

  public static getCurrentYear(): number {
    let calendar = i18n.getCalendar('en-US');
    return calendar.get(DateUtils.YEAR);
  }

  public static getCurrentDay(): number {
    let calendar = i18n.getCalendar('en-US');
    return calendar.get(DateUtils.DATE);
  }

  public static getCurrentMonth(): number {
    let calendar = i18n.getCalendar('en-US');
    return calendar.get(DateUtils.MONTH);
  }
}