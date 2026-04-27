import dayjs from 'dayjs';
import { Lunar } from 'lunar';
import { DateModel } from '../models/DateModel';
import { MonthWeekDataSource, YearDataSource } from '../models/CalendarDataSource';
import { CommonConstants } from '../constants/CommonContants';
import { ViewTypeEnum } from '../enum/CalendarEnum';
import { YearDataUtil } from '../utils/YearDataUtil';

@ObservedV2
export class CalendarVM {
  @Trace selectDate: dayjs.Dayjs = dayjs()
  @Trace todayInfo: DateModel | null = null
  @Trace viewType: ViewTypeEnum = ViewTypeEnum.MONTH;
  @Trace festivalColor: ResourceStr | Color = ''
  @Trace monthWeekDataSource = new MonthWeekDataSource()
  @Trace yearDataSource = new YearDataSource()
  @Trace monthWeekCurIndex: number = 1
  @Trace yearCurIndex: number = 1
  @Trace weekStart: number = 1
  @Trace locateToCorrespondingDay: boolean = false
  @Trace nextDate: dayjs.Dayjs = dayjs()
  @Trace weekDayList: string[] = CommonConstants.weekList
  private curDate: dayjs.Dayjs = dayjs()
  private static _instance: CalendarVM

  public static get instance() {
    if (!CalendarVM._instance) {
      CalendarVM._instance = new CalendarVM()
    }
    return CalendarVM._instance
  }

  /**
   * 初始化数据源
   */
  public initMonthWeekData() {
    if (this.viewType === ViewTypeEnum.WEEK) {
      this.initWeekData();
    } else {
      this.initMonthData();
    }
  }

  /**
   * 初始化数据源
   */
  public initYearData() {
    let selectedYear = this.selectDate.year()
    let offset = selectedYear - dayjs().year()
    let start = offset - 2
    let end = offset + 2
    this.yearDataSource.clearArray()
    for (let i = start; i <= end; i++) {
      this.yearDataSource.pushData(YearDataUtil.generateYearData(i))
    }
    this.yearCurIndex = 2
  }

  /**
   * 初始化周数据
   */
  private initWeekData() {
    // 以当前选择日期为中心，生成前后2周的数据
    let i = -2
    while (i <= 2) {
      let week = this.getWeekList(i)
      this.monthWeekDataSource.pushData(week)
      i++
    }
    this.monthWeekCurIndex = 2
  }

  /**
   * 初始化月数据
   */
  private initMonthData() {
    let i = -2
    while (i <= 2) {
      let month = this.getDateList(i)
      this.monthWeekDataSource.pushData(month)
      i++
    }
    this.monthWeekCurIndex = 2
  }

  /**
   * 切换到周视图
   */
  public switchToWeekView() {
    if (this.viewType === ViewTypeEnum.MONTH) {
      this.generateWeekData()
    }
    this.viewType = ViewTypeEnum.WEEK
  }

  /**
   * 切换到月视图
   */
  public switchToMonthView() {
    if (this.viewType === ViewTypeEnum.WEEK || this.viewType === ViewTypeEnum.DAY) {
      this.generateMonthData()
    }
    this.viewType = ViewTypeEnum.MONTH
  }

  /**
   * 切换到月详情视图
   */
  public switchToMonthDetailView() {
    this.viewType = ViewTypeEnum.MONTH_DETAIL
  }

  /**
   * 生成周数据
   */
  public generateWeekData() {
    this.monthWeekDataSource.clearData();
    this.createWeekData();
  }

  /**
   * 生成月数据
   */
  public generateMonthData() {
    this.monthWeekDataSource.clearData();
    this.createMonthData();
  }

  /**
   * 创建周数据
   */
  private createWeekData() {
    // 计算当前选择日期相对于今天周的偏移量
    const selectWeekStart = this.selectDate.startOf('week').add(this.weekStart, 'day');
    const todayWeekStart = this.curDate.startOf('week').add(this.weekStart, 'day');

    // 计算周数差值
    const weekDiff = selectWeekStart.diff(todayWeekStart, 'week');

    console.log(`周偏移量：${weekDiff}, 选择日期：${this.selectDate.format('YYYY-MM-DD')}, 周开始：${selectWeekStart.format('YYYY-MM-DD')}`);

    // 生成前后各两周的数据（共5周）
    for (let i = -2; i <= 2; i++) {
      // 基于选择日期的周进行偏移
      const weekOffset = weekDiff + i;
      let week = this.getWeekList(weekOffset);
      this.monthWeekDataSource.pushData(week);
    }

    // 设置当前索引为中间位置
    this.monthWeekCurIndex = 2;
  }

