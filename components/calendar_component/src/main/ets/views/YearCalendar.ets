import { CalendarVM } from '../viewmodel/CalendarVM';
import { DateModelList, YearData } from '../models/DateModel';
import { BaseCalendar } from '../views/BaseCalendar';
import dayjs from 'dayjs';
import { TodoItem } from '@ohos_agcit/daily_schedule_component_lib';
import { mediaquery } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';
import { MonthWeekDataSource } from '../models/CalendarDataSource';

@ComponentV2
export struct YearCalendar {
  @Local scrollHeight: number = 0
  @Local currentScreenHeight: number = 0
  swiperController: SwiperController = new SwiperController();
  vm: CalendarVM = CalendarVM.instance;
  portraitHeight: number = 0
  landscapeHeight: number = 300
  gridHeight: number = 120
  gridWidth: number = 104
  columnGap: number = 8
  rowGap: number = 12
  listener: mediaquery.MediaQueryListener | null = null;
  /**
   * 日程卡片信息
   */
  @Param todoData: Map<string, TodoItem[]> = new Map()
  /**
   * 单击回调
   */
  @Param onClickMonth: (index: number) => void = () => {
  };

  aboutToAppear(): void {
    this.listener = this.getUIContext().getMediaQuery().matchMediaSync('(orientation: landscape)')
    
    this.resizeHeight()
    
    this.listener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.resizeHeight()
    });
    this.vm.initYearData()
  }

  aboutToDisappear() {
    if (this.listener) {
      this.listener.off('change');
    }
  }

  resizeHeight() {
    let displayClass = display.getDefaultDisplaySync()
    this.currentScreenHeight = this.getUIContext().px2vp(displayClass?.height)
    let availableArea = this.currentScreenHeight - 300
    let calendarHeight = this.getYearCalendarHeight()
    this.scrollHeight = availableArea < calendarHeight ?  availableArea : calendarHeight
    
    console.info(`availableArea is ${availableArea},calendarHeight is .${calendarHeight}`);
  }

  build() {
    Column() {
      Text(this.vm.selectDate.year() + '年')
        .fontSize($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .height(24)
        .width('100%')
      Blank().height(16)

      Scroll() {
        Swiper(this.swiperController) {
          // 遍历每年
          LazyForEach(this.vm.yearDataSource, (year: MonthWeekDataSource, index: number) => {
            Grid() {
              // 遍历一年中的每个月
              LazyForEach(year, (dataList: DateModelList, index: number) => {
                GridItem() {
                  BaseCalendar({
                    index: index,
                    dataList: dataList,
                    todoData: this.todoData
                  })
                }
                .onClick(() => {
                  this.onClickMonth(index)
                })
              }, (item: DateModelList) => JSON.stringify(item))
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(this.columnGap)
            .rowsGap(this.rowGap)
            .height(this.getYearCalendarHeight())
            .width('100%')
          })
        }
        .loop(false)
        .indicator(false)
        .index(this.vm.monthWeekCurIndex)
        .onChange((index: number) => {
          this.vm.handleHorizontalSwiper(index, index - this.vm.monthWeekCurIndex, this.swiperController);
          console.log('touch on change', dayjs(this.vm.selectDate).format('YYYY-MM-DD'));
        })
      }
      .scrollBar(BarState.Off)
      .height(this.scrollHeight)
    }
    .width('100%')
    .height('100%')
  }

  private getYearCalendarHeight(): number {
    return 4 * this.gridHeight + 3 * this.rowGap;
  }
}