export class BaseReq {
    constructor() {
        this.id = 0;
        this.name = this.constructor.name;
    }
    serializeTo(h2) {
        h2['__type__'] = this.type;
        h2['transaction'] = this.transaction;
        h2['openId'] = this.openId;
        h2['callbackAbility'] = this.callbackAbility;
    }
    deserializeFrom(g2) {
        this.transaction = g2['transaction'];
        this.openId = g2['openId'];
        this.callbackAbility = g2['callbackAbility'];
    }
}
export var ErrCode;
(function (f2) {
    f2[f2["ERR_OK"] = 0] = "ERR_OK";
    f2[f2["ERR_COMM"] = -1] = "ERR_COMM";
    f2[f2["ERR_USER_CANCEL"] = -2] = "ERR_USER_CANCEL";
    f2[f2["ERR_SENT_FAILED"] = -3] = "ERR_SENT_FAILED";
    f2[f2["ERR_AUTH_DENIED"] = -4] = "ERR_AUTH_DENIED";
    f2[f2["ERR_UNSUPPORTED"] = -5] = "ERR_UNSUPPORTED";
    f2[f2["ERR_BAN"] = -6] = "ERR_BAN";
    f2[f2["ERR_SCOPE_SNSAPI_WXAAPP_INFO_CAN_ONLY_AUTHORIZED_SEPARATELY"] = -1000] = "ERR_SCOPE_SNSAPI_WXAAPP_INFO_CAN_ONLY_AUTHORIZED_SEPARATELY";
})(ErrCode || (ErrCode = {}));
export class BaseResp {
    constructor() {
        this.id = 0;
        this.name = this.constructor.name;
        this.errCode = ErrCode.ERR_OK;
    }
    serializeTo(e2) {
        e2['__type__'] = this.type;
        e2['errCode'] = this.errCode;
        e2['errStr'] = this.errStr;
        e2['transaction'] = this.transaction;
        e2['openId'] = this.openId;
    }
    deserializeFrom(d2) {
        this.errCode = d2['errCode'] ?? ErrCode.ERR_COMM;
        this.errStr = d2['errStr'];
        this.transaction = d2['transaction'];
        this.openId = d2['openId'];
    }
}