  /**
   * 创建月数据
   */
  private createMonthData() {
    // 计算当前选择日期相对于今天月份的偏移量
    const selectMonth = this.selectDate.startOf('month');

    // 计算月份差值
    const monthDiff = (selectMonth.year() - this.curDate.year()) * 12 +
      (selectMonth.month() - this.curDate.month());

    console.log(`月份偏移量：${monthDiff}, 选择日期：${this.selectDate.format('YYYY-MM-DD')}`);

    // 生成前后各两个月的数据（共5个月）
    for (let i = -2; i <= 2; i++) {
      // 基于选择日期的月份进行偏移
      const monthOffset = monthDiff + i;
      let month = this.getDateList(monthOffset);
      this.monthWeekDataSource.pushData(month);
    }

    // 设置当前索引为中间位置
    this.monthWeekCurIndex = 2;
  }

  /**
   *
   * @param newIndex 当前页的索引
   * @param direction
   * @param controller
   */
  public handleHorizontalSwiper(newIndex: number, direction: number, controller: SwiperController) {
    console.log('index' + newIndex + '  ', this.monthWeekCurIndex)

    if (newIndex === 1 && this.monthWeekCurIndex === 0) {
      return;
    }

    let newDate = this.calculateNextDate(direction);
    console.log(newIndex + direction + 'new date:::' + newDate.format('YYYYMMDD'))


    let gap = 0
    if (this.viewType === ViewTypeEnum.WEEK || this.viewType === ViewTypeEnum.DAY) {
      const curWeekStart = this.curDate.startOf('week');
      const newWeekStart = newDate.startOf('week');
      gap = newWeekStart.diff(curWeekStart, 'week')
    } else if (this.viewType === ViewTypeEnum.MONTH) {
      gap = (newDate.year() - this.curDate.year()) * 12 + newDate.month() - this.curDate.month();
    } else {
      gap = newDate.year() - this.curDate.year()
    }

    // 添加新数据
    this.appendNewData(newIndex, gap, controller);

    // 将新日期设置为当前日期设置
    this.selectDate = dayjs(newDate)

    // 设置当前页索引
    this.monthWeekCurIndex = newIndex === 0 ? 1 : newIndex
  }

  private appendNewData(newIndex: number, gap: number, controller: SwiperController) {
    if (this.viewType === ViewTypeEnum.YEAR) {
      if (newIndex > 0 && newIndex < this.yearDataSource.totalCount() - 1) {
        return;
      }
      if (newIndex === 0) {
        this.yearDataSource.addDataFromHead(YearDataUtil.generateYearData(gap));
        this.resetIndexToFirst(controller)
        return;
      }
      if (newIndex === this.yearDataSource.totalCount() - 1) {
        this.yearDataSource.addData(this.yearDataSource.totalCount(), YearDataUtil.generateYearData(gap));
        return;
      }
    }

    if (this.viewType === ViewTypeEnum.MONTH) {
      if (newIndex > 0 && newIndex < this.yearDataSource.totalCount() - 1) {
        return;
      }
      if (newIndex === 0) {
        this.monthWeekDataSource.addDataFromHead(this.getDateList(gap - 1))
        this.resetIndexToFirst(controller)
        return;
      }
      if (newIndex === this.yearDataSource.totalCount() - 1) {
        this.monthWeekDataSource.addData(this.monthWeekDataSource.totalCount(), this.getDateList(gap + 1))
        this.resetIndexToFirst(controller)
        return;
      }
    }
    
    if (this.viewType === ViewTypeEnum.WEEK || this.viewType === ViewTypeEnum.DAY) {
      if (newIndex > 0 && newIndex < this.yearDataSource.totalCount() - 1) {
        return;
      }
      if (newIndex === 0) {
        this.monthWeekDataSource.addDataFromHead(this.getWeekList(gap - 1))
        return;
      }
      if (newIndex === this.yearDataSource.totalCount() - 1) {
        this.monthWeekDataSource.addData(this.monthWeekDataSource.totalCount(), this.getWeekList(gap + 1))
      }
    }
  }
  
  /**
   * 当向左滑动到新加载的页面时，重置索引位置，保持滑动连续性
   * @param controller
   */
  private resetIndexToFirst(controller: SwiperController) {
    this.monthWeekCurIndex = 1
    controller.changeIndex(1, false)
  }

  /**
   * 计算滑动后的日期
   * @param direction 滑动方向
   * @returns
   */
  private calculateNextDate(direction: number) {
    let newDate = dayjs();
    // 周视图
    if (this.viewType === ViewTypeEnum.WEEK || this.viewType === ViewTypeEnum.DAY) {
      return newDate = this.selectDate.add(direction, 'week');
    }

    // 年视图
    if (this.viewType === ViewTypeEnum.YEAR) {
      const year = this.selectDate.year() + direction;
      return dayjs().year(year).month(0).date(1);
    }

    // 月视图
    newDate = this.selectDate.add(direction, 'month');
    if (this.locateToCorrespondingDay) {
      newDate = this.nextDate;
    } else {
      if (newDate.year() === this.curDate.year() && newDate.month() === this.curDate.month()) {
        newDate = this.curDate;
      } else {
        newDate = newDate.startOf('month');
      }
    }
    this.locateToCorrespondingDay = false;
    return newDate;
  }

