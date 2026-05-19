import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';

interface DateData {
  day?: string;
  month?: string;
  weekDay?: string;
}

export default class DynamicIconFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    // 返回初始数据
    const now = new Date();
    const month = now.getMonth() + 1;
    const date = now.getDate();
    const dayOfWeek = now.getDay();
    const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
    
    const data: DateData = {
      day: date < 10 ? `0${date}` : `${date}`,
      month: `${month}月`,
      weekDay: `周${weekdays[dayOfWeek]}`
    };
    
    return formBindingData.createFormBindingData(data);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    console.info(`[DynamicIconFormAbility] onUpdateForm: ${formId}`);
    
    // 创建新的日期数据
    const now = new Date();
    const month = now.getMonth() + 1;
    const date = now.getDate();
    const dayOfWeek = now.getDay();
    const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
    
    const data: DateData = {
      day: date < 10 ? `0${date}` : `${date}`,
      month: `${month}月`,
      weekDay: `周${weekdays[dayOfWeek]}`
    };
    
    return formBindingData.createFormBindingData(data);
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    console.info(`[DynamicIconFormAbility] onRemoveForm: ${formId}`);
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}