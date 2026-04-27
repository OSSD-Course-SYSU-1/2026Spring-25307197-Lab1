import { Command } from "./Constants";
import { BaseReq, BaseResp } from "./Base";
export declare class LaunchWxaRedirectingPageReq extends BaseReq {
    invokeTicket?: string;
    mediaUri?: string;
    checkArgs(): boolean;
    serializeTo(u2: object): void;
    deserializeFrom(t2: object): void;
    get type(): Command;
}
export declare class LaunchWxaRedirectingPageResp extends BaseResp {
    serializeTo(s2: object): void;
    deserializeFrom(r2: object): void;
    get type(): Command;
}
