import { MediaObjectType } from "./SendMessageToWX";
export class WXVideoFileObject {
    constructor() {
        this.type = MediaObjectType.TYPE_VIDEO_FILE;
    }
    serializeTo(c4) {
        c4['fileUri'] = this.fileUri;
    }
    deserializeFrom(b4) {
        this.fileUri = b4["fileUri"];
    }
    ;
    checkArgs() {
        if (this.fileUri == undefined) {
            return false;
        }
        return true;
    }
}
