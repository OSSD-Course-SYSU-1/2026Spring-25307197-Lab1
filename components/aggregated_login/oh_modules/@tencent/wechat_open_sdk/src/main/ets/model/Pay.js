import { BaseReq, BaseResp, Log } from '../../../../Index';
import { Command } from './Constants';
const EXTDATA_MAX_LENGTH = 1024;
export class PayReq extends BaseReq {
    get TAG() {
        return "PaySdk.PayReq";
    }
    checkArgs() {
        if (this.appId?.length === 0) {
            Log.e(this.TAG, "checkArgs fail, invalid appId");
            return false;
        }
        if (this.partnerId?.length === 0) {
            Log.e(this.TAG, "checkArgs fail, invalid partnerId");
            return false;
        }
        if (this.prepayId?.length === 0) {
            Log.e(this.TAG, "checkArgs fail, invalid prepayId");
            return false;
        }
        if (this.nonceStr?.length === 0) {
            Log.e(this.TAG, "checkArgs fail, invalid nonceStr");
            return false;
        }
        if (this.timeStamp?.length === 0) {
            Log.e(this.TAG, "checkArgs fail, invalid timeStamp");
            return false;
        }
        if (this.packageValue?.length === 0) {
            Log.e(this.TAG, "checkArgs fail, invalid packageValue");
            return false;
        }
        if (this.sign?.length === 0) {
            Log.e(this.TAG, "checkArgs fail, invalid sign");
            return false;
        }
        if (this.extData && this.extData.length > EXTDATA_MAX_LENGTH) {
            Log.e(this.TAG, "checkArgs fail, extData length too long");
            return false;
        }
        return true;
    }
    serializeTo(g5) {
        super.serializeTo(g5);
        g5['appId'] = this.appId;
        g5['partnerId'] = this.partnerId;
        g5['prepayId'] = this.prepayId;
        g5['nonceStr'] = this.nonceStr;
        g5['timeStamp'] = this.timeStamp;
        g5['packageValue'] = this.packageValue;
        g5['sign'] = this.sign;
        g5['extData'] = this.extData;
        g5['signType'] = this.signType;
    }
    deserializeFrom(f5) {
        super.deserializeFrom(f5);
        this.appId = f5['appId'];
        this.partnerId = f5['partnerId'];
        this.prepayId = f5['prepayId'];
        this.nonceStr = f5['nonceStr'];
        this.timeStamp = f5['timeStamp'];
        this.packageValue = f5['packageValue'];
        this.sign = f5['sign'];
        this.extData = f5['extData'];
        this.signType = f5['signType'];
    }
    get type() {
        return Command.kCommandPay;
    }
}
export class PayResp extends BaseResp {
    serializeTo(e5) {
        super.serializeTo(e5);
        e5['prepayId'] = this.prepayId;
        e5['returnKey'] = this.returnKey;
        e5['extData'] = this.extData;
    }
    deserializeFrom(d5) {
        super.deserializeFrom(d5);
        this.prepayId = d5['prepayId'];
        this.returnKey = d5['returnKey'];
        this.extData = d5['extData'];
    }
    get type() {
        return Command.kCommandPay;
    }
}
export class JointPayReq extends PayReq {
    get TAG() {
        return "PaySdk.JointPayReq";
    }
    get type() {
        return Command.kCommandJointPay;
    }
}
export class JointPayResp extends PayResp {
    get type() {
        return Command.kCommandJointPay;
    }
}
