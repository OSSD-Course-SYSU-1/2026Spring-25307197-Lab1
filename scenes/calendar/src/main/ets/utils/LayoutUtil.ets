/*
 *   Copyright (c) 2025 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { TodoItem } from '@ohos_agcit/daily_schedule_component_lib';
import { TimeLineConstants } from '../constant/CalendarConstant';

export class LayoutUtil {
  private static readonly TIMELINE_HEIGHT = 37;
  private static readonly LINE_WIDTH = 1;
  private static readonly GAP = 3;

  /**
   * 计算垂直方向的位置
   * @param item
   * @returns
   */
  static getYPosition(item: TodoItem): number {
    let hours = item.planTime.getHours()
    return hours * LayoutUtil.TIMELINE_HEIGHT +
      (LayoutUtil.TIMELINE_HEIGHT / 2 + LayoutUtil.LINE_WIDTH + LayoutUtil.GAP)
  }

  /**
   * 计算水平方向的位置
   * @param index
   * @returns
   */
  static getXPosition(itemList: TodoItem[], index: number): number {
    let item = itemList[index];
    let hour = item.planTime.getHours()
    let sameHourItems: TodoItem[] = itemList.filter(x => x.planTime.getHours() === hour)
      .sort((a, b) => a.planTime.getTime() - b.planTime.getTime());
    return sameHourItems.indexOf(item) * TimeLineConstants.TODO_CARD_WIDTH + 42
  }
}
