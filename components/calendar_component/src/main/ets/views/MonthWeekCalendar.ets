import dayjs from 'dayjs';
import CalendarVM from '../viewmodel/CalendarVM';
import { CalendarHeaderItem, DateModel, DateModelList } from '../models/DateModel';
import { CalendarUtil } from '../utils/CalendarUtil';
import { ViewTypeEnum } from '../enum/CalendarEnum';
import { CommonConstants } from '../constants/CommonContants';
import { PriorityEnum, TodoCard, TodoItem } from '@ohos_agcit/daily_schedule_component_lib';

@ComponentV2
export struct MonthWeekCalendar {
  vm: CalendarVM = CalendarVM.instance;
  swiperController: SwiperController = new SwiperController();
  dateTimeController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.dateTimeDialog();
    },
    alignment: DialogAlignment.Center
  });
  /**
   * 日程卡片信息
   */
  @Param todoData: Map<string, TodoItem[]> = new Map()
  /**
   * 选择日期时的回调
   */
  @Param onChangeDay: (date: Date, dateModel?: DateModel) => void = () => {
  }
  /**
   * 时间筛选器的时间
   */
  @Local pickerTime: Date = new Date()
  /**
   * 自定义选中颜色
   */
  @Param selectedColor: ResourceStr | Color = '#C4272B'
  /*
   * 图标形状
   * */
  @Param selectedStyle: 'circle' | 'squares' = 'circle'
  /*
   * 周首日 0=周日, 1=周一
   * */
  @Param startWeekday: 'sunday' | 'monday' = 'monday'
  /*
   * 是否展示农历
   * */
  @Param isShowLunar: boolean = true
  /**
   * 是否显示头部
   */
  @Param isShowHeader: boolean = true
  /**
   * 网格宽度
   */
  @Local gridWidth: number = 48
  /**
   * 网格高度
   */
  @Local gridHeight: number = 46
  /**
   * 自定义头部项插槽
   */
  @BuilderParam calendarHeaderBuilder?: (item: CalendarHeaderItem) => void

  aboutToAppear() {
    this.initCalendar()

    // eventbus
    getContext(this).eventHub.on('viewTypeChange', (data: number) => {
      if (data === ViewTypeEnum.YEAR) {
        this.vm.viewType = ViewTypeEnum.YEAR
        return
      }
      if (data === ViewTypeEnum.MONTH) {
        this.vm.viewType = ViewTypeEnum.MONTH
        this.vm.generateMonthData()
        return
      }
      if (data === ViewTypeEnum.WEEK) {
        this.vm.viewType = ViewTypeEnum.WEEK
        this.vm.generateWeekData()
        return
      }
      if (data === ViewTypeEnum.DAY) {
        this.vm.viewType = ViewTypeEnum.DAY
        this.vm.generateWeekData()
        return
      }
    });
  }

  initCalendar() {
    const week = this.startWeekday === 'sunday' ? 0 : 1 // 0=周日, 1=周一
    // 更新日历数据，以及调整起始日
    this.vm.updateWeekdayStart(week)

    // 设置选择的日期为今天
    this.vm.selectDate = dayjs();

    // 切换日期，并更新日历数据
    this.vm.changeDateInMonthView(new Date())
  }

  /**
   * 日期选择器弹窗
   */
  @Builder
  dateTimeDialog() {
    Column() {
      Row() {
        Text() {
          Span(CalendarUtil.buildDateStringByDate(this.pickerTime))
          Span(' ')
          Span(CalendarUtil.getWeekDescription(this.pickerTime))
        }
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(70)

      // 日期选择器
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2099-12-31'),
        selected: this.pickerTime
      })
        .height(220)
        .expandSafeArea()
        .textStyle({
          font: {
            size: $r('sys.float.Subtitle_M'),
            weight: FontWeight.Normal
          },
          color: $r('sys.color.font_primary')
        })
        .selectedTextStyle({
          color: $r('sys.color.multi_color_04'),
          font: {
            size: $r('sys.float.Title_S'),
            weight: FontWeight.Bold
          }
        })
        .lunar(false)
        .onDateChange((value: Date) => {
          this.pickerTime = value
        })

      Row() {
        Row() {
          Text($r('app.string.text_cancel'))
            .fontColor($r('sys.color.font_tertiary'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.dateTimeController.close();
        })

        Row() {
          Text($r('app.string.text_confirm'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.multi_color_04'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          // TODO 需要根据日、周进行适配
          this.vm.changeDateInMonthView(this.pickerTime)
          this.onChangeDay(this.vm.selectDate.toDate())
          this.dateTimeController.close();
        })
      }
      .width('100%')
      .height(60)
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(32)
    .height(350)
    .width('100%')
  }

  /**
   * 日历头
   */
  @Builder
  calendarHeader() {
    Row() {
      Row() {
        Text(this.vm.selectDate.format('YYYY年MM月'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Medium)
        SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
          .fontSize(15)
          .fontColor([$r('sys.color.ohos_id_color_foreground')])
          .margin({ left: 5 });
      }
      .height(24)
      .onClick(() => {
        this.dateTimeController.open();
      });
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  /**
   * 底部导航
   */
  @Builder
  endNavigation() {
    Column() {
      Column() {
      }
      .borderRadius(2.5)
      .backgroundColor($r('sys.color.icon_fourth'))
      .width(50)
      .height(5)
    }
    .width('100%')
    .height(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      // 日期选择
      Column() {
        if (this.calendarHeaderBuilder) {
          this.calendarHeaderBuilder(this.getHeaderItem())
        } else {
          this.calendarHeader()
        }
      }
      .visibility(this.isShowHeader ? Visibility.Visible : Visibility.None)

      Blank().height(16)

      // 星期栏
      Row() {
        ForEach(this.vm.weekDayList, (item: string) => {
          Text(item)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center);
        }, (item: string) => item);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: 16 })

      // 日历
      Swiper(this.swiperController) {
        LazyForEach(this.vm.monthWeekDataSource, (item: DateModelList) => {
          Grid() {
            ForEach(item, (item: DateModel) => {
              GridItem() {
                Stack({ alignContent: Alignment.Top }) {
                  Column() {

                  }
                  .width(32)
                  .height(32)
                  .backgroundColor(this.vm.isDateSelect(item) ? this.selectedColor : '#00ffffff')
                  .borderRadius(this.selectedStyle === 'squares' ? 0 : 24)
                  .zIndex(0)

                  Column() {
                    Text(this.vm.isToday(item.dayjsObj) ? '今' : item.day.toString())
                      .width(this.gridWidth)
                      .textAlign(TextAlign.Center)
                      .fontSize($r('sys.float.Body_S'))
                      .height(16)
                      .fontWeight(FontWeight.Medium)
                      .opacity(this.vm.viewType === ViewTypeEnum.WEEK ? 1 : item.isCurrentMonth ? 1 : 0.4)
                      .fontColor(this.chooseTextColor(item))

                    Text(item.lunarDay)
                      .width(this.gridWidth)
                      .textAlign(TextAlign.Center)
                      .fontSize(10)
                      .height(16)
                      .fontWeight(FontWeight.Regular)
                      .fontColor(this.chooseTextColor(item))
                      .opacity(this.vm.viewType === ViewTypeEnum.WEEK ? 1 : item.isCurrentMonth ? 1 : 0.4)
                      .visibility(this.isShowLunar ? Visibility.Visible : Visibility.None)
                    if (this.vm.viewType === ViewTypeEnum.MONTH) {
                      Blank().height(16)
                    }

                    Column({ space: 2 }) {
                      ForEach(this.todoData.get(dayjs(item.dayjsObj).format('YYYY-MM-DD')), (item: TodoItem) => {
                        TodoCard({
                          title: item.title,
                          color: this.chooseCardColor(item),
                          cardHeight: 12,
                          headWidth: 2.32,
                          cardWidth: 41.68,
                          fontSize: 8,
                          fontWeight: FontWeight.Regular
                        })
                      }, (item: string) => JSON.stringify(item))
                    }
                    .visibility(this.vm.viewType === ViewTypeEnum.MONTH_DETAIL ? Visibility.Visible : Visibility.None)
                    .padding({ left: 5, right: 5 })
                  }
                  .zIndex(1)
                  .position({ x: 0, y: 0 })
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                }
                .width(this.gridWidth)
                .height(this.gridHeight)
                .onClick(() => {
                  // 周视图、日视图
                  if (this.vm.viewType === ViewTypeEnum.WEEK || this.vm.viewType === ViewTypeEnum.DAY) {
                    this.vm.selectDate = item.dayjsObj;
                    this.pickerTime = item.dayjsObj.toDate()
                    this.onChangeDay(this.vm.selectDate.toDate(), item)
                    return;
                  }
                  // 月视图
                  if (!item.isCurrentMonth) {
                    // 点击的日期不在本月
                    this.vm.locateToCorrespondingDay = true
                    this.vm.nextDate = item.dayjsObj
                    this.vm.isSwiperChange(item, this.swiperController)
                  } else {
                    // 点击的日期在本月
                    this.vm.selectDate = item.dayjsObj;
                  }
                  this.pickerTime = item.dayjsObj.toDate()
                  this.onChangeDay(this.vm.selectDate.toDate(), item)
                });
              }
              .gesture(
                PanGesture({ direction: PanDirection.Vertical })
                  .onActionStart((event: GestureEvent) => {
                    // 上滑手势
                    if (event.offsetY < -CommonConstants.PAN_GESTURE_OFFSET) {
                      if (this.vm.viewType === ViewTypeEnum.MONTH) {
                        this.vm.switchToWeekView();
                        this.gridHeight = 46
                        return
                      }
                      if (this.vm.viewType === ViewTypeEnum.MONTH_DETAIL) {
                        this.vm.switchToMonthView();
                        this.gridHeight = 46
                        return
                      }
                    }
                    // 下滑手势
                    if (event.offsetY > CommonConstants.PAN_GESTURE_OFFSET) {
                      if (this.vm.viewType === ViewTypeEnum.WEEK || this.vm.viewType === ViewTypeEnum.DAY) {
                        this.vm.switchToMonthView();
                        this.gridHeight = 46
                        return
                      }
                      if (this.vm.viewType === ViewTypeEnum.MONTH) {
                        this.vm.switchToMonthDetailView()
                        this.gridHeight = 46 + 30
                      }
                    }
                  })
              );
            }, (item: DateModel) => JSON.stringify(item));
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .columnsGap(0)
          .rowsGap(0)
          .height(this.gridHeight * Math.ceil(item.length / 7) + 10)
          .padding({ bottom: 20 })
        }, (item: DateModelList) => JSON.stringify(item));
      }
      .cachedCount(0)
      .indicator(false)
      .index(this.vm.monthWeekCurIndex)
      .loop(false)
      .itemSpace(0)
      .effectMode(EdgeEffect.None)
      .onAnimationEnd((index: number) => {
        this.vm.handleHorizontalSwiper(index, index - this.vm.monthWeekCurIndex, this.swiperController);
        this.onChangeDay(this.vm.selectDate.toDate(), undefined)
        console.log('touch on change', dayjs(this.vm.selectDate).format('YYYY-MM-DD'));
      })

      this.endNavigation()
    }
    .borderRadius({
      bottomLeft: 16,
      bottomRight: 16,
    })
  }

  chooseTextColor(item: DateModel): ResourceColor {
    if (this.vm.isDateSelect(item)) {
      return $r('sys.color.font_on_primary')
    }
    const dateKey = CalendarUtil.buildKeyByDateModel(item);
    return this.todoData.has(dateKey) ? $r('sys.color.multi_color_04') : $r('sys.color.font_primary');
  }

  chooseCardColor(item: TodoItem): ResourceColor | undefined {
    if (item.priorityType === PriorityEnum.NO) {
      return $r('app.color.card_gray')
    }
    if (item.priorityType === PriorityEnum.LOW) {
      return $r('app.color.card_green')
    }
    if (item.priorityType === PriorityEnum.MID) {
      return $r('app.color.card_orange')
    }
    if (item.priorityType === PriorityEnum.HIGH) {
      return $r('app.color.card_red')
    }
    return $r('app.color.card_gray')
  }

  /**
   * 获取日历头部项
   */
  getHeaderItem(): CalendarHeaderItem {
    const headerItem = new CalendarHeaderItem();
    headerItem.dateStr = this.vm.selectDate.format('YYYY年MM月');
    headerItem.lunarDay = '';
    headerItem.lunarFullDate = '';
    return headerItem;
  }
}