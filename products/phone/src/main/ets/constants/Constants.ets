import { TabListItem } from '../types/Types';

export const TAB_LIST: TabListItem[] = [
  {
    label: $r('app.string.schedule'),
    icon: $r('app.media.todo_unchecked'),
    iconChecked: $r('app.media.todo_checked'),
    titleBackgroundColor: Color.White
  },
  {
    label: $r('app.string.calendar'),
    icon: $r('app.media.calendar_unchecked'),
    iconChecked: $r('app.media.calendar_checked'),
    titleBackgroundColor: Color.White
  },
  {
    label: $r('app.string.mine'),
    icon: $r('app.media.mine_unchecked'),
    iconChecked: $r('app.media.mine_checked'),
    titleBackgroundColor: $r('app.color.title_background_color')
  }
];