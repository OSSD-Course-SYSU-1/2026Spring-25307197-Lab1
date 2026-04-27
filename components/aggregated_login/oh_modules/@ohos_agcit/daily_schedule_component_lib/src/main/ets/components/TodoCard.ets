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

@ComponentV2
export struct TodoCard {
  @Param title: string = ''
  @Param color: ResourceColor = Color.Red
  @Param cardHeight: number = 28
  @Param headWidth: number = 2
  @Param cardWidth: number = 60
  @Param fontWeight: number = 600
  @Param fontSize: number | Resource = $r('sys.float.Body_M')

  build() {
    Column() {
      Row() {
        Column() {
        }
        .height('100%')
        .width(this.headWidth)
        .backgroundColor(this.color)

        Stack() {
          Text(this.title)
            .fontSize(this.fontSize)
            .fontWeight(this.fontWeight)
            .width('100%')
            .height('100%')
            .textAlign(TextAlign.Start)
            .fontColor(this.color)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
          Column() {
          }
          .width('100%')
          .height('100%')
          .backgroundColor(this.color)
          .opacity(0.25)
        }
        .height('100%')
        .width(this.cardWidth)
      }
      .height(this.cardHeight)
      .width(this.headWidth + this.cardWidth)
    }
  }
}