import { MediaObjectType } from './SendMessageToWX';
export class WXImageObject {
    constructor() {
        this.type = MediaObjectType.TYPE_IMAGE;
    }
    serializeTo(m3) {
        m3['imageBase64'] = this.imageData;
        m3['uri'] = this.uri;
    }
    deserializeFrom(l3) {
        this.imageData = l3['imageBase64'];
        this.uri = l3['uri'];
    }
    checkArgs() {
        if (this.uri === undefined) {
            return false;
        }
        return true;
    }
}
