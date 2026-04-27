import { IMediaObject, MediaObjectType } from './SendMessageToWX';
export declare class WXTextObject implements IMediaObject {
    type: MediaObjectType;
    text?: string;
    serializeTo(a4: object): void;
    deserializeFrom(z3: object): void;
    checkArgs(): boolean;
}
