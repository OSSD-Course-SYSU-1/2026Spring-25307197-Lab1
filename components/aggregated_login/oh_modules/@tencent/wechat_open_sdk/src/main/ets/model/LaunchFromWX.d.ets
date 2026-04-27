import { BaseReq } from "./Base";
import { Command } from "./Constants";
import { WXMediaMessage } from "./message/SendMessageToWX";
export declare class LaunchFromWXReq extends BaseReq {
    /** 发送消息的多媒体内容
     * @see WXMediaMessage
     */
    message?: WXMediaMessage;
    lang?: string;
    country?: string;
    serializeTo(l2: object): void;
    deserializeFrom(k2: object): void;
    checkArgs(): boolean;
    get type(): Command;
}
