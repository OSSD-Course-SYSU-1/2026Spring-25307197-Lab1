import { BaseReq, BaseResp } from './Base';
export declare class SendAuthReq extends BaseReq {
    scope?: string;
    state?: string;
    extData?: string;
    isOption1: boolean;
    nonAutomatic: boolean;
    checkArgs(): boolean;
    serializeTo(k5: object): void;
    deserializeFrom(j5: object): void;
    get type(): number;
}
export declare class SendAuthResp extends BaseResp {
    code?: string;
    state?: string;
    authResult: boolean;
    url?: string;
    lang?: string;
    country?: string;
    serializeTo(i5: object): void;
    deserializeFrom(h5: object): void;
    get type(): number;
}
