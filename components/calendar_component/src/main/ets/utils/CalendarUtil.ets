/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { DateModel } from '../models/DateModel';

export class CalendarUtil {
  static buildKeyByDateModel(item: DateModel): string {
    const year = item.dayjsObj.year().toString()
    const month = (item.dayjsObj.month() + 1).toString().padStart(2, '0');
    const day = item.dayjsObj.date().toString().padStart(2, '0');
    return `${year}-${month}-${day}`
  }

  static buildDateStringByDate(date: Date): string {
    return date.getFullYear() + '年' + (date.getMonth() + 1) + '月' + date.getDate() + '日'
  }

  static getWeekDescription(date: Date): Resource | undefined {
    const dayOfWeek = date.getDay();

    if (dayOfWeek === 0) {
      return $r('app.string.text_sunday_week')
    }
    if (dayOfWeek === 1) {
      return $r('app.string.text_monday_week')
    }
    if (dayOfWeek === 2) {
      return $r('app.string.text_tuesday_week')
    }
    if (dayOfWeek === 3) {
      return $r('app.string.text_wednesday_week')
    }
    if (dayOfWeek === 4) {
      return $r('app.string.text_thursday_week')
    }
    if (dayOfWeek === 5) {
      return $r('app.string.text_friday_week')
    }
    if (dayOfWeek === 6) {
      return $r('app.string.text_saturday_week')
    }
    return undefined
  }
}