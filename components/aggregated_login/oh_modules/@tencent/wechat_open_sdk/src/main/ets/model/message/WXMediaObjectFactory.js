import { MediaObjectType } from './SendMessageToWX';
import { WXFileObject } from './WXFileObject';
import { WXImageObject } from './WXImageObject';
import { WXMiniProgramObject } from './WXMiniProgramObject';
import { WXTextObject } from './WXTextObject';
import { WXWebpageObject } from './WXWebpageObject';
import { WXVideoFileObject } from './WXVideoFileObject';
import { WXVideoObject } from './WXVideoObject';
export class WXMediaObjectFactory {
    static createMediaObject(n3) {
        if (n3 === MediaObjectType.TYPE_TEXT) {
            return new WXTextObject;
        }
        else if (n3 === MediaObjectType.TYPE_IMAGE) {
            return new WXImageObject;
        }
        else if (n3 === MediaObjectType.TYPE_URL) {
            return new WXWebpageObject();
        }
        else if (n3 === MediaObjectType.TYPE_OPENSDK_APPBRAND) {
            return new WXMiniProgramObject();
        }
        else if (n3 === MediaObjectType.TYPE_FILE) {
            return new WXFileObject();
        }
        else if (n3 === MediaObjectType.TYPE_VIDEO_FILE) {
            return new WXVideoFileObject();
        }
        else if (n3 === MediaObjectType.TYPE_VIDEO) {
            return new WXVideoObject();
        }
        return undefined;
    }
}
