import { Command } from "./Constants";
import { BaseReq, BaseResp } from "./Base";
export declare class OpenBusinessWebViewReq extends BaseReq {
    queryInfo?: Record<string, string>;
    businessType: number;
    checkArgs(): boolean;
    serializeTo(w4: object): void;
    deserializeFrom(v4: object): void;
    get type(): Command;
}
export declare class OpenBusinessWebViewResp extends BaseResp {
    resultInfo?: string;
    businessType: number;
    serializeTo(u4: object): void;
    deserializeFrom(t4: object): void;
    get type(): Command;
}
