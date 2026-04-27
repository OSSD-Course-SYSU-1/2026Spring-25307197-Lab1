import { MediaObjectType } from './SendMessageToWX';
export class WXWebpageObject {
    constructor() {
        this.type = MediaObjectType.TYPE_URL;
        this.isSecretMessage = false;
    }
    serializeTo(l4) {
        l4['wx_webpage_url'] = this.webpageUrl;
        l4['wx_webpage_extinfo'] = this.extInfo;
        l4['wx_webpage_canvaspagexml'] = this.canvasPageXml;
        l4['wx_webpage_issecretmsg'] = this.isSecretMessage;
        if (this.extraInfoMap != undefined) {
            const m4 = {};
            this.extraInfoMap.forEach((n4, o4) => {
                m4[o4] = n4;
            });
            l4['wx_webpage_extrainfo'] = m4;
        }
    }
    deserializeFrom(j4) {
        this.webpageUrl = j4["wx_webpage_url"];
        this.extInfo = j4['wx_webpage_extinfo'];
        this.canvasPageXml = j4['wx_webpage_canvaspagexml'];
        this.isSecretMessage = j4['wx_webpage_issecretmsg'];
        if (j4["wx_webpage_extrainfo"] != undefined) {
            const k4 = j4["wx_webpage_extrainfo"];
            this.extraInfoMap = new Map(Object.entries(k4));
        }
    }
    checkArgs() {
        if (this.webpageUrl == undefined || this.webpageUrl.length == 0 || this.webpageUrl.length > 1024 * 10) {
            return false;
        }
        return true;
    }
    putExtra(h4, i4) {
        if (this.extraInfoMap == undefined) {
            this.extraInfoMap = new Map();
        }
        this.extraInfoMap.set(h4, i4);
    }
    getExtra(f4, g4) {
        return this.extraInfoMap?.get(f4) ?? g4;
    }
}
