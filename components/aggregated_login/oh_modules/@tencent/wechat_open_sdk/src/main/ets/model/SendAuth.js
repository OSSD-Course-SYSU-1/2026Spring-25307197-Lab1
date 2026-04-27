import { BaseReq, BaseResp } from './Base';
import { Command } from './Constants';
export class SendAuthReq extends BaseReq {
    constructor() {
        super(...arguments);
        this.isOption1 = false;
        this.nonAutomatic = false;
    }
    checkArgs() {
        this.scope = this.scope?.trim();
        if ((this.scope?.length ?? 0) === 0) {
            return false;
        }
        return true;
    }
    serializeTo(k5) {
        super.serializeTo(k5);
        k5['scope'] = this.scope;
        k5['state'] = this.state;
        k5['extData'] = this.extData;
        k5['isOption1'] = this.isOption1;
        k5['nonAutomatic'] = this.nonAutomatic;
    }
    deserializeFrom(j5) {
        super.deserializeFrom(j5);
        this.scope = j5['scope'];
        this.state = j5['state'];
        this.extData = j5['extData'];
        this.isOption1 = j5['isOption1'] ?? false;
        this.nonAutomatic = j5['nonAutomatic'] ?? false;
    }
    get type() {
        return Command.kCommandSendAuth;
    }
}
export class SendAuthResp extends BaseResp {
    constructor() {
        super(...arguments);
        this.authResult = false;
    }
    serializeTo(i5) {
        super.serializeTo(i5);
        i5['code'] = this.code;
        i5['state'] = this.state;
        i5['authResult'] = this.authResult;
        i5['url'] = this.url;
        i5['lang'] = this.lang;
        i5['country'] = this.country;
    }
    deserializeFrom(h5) {
        super.deserializeFrom(h5);
        this.code = h5['code'];
        this.state = h5['state'];
        this.authResult = h5['authResult'];
        this.url = h5['url'];
        this.lang = h5['lang'];
        this.country = h5['country'];
    }
    get type() {
        return Command.kCommandSendAuth;
    }
}
