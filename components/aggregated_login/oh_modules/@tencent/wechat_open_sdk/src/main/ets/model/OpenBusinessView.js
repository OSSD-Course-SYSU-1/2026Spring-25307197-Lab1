import { Log } from '../log/Log';
import { BaseReq, BaseResp } from "./Base";
import { Command } from "./Constants";
export class OpenBusinessViewReq extends BaseReq {
    constructor() {
        super(...arguments);
        this.kTag = 'wxopensdk::OpenBusinessView';
    }
    checkArgs() {
        if (!this.businessType || this.businessType.length === 0) {
            Log.e(this.kTag, 'businessType is invalid');
            return false;
        }
        return true;
    }
    serializeTo(s4) {
        super.serializeTo(s4);
        s4['businessType'] = this.businessType;
        s4['query'] = this.query;
        s4['extInfo'] = this.extInfo;
    }
    deserializeFrom(r4) {
        super.deserializeFrom(r4);
        this.businessType = r4['businessType'];
        this.query = r4['query'];
        this.extInfo = r4['extInfo'];
    }
    get type() {
        return Command.kCommandOpenBusinessView;
    }
}
export class OpenBusinessViewResp extends BaseResp {
    serializeTo(q4) {
        super.serializeTo(q4);
        q4['extMsg'] = this.extMsg;
        q4['businessType'] = this.businessType;
    }
    deserializeFrom(p4) {
        super.deserializeFrom(p4);
        this.extMsg = p4['extMsg'];
        this.businessType = p4['businessType'];
    }
    get type() {
        return Command.kCommandOpenBusinessView;
    }
}
