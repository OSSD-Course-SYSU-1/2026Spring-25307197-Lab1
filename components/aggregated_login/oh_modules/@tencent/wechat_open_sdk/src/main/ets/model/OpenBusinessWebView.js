import { Command } from "./Constants";
import { BaseReq, BaseResp } from "./Base";
export class OpenBusinessWebViewReq extends BaseReq {
    constructor() {
        super(...arguments);
        this.businessType = 0;
    }
    checkArgs() {
        return true;
    }
    serializeTo(w4) {
        super.serializeTo(w4);
        w4['queryInfo'] = this.queryInfo;
        w4['businessType'] = this.businessType;
    }
    deserializeFrom(v4) {
        super.deserializeFrom(v4);
        this.queryInfo = v4['queryInfo'];
        this.businessType = v4['businessType'];
    }
    get type() {
        return Command.kCommandOpenBusinessWebView;
    }
}
export class OpenBusinessWebViewResp extends BaseResp {
    constructor() {
        super(...arguments);
        this.businessType = 0;
    }
    serializeTo(u4) {
        super.serializeTo(u4);
        u4['resultInfo'] = this.resultInfo;
        u4['businessType'] = this.businessType;
    }
    deserializeFrom(t4) {
        super.deserializeFrom(t4);
        this.resultInfo = t4['resultInfo'];
        this.businessType = t4['businessType'];
    }
    get type() {
        return Command.kCommandOpenBusinessWebView;
    }
}
