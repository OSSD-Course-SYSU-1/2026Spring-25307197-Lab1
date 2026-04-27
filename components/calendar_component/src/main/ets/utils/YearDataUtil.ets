import dayjs from 'dayjs';
import { DateModel } from '../models/DateModel';
import { MonthWeekDataSource } from '../models/CalendarDataSource';

export class YearDataUtil {
  public static generateYearData(yearOffset: number): MonthWeekDataSource {
    let ds = new MonthWeekDataSource()
    const baseYear = dayjs().add(yearOffset, 'year').year();
    for (let month = 0; month < 12; month++) {
      ds.pushData(YearDataUtil.getDateList(baseYear, month))
    }
    return ds;
  }


  private static getDateList(year: number, month: number): DateModel[] {
    const baseDate = dayjs().year(year).month(month).startOf('month');

    // 计算当月首尾日期
    const firstDate = baseDate.startOf('month');
    const afterDate = baseDate.endOf('month');

    // 计算日历起始日（考虑周起始）
    const firstDateDay = firstDate.day();
    const weekStart = 0 % 7;
    const frontPadding = (firstDateDay - weekStart + 7) % 7;
    const showFirstDay = firstDate.subtract(frontPadding, 'day');

    // 计算基础显示天数（包含前后缓冲）
    const baseDays = afterDate.diff(showFirstDay, 'day') + 1;

    // 计算需要的行数（向上取整）
    const rowsNeeded = Math.ceil(baseDays / 7);
    // 确保至少有5行
    const totalRows = Math.max(5, rowsNeeded);
    // 计算总单元格数
    const totalCells = totalRows * 7;

    // 生成日期数据
    let dateList: DateModel[] = [];
    for (let i = 0; i < totalCells; i++) {
      const dayjsObj = showFirstDay.add(i, 'day');

      // 智能月份判断（精确到月份）
      const isCurrentMonth = dayjsObj.isSame(firstDate, 'month');

      // 创建日期模型
      const dateModel = new DateModel(
        dayjsObj,
        dayjsObj.date(),
        '',
        '',
        isCurrentMonth,
        dayjsObj.format('YYYY-M-D')
      );
      dateList.push(dateModel);
    }

    return dateList;
  }
}