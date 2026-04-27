import { BaseReq, BaseResp } from './Base';
import { Command } from './Constants';
export class OpenCustomerServiceChatReq extends BaseReq {
    checkArgs() {
        if (this.corpId == undefined || this.corpId.length === 0) {
            return false;
        }
        if (this.url == undefined || this.url.length === 0) {
            return false;
        }
        return true;
    }
    get type() {
        return Command.kCommandOpenCustomerServiceChat;
    }
    serializeTo(y4) {
        super.serializeTo(y4);
        y4["wx_open_customer_service_chat_corpId"] = this.corpId;
        y4["wx_open_customer_service_chat_url"] = this.url;
    }
    deserializeFrom(x4) {
        super.deserializeFrom(x4);
        this.corpId = x4["wx_open_customer_service_chat_corpId"];
        this.url = x4["wx_open_customer_service_chat_url"];
    }
}
export class OpenCustomerServiceChatResp extends BaseResp {
    get type() {
        return Command.kCommandOpenCustomerServiceChat;
    }
}