  public isSwiperChange(item: DateModel, swiperController: SwiperController) {
    if (item.isCurrentMonth) {
      return
    }
    if (new Date(item.dateStr) >= new Date(this.selectDate.format('YYYY-MM-DD'))) {
      swiperController.showNext()
    } else {
      swiperController.showPrevious()
    }
  }

  public isDateSelect(item: DateModel) {
    return item.dayjsObj.format('YYYYMMDD') === this.selectDate.format('YYYYMMDD')
  }

  public changeDateInMonthView(date: Date) {
    // 计算指定日期与当前日期的差值
    let gap = (date.getFullYear() - this.curDate.year()) * 12 + date.getMonth() - this.curDate.month()
    console.log('new date::' + date.toDateString() + 'gap::' + gap)
    this.monthWeekDataSource.clearData()
    let i = -2
    while (i <= 2) {
      let month = this.getDateList(i + gap)
      this.monthWeekDataSource.pushData(month)
      i++
    }
    this.monthWeekCurIndex = 2
    this.selectDate = dayjs(date)
    console.log('changedate::' + this.selectDate.format('YYYYMMDD'))
  }

  public updateWeekdayStart(value: number) {
    this.weekStart = value

    // 清除数据
    this.monthWeekDataSource.clearArray()

    // 设置选择日期为今天
    this.selectDate = dayjs()

    // 加载数据
    this.initMonthWeekData()

    // 调整周标题栏
    this.changeWeekdayList()
  }

  // 处理weekDayList
  public changeWeekdayList() {
    // 起始为周日
    if (this.weekStart === 0 && this.weekDayList[0] !== '日') {
      const sunday = this.weekDayList.splice(6, 1)[0];
      this.weekDayList.unshift(sunday);
      return
    }
    // 起始为周一
    if (this.weekStart === 1 && this.weekDayList[0] !== '一') {
      const sunday = this.weekDayList.shift();
      if (sunday !== undefined) {
        this.weekDayList.push(sunday);
      }
    }
  }

  // 生成周数据的方法
  public getWeekList(weekOffset: number): DateModel[] {
    const baseDate = dayjs().add(weekOffset, 'week');
    const weekStart = baseDate.startOf('week').add(this.weekStart, 'day');

    let weekList: DateModel[] = [];

    // 生成一周7天的数据
    for (let i = 0; i < 7; i++) {
      const dayjsObj = weekStart.add(i, 'day');
      const isCurrentMonth = dayjsObj.isSame(this.selectDate, 'month');

      // 农历信息计算
      const lunarDate = Lunar.fromDate(dayjsObj.toDate());
      let lunarDay = this.getLunarInfo(lunarDate).substring(0, 2);
      let lunarFullDate = this.getFullLunarDate(lunarDate);

      const dateModel = new DateModel(
        dayjsObj,
        dayjsObj.date(),
        lunarDay,
        lunarFullDate,
        isCurrentMonth,
        dayjsObj.format('YYYY-M-D')
      );

      weekList.push(dateModel);
    }

    return weekList;
  }

  public getDateList(param: number) {
    const baseDate = dayjs().add(param, 'month');

    // 计算当月首尾日期
    const firstDate = baseDate.startOf('month');
    const afterDate = baseDate.endOf('month');

    // 计算日历起始日（考虑周起始）
    const firstDateDay = firstDate.day();
    const weekStart = this.weekStart % 7;
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

      // 农历信息计算
      const lunarDate = Lunar.fromDate(dayjsObj.toDate());
      let lunarDay = this.getLunarInfo(lunarDate).substring(0, 2);
      let lunarFullDate = this.getFullLunarDate(lunarDate);
      // 创建日期模型
      const dateModel = new DateModel(
        dayjsObj,
        dayjsObj.date(),
        lunarDay,
        lunarFullDate,
        isCurrentMonth,
        dayjsObj.format('YYYY-M-D')
      );

      // 记录当天信息
      if (dayjsObj.isSame(this.selectDate, 'day')) {
        this.todayInfo = dateModel;
      }

      dateList.push(dateModel);
    }

    return dateList;
  }

  /**
   * 获取农历信息（短格式，用于日历显示）
   * @param lunarDate 农历日期对象
   * @returns
   */
  private getLunarInfo(lunarDate: Lunar): string {
    if (lunarDate.getFestivals().length > 0) {
      return lunarDate.getFestivals()[0];
    }
    if (lunarDate.getJieQi()) {
      return lunarDate.getJieQi();
    }
    const day = lunarDate.getDayInChinese();
    return day === '初一' ? lunarDate.getMonthInChinese() + '月' : day;
  }

  /**
   * 获取完整农历日期（如：正月十五）
   * @param lunarDate 农历日期对象
   * @returns
   */
  private getFullLunarDate(lunarDate: Lunar): string {
    const month = lunarDate.getMonthInChinese();
    const day = lunarDate.getDayInChinese();
    return `${month}月${day}`;
  }

  public isToday(item: dayjs.Dayjs): boolean {
    return item.year() === this.curDate.year() && item.month() === this.curDate.month() &&
      item.date() === this.curDate.date()
  }
}

export default CalendarVM