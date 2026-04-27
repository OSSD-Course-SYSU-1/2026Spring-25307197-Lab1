import { MediaObjectType } from "./SendMessageToWX";
export class WXVideoObject {
    constructor() {
        this.type = MediaObjectType.TYPE_VIDEO;
    }
    serializeTo(e4) {
        e4['videoUrl'] = this.videoUrl;
        e4['videoLowBandUrl'] = this.videoLowBandUrl;
    }
    deserializeFrom(d4) {
        this.videoUrl = d4["videoUrl"];
        this.videoLowBandUrl = d4["videoLowBandUrl"];
    }
    checkArgs() {
        if ((this.videoUrl == undefined || this.videoUrl.length == 0)
            && (this.videoLowBandUrl == undefined || this.videoLowBandUrl.length == 0)) {
            return false;
        }
        return true;
    }
}
