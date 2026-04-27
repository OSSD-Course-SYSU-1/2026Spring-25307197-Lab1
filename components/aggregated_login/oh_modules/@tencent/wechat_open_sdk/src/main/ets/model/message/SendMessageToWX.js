import { BaseResp } from '../../../../../Index';
import { BaseReq } from '../../../../../Index';
import { Command } from '../Constants';
import { WXMediaObjectFactory } from './WXMediaObjectFactory';
import util from "@ohos.util";
export class SendMessageToWXReq extends BaseReq {
    constructor() {
        super(...arguments);
        this.scene = SendMessageToWXReq.WXSceneSession;
    }
    serializeTo(h3) {
        super.serializeTo(h3);
        if (this.message !== undefined) {
            let i3 = {};
            this.message.serializeTo(i3);
            h3['message'] = i3;
        }
        h3['scene'] = this.scene;
    }
    deserializeFrom(g3) {
        super.deserializeFrom(g3);
        if (typeof g3['message'] !== 'undefined') {
            this.message = new WXMediaMessage;
            this.message.deserializeFrom(g3['message']);
        }
        this.scene = g3['scene'];
    }
    checkArgs() {
        if (this.message === undefined) {
            return false;
        }
        return this.message.checkArgs();
    }
    get type() {
        return Command.kCommandSendMessageToWX;
    }
}
SendMessageToWXReq.WXSceneSession = 0;
SendMessageToWXReq.WXSceneTimeline = 1;
export class SendMessageToWXResp extends BaseResp {
    serializeTo(f3) {
        super.serializeTo(f3);
    }
    deserializeFrom(e3) {
        super.deserializeFrom(e3);
    }
    get type() {
        return Command.kCommandSendMessageToWX;
    }
}
export var MediaObjectType;
(function (d3) {
    d3[d3["TYPE_TEXT"] = 1] = "TYPE_TEXT";
    d3[d3["TYPE_IMAGE"] = 2] = "TYPE_IMAGE";
    d3[d3["TYPE_VIDEO"] = 4] = "TYPE_VIDEO";
    d3[d3["TYPE_URL"] = 5] = "TYPE_URL";
    d3[d3["TYPE_FILE"] = 6] = "TYPE_FILE";
    d3[d3["TYPE_OPENSDK_APPBRAND"] = 36] = "TYPE_OPENSDK_APPBRAND";
    d3[d3["TYPE_VIDEO_FILE"] = 38] = "TYPE_VIDEO_FILE";
})(MediaObjectType || (MediaObjectType = {}));
export class WXMediaMessage {
    constructor() {
        this.title = '';
        this.description = "";
    }
    serializeTo(z2) {
        z2['wx_media_message_title'] = this.title;
        z2['wx_media_message_description'] = this.description;
        if (this.mediaObject !== undefined) {
            z2['wx_media_message_media_object_type'] = this.mediaObject.type;
            let c3 = {};
            this.mediaObject.serializeTo(c3);
            z2['wx_media_message_media_object'] = c3;
        }
        if (this.thumbData != undefined) {
            const a3 = new util.Base64Helper();
            const b3 = a3.encodeToStringSync(this.thumbData);
            z2['wx_media_message_thumb_data'] = b3;
        }
        z2['wx_media_message_media_tag_name'] = this.mediaTagName;
        z2['wx_media_message_message_action'] = this.messageAction;
        z2['wx_media_message_message_ext'] = this.messageExt;
    }
    deserializeFrom(v2) {
        this.title = v2['wx_media_message_title'];
        this.description = v2['wx_media_message_description'];
        if (typeof v2['wx_media_message_media_object_type'] === 'number' &&
            typeof v2['wx_media_message_media_object'] === 'object') {
            let y2 = WXMediaObjectFactory.createMediaObject(v2['wx_media_message_media_object_type']);
            if (y2 !== undefined) {
                y2.deserializeFrom(v2['wx_media_message_media_object']);
            }
            this.mediaObject = y2;
        }
        if (v2["wx_media_message_thumb_data"] != undefined) {
            const w2 = v2["wx_media_message_thumb_data"];
            const x2 = new util.Base64Helper();
            this.thumbData = x2.decodeSync(w2);
        }
        this.mediaTagName = v2['wx_media_message_media_tag_name'];
        this.messageAction = v2['wx_media_message_message_action'];
        this.messageExt = v2['wx_media_message_message_ext'];
    }
    checkArgs() {
        if (this.mediaObject === undefined) {
            return false;
        }
        return this.mediaObject.checkArgs();
    }
}
