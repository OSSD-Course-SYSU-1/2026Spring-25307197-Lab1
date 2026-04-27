import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { TodoDataManager } from '@ohos_agcit/daily_schedule_todo';
import { CardManager, PreferenceUtil, Logger } from '@ohos_agcit/daily_schedule_common_lib';
import { preferences } from '@kit.ArkData';

export default class PhoneFormAbility extends FormExtensionAbility {
  dataManager: TodoDataManager = TodoDataManager.instance;

  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    let formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    console.info(`[EntryFormAbility] onAddForm formId: ${formId}`);
    if (!formId) {
      return formBindingData.createFormBindingData({
        text: 'onAddFormWithoutFormId',
      });
    }

    try {
      let preference = preferences.getPreferencesSync(this.context, { name: 'myStore' })
      PreferenceUtil.putToArray(preference, CardManager.KEY_CARD_ID, formId)
      Logger.info(`[EntryFormAbility] onAddForm success: ${formId}`);
    } catch (e) {
      Logger.error(`[EntryFormAbility] onAddForm error: ${e}`);
    }
    return formBindingData.createFormBindingData({});
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    let preference = preferences.getPreferencesSync(this.context, { name: 'myStore' })
    PreferenceUtil.removeFromArray(preference, CardManager.KEY_CARD_ID, formId);
    Logger.info(`[EntryFormAbility] onRemoveForm success: ${formId}`);
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}