import { BaseReq } from "./Base";
import { Command } from "./Constants";
import { WXMediaMessage } from "./message/SendMessageToWX";
export class LaunchFromWXReq extends BaseReq {
    serializeTo(l2) {
        super.serializeTo(l2);
        if (this.message) {
            let m2 = {};
            this.message.serializeTo(m2);
            l2['message'] = m2;
        }
        l2['lang'] = this.lang;
        l2['country'] = this.country;
    }
    deserializeFrom(k2) {
        super.deserializeFrom(k2);
        if (typeof k2['message'] !== 'undefined') {
            this.message = new WXMediaMessage;
            this.message.deserializeFrom(k2['message']);
        }
        this.lang = k2['lang'];
        this.country = k2['country'];
    }
    checkArgs() {
        return true;
    }
    get type() {
        return Command.kCommandLaunchFromWX;
    }
}
