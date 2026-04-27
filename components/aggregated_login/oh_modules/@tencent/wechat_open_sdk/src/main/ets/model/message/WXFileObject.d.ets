import { IMediaObject } from "./SendMessageToWX";
export declare class WXFileObject implements IMediaObject {
    /**
     * 文件路径uri
     */
    fileUri?: string;
    type: number;
    serializeTo(k3: object): void;
    deserializeFrom(j3: object): void;
    checkArgs(): boolean;
}
