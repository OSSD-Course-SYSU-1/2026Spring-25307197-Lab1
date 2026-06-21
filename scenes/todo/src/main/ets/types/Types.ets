import { TodoItem } from '@ohos_agcit/daily_schedule_common_lib';

export interface SheetCallbacks {
  onConfirm: () => void;
  onClose: () => void;
}

export interface SectionParam {
  label: string | Resource;
  data: TodoItem[];
  isShow: boolean;
}