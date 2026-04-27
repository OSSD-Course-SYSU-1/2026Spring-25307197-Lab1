import { formBindingData, formProvider } from '@kit.FormKit';
import { PreferenceUtil } from '../utils/PreferenceUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';

export class FormDataClass {
  titles: Array<string> = []
}

export class CardManager {
  private static instance: CardManager = new CardManager()

  static get(): CardManager {
    return CardManager.instance
  }

  static KEY_CARD_ID = 'card_id'
  static KEY_CARD_INFO = 'card_info'

  public createFormData(data: FormDataClass): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData(data);
  }

  async updateCard(formData: FormDataClass, formId?: string) {
    if (!formData) {
      formData = new FormDataClass()
    }
    let formInfo = this.createFormData(formData);

    let preference = preferences.getPreferencesSync(getContext(), { name: 'myStore' })
    preferences.removePreferencesFromCacheSync(getContext(), { name: 'myStore' });

    let formIdArray: Array<string> = PreferenceUtil.get(preference, CardManager.KEY_CARD_ID) as Array<string>
    if (formIdArray.length === 0) {
      return;
    }

    console.info(`CardManager formIdArray: ${formIdArray}`)
    for (let id of formIdArray) {
      if (formId && id !== formId) {
        continue
      }
      formProvider.updateForm(id, formInfo).then(() => {
        console.info(`CardManager updateForm success. ${JSON.stringify(formData)}`)
      }).catch((error: BusinessError) => {
        console.info(`CardManager updateForm failed. Cause: ${JSON.stringify(error)}`);
      })
    }
  }
}