import { MediaObjectType } from './SendMessageToWX';
export class WXTextObject {
    constructor() {
        this.type = MediaObjectType.TYPE_TEXT;
    }
    serializeTo(a4) {
        a4['wx_text_object_text'] = this.text;
    }
    deserializeFrom(z3) {
        this.text = z3['wx_text_object_text'];
    }
    checkArgs() {
        if (this.text === undefined || this.text.length === 0) {
            return false;
        }
        return true;
    }
}
