import { BaseReq, BaseResp } from './Base';
export declare class OpenCustomerServiceChatReq extends BaseReq {
    /**
     * 企业ID
     */
    corpId?: string;
    /**
     * 客服url
     */
    url?: string;
    checkArgs(): boolean;
    get type(): number;
    serializeTo(y4: object): void;
    deserializeFrom(x4: object): void;
}
export declare class OpenCustomerServiceChatResp extends BaseResp {
    get type(): number;
}
