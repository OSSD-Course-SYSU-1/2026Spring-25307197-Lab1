import { BaseReq, BaseResp } from "./Base";
import { Command } from "./Constants";
export declare class OpenWebViewReq extends BaseReq {
    url?: string;
    checkArgs(): boolean;
    serializeTo(c5: object): void;
    deserializeFrom(b5: object): void;
    get type(): Command;
}
export declare class OpenWebViewResp extends BaseResp {
    result?: string;
    serializeTo(a5: object): void;
    deserializeFrom(z4: object): void;
    get type(): Command;
}
