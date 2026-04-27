import { BaseReq, BaseResp } from "./Base";
import { Command } from "./Constants";
export class OpenWebViewReq extends BaseReq {
    checkArgs() {
        return this.url !== undefined && this.url.length > 0;
    }
    serializeTo(c5) {
        super.serializeTo(c5);
        c5['url'] = this.url;
    }
    deserializeFrom(b5) {
        super.deserializeFrom(b5);
        this.url = b5['url'];
    }
    get type() {
        return Command.kCommandOpenWebView;
    }
}
export class OpenWebViewResp extends BaseResp {
    serializeTo(a5) {
        super.serializeTo(a5);
        a5['result'] = this.result;
    }
    deserializeFrom(z4) {
        super.deserializeFrom(z4);
        this.result = z4['result'];
    }
    get type() {
        return Command.kCommandOpenWebView;
    }
}
