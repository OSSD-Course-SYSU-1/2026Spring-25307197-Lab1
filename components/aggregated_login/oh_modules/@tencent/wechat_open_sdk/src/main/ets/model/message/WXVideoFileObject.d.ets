import { IMediaObject } from "./SendMessageToWX";
/**
 * 目前只支持分享到朋友圈
 */
export declare class WXVideoFileObject implements IMediaObject {
    /**
     * 文件路径uri
     */
    fileUri?: string;
    type: number;
    serializeTo(c4: object): void;
    deserializeFrom(b4: object): void;
    checkArgs(): boolean;
}
