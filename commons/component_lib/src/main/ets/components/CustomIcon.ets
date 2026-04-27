import { CustomIconOptions } from '../types/CustomIconOptions'


@Builder
export function CustomIcon(options: CustomIconOptions) {
  Stack({ alignContent: Alignment.Center }) {
    Circle()
      .width(options.size ?? 40)
      .height(options.size ?? 40)
      .fill(options.backgroundColor ?? $r('sys.color.comp_background_tertiary'))

    SymbolGlyph(options.resource)
      .fontSize(options.fontSize ?? 20)
      .fontColor([options.fontColor ?? $r('sys.color.icon_on_primary')])
  }
  .onClick(options.onClick)
}
