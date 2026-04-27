import { IMediaObject } from './SendMessageToWX';
export declare class WXWebpageObject implements IMediaObject {
    type: number;
    /**
     * html 链接
     * @note 长度大于0且不超过10KB
     */
    webpageUrl?: string;
    /**
     * 拓展信息
     */
    extInfo?: string;
    /**
     * canvas链接
     */
    canvasPageXml?: string;
    /**
     * 是否是私密消息
     */
    isSecretMessage?: boolean;
    /**
     * 业务所需的额外信息
     */
    private extraInfoMap?;
    serializeTo(l4: object): void;
    deserializeFrom(j4: object): void;
    checkArgs(): boolean;
    putExtra(h4: string, i4: string): void;
    getExtra(f4: string, g4: string): string;
}
