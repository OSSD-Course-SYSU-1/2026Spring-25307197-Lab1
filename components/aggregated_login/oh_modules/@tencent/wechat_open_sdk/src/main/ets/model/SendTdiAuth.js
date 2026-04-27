import { SendAuthReq, SendAuthResp } from './SendAuth';
import { Command } from './Constants';
export class SendTdiAuthReq extends SendAuthReq {
    get type() {
        return Command.kCommandSendTdiAuth;
    }
}
export class SendTdiAuthResp extends SendAuthResp {
    serializeTo(m5) {
        super.serializeTo(m5);
        if (this.tdiAuthBuffer != undefined) {
            m5['tdiAuthBuffer'] = Array.from(this.tdiAuthBuffer);
        }
    }
    deserializeFrom(l5) {
        super.deserializeFrom(l5);
        if (Array.isArray(l5['tdiAuthBuffer'])) {
            this.tdiAuthBuffer = new Uint8Array(l5['tdiAuthBuffer']);
        }
    }
    get type() {
        return Command.kCommandSendTdiAuth;
    }
}
