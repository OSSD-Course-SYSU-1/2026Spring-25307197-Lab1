import { BaseResp } from '../../../../../Index';
import { BaseReq } from '../../../../../Index';
import { Command } from '../Constants';
export declare class SendMessageToWXReq extends BaseReq {
    /**
     * 表示发送到会话
     */
    static readonly WXSceneSession: number;
    /**
     * 表示发送到朋友圈
     */
    static readonly WXSceneTimeline: number;
    /** 发送消息的多媒体内容
     * @see WXMediaMessage
     */
    message?: WXMediaMessage;
    /** 发送的目标场景。 默认发送到会话。
     * @see WXScene
     */
    scene: number;
    serializeTo(h3: object): void;
    deserializeFrom(g3: object): void;
    checkArgs(): boolean;
    get type(): Command;
}
export declare class SendMessageToWXResp extends BaseResp {
    serializeTo(f3: object): void;
    deserializeFrom(e3: object): void;
    get type(): Command;
}
export declare enum MediaObjectType {
    TYPE_TEXT = 1,
    TYPE_IMAGE = 2,
    TYPE_VIDEO = 4,
    TYPE_URL = 5,
    TYPE_FILE = 6,
    TYPE_OPENSDK_APPBRAND = 36,
    TYPE_VIDEO_FILE = 38
}
export interface IMediaObject {
    serializeTo: (to: object) => void;
    deserializeFrom: (from: object) => void;
    type: number;
    checkArgs: () => boolean;
}
export declare class WXMediaMessage {
    /** 标题
     * @note 长度不能超过512字节
     */
    title?: string;
    /**
     * 描述
     * @note 限制长度不超过1KB
     */
    description?: string;
    mediaObject?: IMediaObject;
    /** 缩略图数据
     * @note 大小不能超过64K
     */
    thumbData?: Uint8Array;
    mediaTagName?: string;
    messageAction?: string;
    messageExt?: string;
    serializeTo(z2: object): void;
    deserializeFrom(v2: object): void;
    checkArgs(): boolean;
}
