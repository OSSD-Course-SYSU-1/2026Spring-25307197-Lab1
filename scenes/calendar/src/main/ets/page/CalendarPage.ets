import { SegmentButton, SegmentController } from './component/SegmentButton';
import { TimelineBar } from './component/TimelineBar';
import { CalendarButtonType } from '../types/Types';
import { CalendarVM, MonthWeekCalendar, ViewTypeEnum, YearCalendar, DateModel } from 'calendar_component';
import { LayoutUtil } from '../utils/LayoutUtil';
import { TimeLineConstants } from '../constant/CalendarConstant';
import { TodoDataManager, TodoSectionList } from '@ohos_agcit/daily_schedule_todo';
import { AvoidArea, TodoCard } from '@ohos_agcit/daily_schedule_component_lib';
import { TodoItem } from '@ohos_agcit/daily_schedule_common_lib';
import { AppStorageV2, curves } from '@kit.ArkUI';
import { ThemeController } from '@ohos_agcit/daily_schedule_common_lib';
import { DataPreferencesUtils } from '../utils/DataPreferencesUtils';
import { Utils } from '../utils/Utils';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { BreakpointType, BreakpointTypeEnum, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';
import dayjs from 'dayjs';
import { Lunar } from 'lunar';
import { DateUtils } from '@ohos_agcit/daily_schedule_common_lib';

@ComponentV2
export struct CalendarPage {
  buttons: string[] = ['年', '月', '周', '日'];
  dataManager: TodoDataManager = TodoDataManager.instance
  controller: Scroller = new Scroller()
  themeController: ThemeController = ThemeController.instance;
  vm: CalendarVM = CalendarVM.instance;
  // 避让区域
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  // 断点控制器 
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
  // 分段式按钮控制器
  @Local segmentController: SegmentController = new SegmentController(0, this.onButtonChange.bind(this));
  // 所有今日待办
  @Local allTodayTodoItems: TodoItem[] = []
  // 时间线中展示的今日待办
  @Local todayTodoItemsInTimeline: TodoItem[] = []
  // 是否展示农历
  @Local isShowLunar: boolean = true
  // 选中的日期信息
  @Local selectedDate: Date = new Date()
  @Local selectedLunarDate: string = ''
  // 待办信息
  @Local todoData: Map<string, TodoItem[]> = new Map()
  // 黄历宜忌
  @Local almanacYi: string = ''
  @Local almanacJi: string = ''

  aboutToAppear(): void {
    this.isShowLunar = this.isSettingLunar()
    this.segmentController.updateActiveIndex(1)
    this.refreshAllTodoCard();
    this.refreshTodayTodoData(new Date());
    DateUtils.initAlmanacCache(getContext(this) as common.UIAbilityContext);
    this.loadAlmanac(new Date());
  }

  /**
   * 监听待办数据变化
   */
  @Monitor('dataManager.refreshNum')
  onTaskMapChange() {
    if (this.dataManager.refreshNum) {
      this.dataManager.refreshNum = 0
      this.refreshAllTodoCard();
      this.refreshTodayTodoData(this.vm.selectDate.toDate());
    }
  }

  /**
   * 监听视图模式变化
   */
  @Monitor('vm.viewType')
  onViewTypeChange() {
    if (this.vm.viewType === ViewTypeEnum.MONTH) {
      this.segmentController.updateActiveIndex(CalendarButtonType.MONTH)
      return;
    }
    if (this.vm.viewType === ViewTypeEnum.WEEK) {
      this.segmentController.updateActiveIndex(CalendarButtonType.WEEK)
      return;
    }
  }

  /**
   * 监听断点变化
   */
  @Monitor('globalInfo.currentBreakpoint')
  onCurrentBreakpointChange() {
    this.refreshTodayTodoData(this.vm.selectDate.toDate())
  }

  /**
   * 判断是否显示分栏布局（平板/PC横屏）
   */
  isSplitLayout(): boolean {
    return this.globalInfo.currentBreakpoint === BreakpointTypeEnum.MD ||
           this.globalInfo.currentBreakpoint === BreakpointTypeEnum.LG;
  }
  
  /**
   * 分段式按钮回调函数
   * @param index
   */
  onButtonChange(index: number) {
    if (this.segmentController.activeIndex === CalendarButtonType.YEAR &&
      this.vm.viewType !== ViewTypeEnum.YEAR) {
      getContext(this).eventHub.emit('viewTypeChange', ViewTypeEnum.YEAR);
      return
    }
    if (this.segmentController.activeIndex === CalendarButtonType.MONTH &&
      this.vm.viewType !== ViewTypeEnum.MONTH) {
      getContext(this).eventHub.emit('viewTypeChange', ViewTypeEnum.MONTH);
      return
    }
    if (this.segmentController.activeIndex === CalendarButtonType.WEEK &&
      this.vm.viewType !== ViewTypeEnum.WEEK) {
      getContext(this).eventHub.emit('viewTypeChange', ViewTypeEnum.WEEK);
      return
    }
    if (this.segmentController.activeIndex === CalendarButtonType.DAY &&
      this.vm.viewType !== ViewTypeEnum.DAY) {
      getContext(this).eventHub.emit('viewTypeChange', ViewTypeEnum.DAY);
      return
    }
  }

  /**
   * 刷新待办数据
   */
  refreshTodayTodoData(date: Date, dateModel?: DateModel) {
    // 更新选中的日期信息
    this.updateSelectedDateInfo(date, dateModel);
    
    this.allTodayTodoItems = Utils.filterTodayTasks(this.dataManager.allTasks, date)


    // 1. 按小时分组
    const groupedByHour = new Map<number, TodoItem[]>();

    this.allTodayTodoItems.forEach(item => {
      const hour = item.planTime.getHours();
      if (!groupedByHour.has(hour)) {
        groupedByHour.set(hour, []);
      }
      groupedByHour.get(hour)?.push(item);
    });

    // 2. 每组内按时间排序
    groupedByHour.forEach(items => {
      items.sort((a, b) => a.planTime.getTime() - b.planTime.getTime());
    });

    // 3. 取每组前N个并合并
    this.todayTodoItemsInTimeline = Array.from(groupedByHour.values())
      .flatMap(items => items.slice(0, new BreakpointType<number>({
        sm: 4,
        md: 8,
        lg: 12,
      }).getValue(this.globalInfo.currentBreakpoint)))
      .sort((a, b) => a.planTime.getTime() - b.planTime.getTime());
  }

  /**
   * 刷新卡片数据
   */
  refreshAllTodoCard() {
    this.todoData = Utils.getAllCard(this.dataManager.taskMap);
  }

  /**
   * 更新选中的日期信息
   * @param date 选中的日期
   * @param dateModel 日期模型（可选，包含农历信息）
   */
  updateSelectedDateInfo(date: Date, dateModel?: DateModel) {
    this.selectedDate = date;
    
    if (dateModel && dateModel.lunarFullDate) {
      // 如果有DateModel且包含完整的农历日期，直接使用
      this.selectedLunarDate = dateModel.lunarFullDate;
    } else {
      // 否则计算农历日期
      const lunarDate = Lunar.fromDate(date);
      const month = lunarDate.getMonthInChinese();
      const day = lunarDate.getDayInChinese();
      this.selectedLunarDate = `${month}月${day}`;
    }
  }

  @Builder
  titleBar() {
    Row() {
      Text($r('app.string.title_calendar'))
        .fontSize($r('sys.float.Title_L'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .height(35)
    .width('100%')
    .padding({ left: '5%', right: '5%' })
  }

  @Builder
  almanacCard() {
    Column() {
      // 标题
      Text('黄历')
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: new BreakpointType<number>({ sm: 12, md: 16, lg: 18 }).getValue(this.globalInfo.currentBreakpoint) })

      if (this.almanacYi || this.almanacJi) {
        // 宜
        if (this.almanacYi) {
          Row() {
            Text('宜')
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#52C41A')
              .fontWeight(FontWeight.Medium)
              .width(new BreakpointType<number>({ sm: 32, md: 40, lg: 48 }).getValue(this.globalInfo.currentBreakpoint))
            Text(this.almanacYi)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .margin({ bottom: new BreakpointType<number>({ sm: 8, md: 12, lg: 14 }).getValue(this.globalInfo.currentBreakpoint) })
        }

        // 忌
        if (this.almanacJi) {
          Row() {
            Text('忌')
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#FF4D4F')
              .fontWeight(FontWeight.Medium)
              .width(new BreakpointType<number>({ sm: 32, md: 40, lg: 48 }).getValue(this.globalInfo.currentBreakpoint))
            Text(this.almanacJi)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }
      } else {
        // 无数据提示
        Text('暂无黄历信息')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_tertiary'))
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding(new BreakpointType<Padding>({
      sm: { left: 20, right: 20, top: 16, bottom: 16 },
      md: { left: 24, right: 24, top: 20, bottom: 20 },
      lg: { left: 28, right: 28, top: 24, bottom: 24 }
    }).getValue(this.globalInfo.currentBreakpoint))
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(new BreakpointType<number>({ sm: 12, md: 16, lg: 20 }).getValue(this.globalInfo.currentBreakpoint))
  }

  @Builder
  segmentButton() {
    SegmentButton({
      tabOptions: this.buttons,
      activeButtonHeight: 35,
      buttonHeight: 40,
      buttonWidth: '90%',
      buttonRadius: 24,
      textFontColor: $r('sys.color.font_secondary'),
      buttonBgColor: $r('sys.color.interactive_pressed'),
      textActiveFontColor: $r('sys.color.font_primary'),
      textActiveBgColor: this.themeController.currentColorMode ===
      ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? $r('sys.color.comp_background_secondary') :
      $r('sys.color.comp_background_primary'),
      controller: this.segmentController
    })
  }

  isSettingLunar() {
    return DataPreferencesUtils.LUNAR_SETTING_OFF !==
    DataPreferencesUtils.getSync(DataPreferencesUtils.LUNAR_SETTING, DataPreferencesUtils.LUNAR_SETTING_ON)
  }

  loadAlmanac(date: Date) {
    let year = date.getFullYear();
    let month = date.getMonth();
    let day = date.getDate();
    let cachedAlmanac = DateUtils.getCacheAlmanac(year, month, day);
    if (cachedAlmanac) {
      this.almanacYi = cachedAlmanac.yi;
      this.almanacJi = cachedAlmanac.ji;
    } else {
      let almanac = DateUtils.getDayAlmanac(year, month, day);
      DateUtils.saveAlmanac(year, month, day, almanac);
      this.almanacYi = almanac.yi;
      this.almanacJi = almanac.ji;
    }
  }

  /**
   * 左侧日历面板（分栏布局）
   */
  @Builder
  calendarPanelBuilder() {
    Column() {
      // 年视图
      YearCalendar({
        todoData: this.todoData,
        onClickMonth: (index) => {
          this.vm.selectDate = dayjs(new Date(this.vm.selectDate.year(), index, 1));
          this.refreshTodayTodoData(new Date(this.vm.selectDate.year(), index, 1))
          this.segmentController.updateActiveIndex(1)
          this.loadAlmanac(new Date(this.vm.selectDate.year(), index, 1))
        }
      })
        .visibility(this.vm.viewType === ViewTypeEnum.YEAR ? Visibility.Visible : Visibility.None)

      // 月周视图
      MonthWeekCalendar({
        selectedStyle: 'circle',
        startWeekday: 'sunday',
        isShowLunar: this.isShowLunar,
        selectedColor: $r('sys.color.multi_color_04'),
        todoData: this.todoData,
        onChangeDay: (date: Date, dateModel?: DateModel) => {
          this.refreshTodayTodoData(date, dateModel)
          this.loadAlmanac(date)
        }
      })
        .visibility(this.vm.viewType !== ViewTypeEnum.YEAR ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 8, top: 8, bottom: 8 })
    .justifyContent(FlexAlign.Start)
  }

  /**
   * 右侧待办面板（分栏布局）
   */
  @Builder
  todoPanelBuilder() {
    Column() {
      // 日期显示区域
      Row() {
        Text(this.selectedDate.toLocaleDateString('zh-CN', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
          weekday: 'long'
        }))
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        if (this.isShowLunar) {
          Text(this.selectedLunarDate)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Regular)
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(12)
      .margin({ bottom: 12 })

      // 待办列表
      TodoSectionList({
        params: [
          {
            label: $r('app.string.title_today'),
            data: this.allTodayTodoItems,
            isShow: true,
          }
        ]
      })
        .layoutWeight(1)

      // 黄历卡片
      Column() {
        this.almanacCard()
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 8, right: 16, top: 8, bottom: 8 })
  }

  /**
   * 分栏布局（平板/PC横屏）
   */
  @Builder
  splitLayoutBuilder() {
    Row() {
      // 左侧：日历面板
      Column() {
        this.titleBar()
        Blank().height(10)
        this.segmentButton()
        Blank().height(12)
        this.calendarPanelBuilder()
      }
      .width('45%')
      .height('100%')

      // 右侧：待办面板
      Column() {
        this.todoPanelBuilder()
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 单列布局（手机）
   */
  @Builder
  singleLayoutBuilder() {
    Column() {
      // 标题
      this.titleBar()
      Blank().height(10)

      // 分段式按钮
      this.segmentButton()
      Blank().height(18)

      Column() {
        // 年视图
        YearCalendar({
          todoData: this.todoData,
          onClickMonth: (index) => {
            this.vm.selectDate = dayjs(new Date(this.vm.selectDate.year(), index, 1));
            this.refreshTodayTodoData(new Date(this.vm.selectDate.year(), index, 1))
            this.segmentController.updateActiveIndex(1)
            this.loadAlmanac(new Date(this.vm.selectDate.year(), index, 1))
          }
        })
          .visibility(this.vm.viewType === ViewTypeEnum.YEAR ? Visibility.Visible : Visibility.None)

        // 月周视图
        MonthWeekCalendar({
          selectedStyle: 'circle',
          startWeekday: 'sunday',
          isShowLunar: this.isShowLunar,
          selectedColor: $r('sys.color.multi_color_04'),
          todoData: this.todoData,
          onChangeDay: (date: Date, dateModel?: DateModel) => {
            this.refreshTodayTodoData(date, dateModel)
            this.loadAlmanac(date)
          }
        })
          .visibility(this.vm.viewType !== ViewTypeEnum.YEAR ? Visibility.Visible : Visibility.None)
      }
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.Start)

      // 待办列表
      if ((this.segmentController.activeIndex === CalendarButtonType.MONTH ||
        this.segmentController.activeIndex === CalendarButtonType.WEEK) &&
        this.vm.viewType !== ViewTypeEnum.MONTH_DETAIL) {
        // 日期显示区域
        Column() {
          Row() {
            // 公历日期
            Text(this.selectedDate.toLocaleDateString('zh-CN', {
              year: 'numeric',
              month: 'long',
              day: 'numeric',
              weekday: 'long'
            }))
              .fontSize($r('sys.float.Title_S'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
            
            // 农历日期
            if (this.isShowLunar) {
              Text(this.selectedLunarDate)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_tertiary'))
                .fontWeight(FontWeight.Regular)
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(12)
          .margin({ bottom: 16 })
          
          Blank().height(8)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        
        TodoSectionList({
          params: [
            {
              label: $r('app.string.title_today'),
              data: this.allTodayTodoItems,
              isShow: true,
            }
          ]
        })
          .layoutWeight(1)

        // 黄历卡片
        Column() {
          this.almanacCard()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }

      // 日程卡片
      if (this.segmentController.activeIndex === CalendarButtonType.DAY) {
        Column() {
          // 日期显示区域
          Row() {
            // 公历日期
            Text(this.selectedDate.toLocaleDateString('zh-CN', {
              year: 'numeric',
              month: 'long',
              day: 'numeric',
              weekday: 'long'
            }))
              .fontSize($r('sys.float.Title_S'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
            
            // 农历日期
            if (this.isShowLunar) {
              Text(this.selectedLunarDate)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_tertiary'))
                .fontWeight(FontWeight.Regular)
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius(12)
          .margin({ bottom: 16 })
          
          Text('待办').width('100%').textAlign(TextAlign.Start).height(50).padding({ left: 20 })
          Column() {
            Scroll(this.controller) {
              Column() {
                Stack({ alignContent: Alignment.TopStart }) {
                  TimelineBar({
                    firstHour: TimeLineConstants.DEFAULT_FIRST_HOUR,
                    lastHour: TimeLineConstants.DEFAULT_LAST_HOUR
                  })
                  Column() {
                    ForEach(this.todayTodoItemsInTimeline, (item: TodoItem, index: number) => {
                      TodoCard({
                        title: item.title,
                        cardHeight: TimeLineConstants.TODO_CARD_HEIGHT,
                        cardWidth: TimeLineConstants.TODO_CARD_WIDTH,
                        color: Utils.chooseCardColor(item)
                      })
                        .position({
                          x: LayoutUtil.getXPosition(this.todayTodoItemsInTimeline, index),
                          y: LayoutUtil.getYPosition(item)
                        })
                    }, (item: TodoItem) => JSON.stringify(item))
                  }
                }
              }
            }
          }
          .layoutWeight(1)
          .width('100%')

          // 黄历卡片
          Column() {
            this.almanacCard()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }
        .layoutWeight(1)
        .transition(TransitionEffect.OPACITY
          .combine(TransitionEffect.scale({ x: 0.9, y: 0.9 }).animation({ curve: curves.springMotion() })))
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: px2vp(this.avoidArea.topRectHeight) })
    .backgroundColor($r('sys.color.background_secondary'))
    .justifyContent(FlexAlign.Start)
  }

  build() {
    Column() {
      if (this.isSplitLayout()) {
        // 平板/PC横屏：分栏布局
        this.splitLayoutBuilder()
      } else {
        // 手机：单列布局
        this.singleLayoutBuilder()
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: px2vp(this.avoidArea.topRectHeight) })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}