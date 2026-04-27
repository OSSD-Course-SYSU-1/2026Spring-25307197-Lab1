import { SendAuthReq, SendAuthResp } from './SendAuth';
import { Command } from './Constants';
export declare class SendTdiAuthReq extends SendAuthReq {
    get type(): Command;
}
export declare class SendTdiAuthResp extends SendAuthResp {
    tdiAuthBuffer?: Uint8Array;
    serializeTo(m5: object): void;
    deserializeFrom(l5: object): void;
    get type(): Command;
}
