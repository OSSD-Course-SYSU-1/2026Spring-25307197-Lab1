import { MediaObjectType } from "./SendMessageToWX";
export class WXFileObject {
    constructor() {
        this.type = MediaObjectType.TYPE_FILE;
    }
    serializeTo(k3) {
        k3['fileUri'] = this.fileUri;
    }
    deserializeFrom(j3) {
        this.fileUri = j3["fileUri"];
    }
    ;
    checkArgs() {
        if (this.fileUri == undefined) {
            return false;
        }
        return true;
    }
}
