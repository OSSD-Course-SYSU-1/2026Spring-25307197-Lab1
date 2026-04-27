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

@Component
export struct TimelineBar {
  @Prop firstHour: number;
  @Prop lastHour: number;

  private generateHours(start: number, end: number): number[] {
    let hours: number[] = [];
    for (let i = start; i <= end; i++) {
      hours.push(i);
    }
    return hours;
  }

  build() {
    Column() {
      ForEach(this.generateHours(this.firstHour, this.lastHour), (hour: number) => {
        Row() {
          Text(hour.toString())
            .fontSize($r('sys.float.Body_M'))
            .fontColor('#999')
            .textAlign(TextAlign.Start)
            .width(16)
          Blank().width(10)
          Divider()
            .layoutWeight(1)
            .backgroundColor('#ccc').strokeWidth('1px')
        }
        .height(37)
        .width('100%')
        .padding({left: 16, right: 16})
      },(hour: number)=>JSON.stringify(hour))
    }
    .width('100%')
  }
}