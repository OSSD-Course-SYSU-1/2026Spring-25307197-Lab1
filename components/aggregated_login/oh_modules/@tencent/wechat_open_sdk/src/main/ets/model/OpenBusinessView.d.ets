import { BaseReq, BaseResp } from "./Base";
import { Command } from "./Constants";
export declare class OpenBusinessViewReq extends BaseReq {
    private kTag;
    businessType?: string;
    query?: string;
    extInfo?: string;
    checkArgs(): boolean;
    serializeTo(s4: object): void;
    deserializeFrom(r4: object): void;
    get type(): Command;
}
export declare class OpenBusinessViewResp extends BaseResp {
    extMsg?: string;
    businessType?: string;
    serializeTo(q4: object): void;
    deserializeFrom(p4: object): void;
    get type(): Command;
}
