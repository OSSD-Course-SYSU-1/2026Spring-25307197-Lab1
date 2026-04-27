import { MediaObjectType } from './SendMessageToWX';
import { Log } from '../../log/Log';
const TAG = "wxopensdk::WXMiniProgramObject";
export var WXMiniProgramType;
(function (y3) {
    y3[y3["RELEASE"] = 0] = "RELEASE";
    y3[y3["TEST"] = 1] = "TEST";
    y3[y3["PREVIEW"] = 2] = "PREVIEW";
})(WXMiniProgramType || (WXMiniProgramType = {}));
export class WXMiniProgramObject {
    constructor() {
        this.type = MediaObjectType.TYPE_OPENSDK_APPBRAND;
        this.disableForward = false;
        this.isUpdatableMessage = false;
        this.isSecretMessage = false;
    }
    serializeTo(u3) {
        u3["wx_miniprogram_wepageurl"] = this.webpageUrl;
        u3["wx_miniprogram_username"] = this.userName;
        u3["wx_miniprogram_path"] = this.path;
        u3["wx_miniprogram_withshareticket"] = this.withShareTicket;
        u3["wx_miniprogram_type"] = this.miniprogramType;
        u3["wx_miniprogram_disableforward"] = this.disableForward;
        u3["wx_miniprogram_isupdatablemsg"] = this.isUpdatableMessage;
        u3["wx_miniprogram_issecretmsg"] = this.isSecretMessage;
        if (this.extraInfoMap != undefined) {
            const v3 = {};
            this.extraInfoMap.forEach((w3, x3) => {
                v3[x3] = w3;
            });
            u3["wx_miniprogram_extrainfo"] = v3;
        }
    }
    deserializeFrom(s3) {
        this.webpageUrl = s3["wx_miniprogram_wepageurl"];
        this.userName = s3["wx_miniprogram_username"];
        this.path = s3["wx_miniprogram_path"];
        this.withShareTicket = s3["wx_miniprogram_withshareticket"];
        this.miniprogramType = s3["wx_miniprogram_type"];
        this.disableForward = s3["wx_miniprogram_disableforward"];
        this.isUpdatableMessage = s3["wx_miniprogram_isupdatablemsg"];
        this.isSecretMessage = s3["wx_miniprogram_issecretmsg"];
        if (s3["wx_miniprogram_extrainfo"] != undefined) {
            const t3 = s3["wx_miniprogram_extrainfo"];
            this.extraInfoMap = new Map(Object.entries(t3));
        }
    }
    checkArgs() {
        if (this.userName == undefined || this.userName.length == 0) {
            Log.i(TAG, `checkArgs, userName is null`);
            return false;
        }
        if (this.miniprogramType == undefined || this.miniprogramType < WXMiniProgramType.RELEASE || this.miniprogramType > WXMiniProgramType.PREVIEW) {
            Log.i(TAG, `checkArgs, miniprogramType is invalid`);
            return false;
        }
        return true;
    }
    putExtra(q3, r3) {
        if (this.extraInfoMap == undefined) {
            this.extraInfoMap = new Map();
        }
        this.extraInfoMap.set(q3, r3);
    }
    getExtra(o3, p3) {
        return this.extraInfoMap?.get(o3) ?? p3;
    }
}
