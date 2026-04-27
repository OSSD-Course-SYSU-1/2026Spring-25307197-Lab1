import { Command, kWechatBundleName, kWechatEntryAbility } from '../model/Constants';
import bundleManager from "@ohos.bundle.bundleManager";
import wantConstant from "@ohos.app.ability.wantConstant";
import { SendAuthReq, SendAuthResp } from '../model/SendAuth';
import { JointPayReq, JointPayResp, PayReq, PayResp } from '../model/Pay';
import { Log } from '../log/Log';
import { SendTdiAuthReq, SendTdiAuthResp } from '../model/SendTdiAuth';
import { MediaObjectType, SendMessageToWXReq, SendMessageToWXResp } from '../model/message/SendMessageToWX';
import { LaunchMiniProgramReq, LaunchMiniProgramResp } from '../model/LaunchMiniProgram';
import { OpenBusinessViewReq, OpenBusinessViewResp } from '../model/OpenBusinessView';
import { LaunchFromWXReq } from '../model/LaunchFromWX';
import { LaunchWxaRedirectingPageReq, LaunchWxaRedirectingPageResp } from '../model/LaunchWxaRediectingPage';
import { OpenCustomerServiceChatReq, OpenCustomerServiceChatResp } from '../model/OpenCustomerServiceChat';
import { OpenBusinessWebViewReq, OpenBusinessWebViewResp } from '../model/OpenBusinessWebView';
import { OpenWebViewReq, OpenWebViewResp } from '../model/OpenWebView';
const kTag = 'wxopensdk::WXApi';
const kWantCallerBundleNameKey = "ohos.aafwk.param.callerBundleName";
const kWantRequestKey = "wxopensdk_request";
const kWantResponseKey = "wxopensdk_response";
const kWantAppidKey = "wxopensdk_appid";
const kWechatBundleNameCandidates = [
    "com.tencent.wechat.debug",
    "com.tencent.wechat.red",
    "com.tencent.wechat.purple",
    "com.tencent.wechat.blue",
    "com.tencent.wechat.yellow"
];
const kWechatLink = "wxopensdk://open_sdk_request_link";
export class WXAPIFactory {
    static createWXAPI(s7) {
        return new WXApiImpl(s7);
    }
    static createReq(p7) {
        let q7 = p7['__type__'] ?? -1;
        let r7 = (() => {
            switch (q7) {
                case Command.kCommandSendAuth: return new SendAuthReq;
                case Command.kCommandSendTdiAuth: return new SendTdiAuthReq;
                case Command.kCommandSendMessageToWX: return new SendMessageToWXReq;
                case Command.kCommandPay: return new PayReq();
                case Command.kCommandJointPay: return new JointPayReq();
                case Command.kCommandLaunchFromWX: return new LaunchFromWXReq;
                case Command.kCommandLaunchMiniProgram: return new LaunchMiniProgramReq;
                case Command.kCommandOpenWebView: return new OpenWebViewReq;
                case Command.kCommandOpenBusinessWebView: return new OpenBusinessWebViewReq;
                case Command.kCommandOpenBusinessView: return new OpenBusinessViewReq;
                case Command.kCommandWxaRedirectingPage: return new LaunchWxaRedirectingPageReq;
                case Command.kCommandOpenCustomerServiceChat: return new OpenCustomerServiceChatReq;
                default: return;
            }
        })();
        r7?.deserializeFrom(p7);
        return r7;
    }
    static createResp(m7) {
        let n7 = m7['__type__'] ?? -1;
        let o7 = (() => {
            switch (n7) {
                case Command.kCommandSendAuth: return new SendAuthResp;
                case Command.kCommandSendTdiAuth: return new SendTdiAuthResp;
                case Command.kCommandSendMessageToWX: return new SendMessageToWXResp;
                case Command.kCommandPay: return new PayResp;
                case Command.kCommandJointPay: return new JointPayResp;
                case Command.kCommandLaunchMiniProgram: return new LaunchMiniProgramResp;
                case Command.kCommandOpenWebView: return new OpenWebViewResp;
                case Command.kCommandOpenBusinessWebView: return new OpenBusinessWebViewResp;
                case Command.kCommandOpenBusinessView: return new OpenBusinessViewResp;
                case Command.kCommandWxaRedirectingPage: return new LaunchWxaRedirectingPageResp;
                case Command.kCommandOpenCustomerServiceChat: return new OpenCustomerServiceChatResp;
                default: return;
            }
        })();
        o7?.deserializeFrom(m7);
        return o7;
    }
}
class WXApiImpl {
    constructor(l7) {
        this.resolves = new Map();
        this.appId = l7;
    }
    static reqToWantObject(j7) {
        if (j7) {
            let k7 = {};
            j7.serializeTo(k7);
            if (k7['__type__'] !== j7.type) {
                Log.e(kTag, 'super.serializedTo must be called');
            }
            return k7;
        }
        else {
            return undefined;
        }
    }
    makeParameters(h7) {
        let i7 = {};
        i7[kWantRequestKey] = WXApiImpl.reqToWantObject(h7) ?? "";
        i7[kWantAppidKey] = this.appId;
        i7["from"] = "_wechat_open_sdk";
        i7["linkFeature"] = "Pay";
        return i7;
    }
    makeWant(y6, z6) {
        let a7 = undefined;
        let b7 = undefined;
        let c7 = undefined;
        if (y6 && y6.type === Command.kCommandSendMessageToWX) {
            let d7 = y6;
            if (d7.checkArgs()) {
                if (d7.message?.mediaObject?.type === MediaObjectType.TYPE_IMAGE) {
                    let g7 = d7.message?.mediaObject;
                    a7 = g7.uri;
                }
                else if (d7.message?.mediaObject?.type === MediaObjectType.TYPE_FILE) {
                    let f7 = d7.message?.mediaObject;
                    a7 = f7.fileUri;
                }
                else if (d7.message?.mediaObject?.type === MediaObjectType.TYPE_VIDEO_FILE) {
                    let e7 = d7.message?.mediaObject;
                    a7 = e7.fileUri;
                }
            }
        }
        else if (y6 && y6.type === Command.kCommandWxaRedirectingPage) {
            a7 = y6.mediaUri?.trim();
        }
        if (a7 != undefined && a7.length > 0) {
            b7 = 'ohos.want.action.sendData';
            c7 = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION;
        }
        return {
            bundleName: z6 ?? kWechatBundleName,
            abilityName: kWechatEntryAbility,
            parameters: this.makeParameters(y6),
            action: b7,
            uri: a7,
            flags: c7
        };
    }
    openWeChatWithLink(r6, s6) {
        return new Promise(async (t6) => {
            const u6 = {
                appLinkingOnly: false,
                parameters: this.makeParameters(s6)
            };
            try {
                await r6.openLink(kWechatLink, u6, (w6, x6) => {
                    if (w6 && w6.code != 0) {
                        Log.e(kTag, `openWeChatWithLink result err: ${w6.message}`);
                        return;
                    }
                    this.handleResult(x6);
                });
                t6(true);
            }
            catch (v6) {
                Log.e(kTag, `openWeChatWithLink fail by err: ${v6.message}`);
                t6(false);
            }
        });
    }
    openWechatWithWant(j6, k6) {
        return new Promise((l6) => {
            let m6 = [];
            m6.push(kWechatBundleName);
            m6.push(...kWechatBundleNameCandidates);
            (async () => {
                let n6 = false;
                for (let o6 of m6) {
                    let p6 = this.makeWant(k6, o6);
                    try {
                        await j6.startAbility(p6);
                        n6 = true;
                        l6(true);
                        return;
                    }
                    catch (q6) {
                        Log.e(kTag, `openWechatWithWant fail by err: ${q6.message}`);
                    }
                }
                l6(n6);
            })();
        });
    }
    handleResult(i6) {
        Log.i(kTag, `handleResult, result = ${JSON.stringify(i6)}`);
        if (i6.resultCode != 0) {
            return;
        }
        this.handleWantInternal(i6.want);
    }
    handleWantInternal(d6) {
        if (d6?.parameters === undefined) {
            return;
        }
        let e6 = d6.parameters[kWantRequestKey];
        if (e6) {
            let h6 = WXAPIFactory.createReq(e6);
            if (h6) {
                this.eventHandler?.onReq(h6);
            }
        }
        let f6 = d6.parameters[kWantResponseKey];
        if (f6) {
            let g6 = WXAPIFactory.createResp(f6);
            if (g6) {
                this.eventHandler?.onResp(g6);
            }
        }
    }
    canOpenWithLink(w5) {
        try {
            if (!bundleManager.canOpenLink(kWechatLink)) {
                return false;
            }
        }
        catch (c6) {
            Log.e(kTag, `canOpenLink fail by err: ${c6.message}`);
            return false;
        }
        if (w5.type === Command.kCommandSendMessageToWX) {
            const y5 = w5;
            if (y5.message?.mediaObject?.type === MediaObjectType.TYPE_IMAGE) {
                const b6 = y5.message.mediaObject;
                return b6.uri === undefined || b6.uri.trim().length === 0;
            }
            else if (y5.message?.mediaObject?.type === MediaObjectType.TYPE_FILE) {
                const a6 = y5.message.mediaObject;
                return a6.fileUri === undefined || a6.fileUri.trim().length === 0;
            }
            else if (y5.message?.mediaObject?.type === MediaObjectType.TYPE_VIDEO_FILE) {
                const z5 = y5.message.mediaObject;
                return z5.fileUri === undefined || z5.fileUri.trim().length === 0;
            }
        }
        else if (w5.type === Command.kCommandWxaRedirectingPage) {
            const x5 = w5;
            return x5.mediaUri === undefined || x5.mediaUri.trim().length === 0;
        }
        return true;
    }
    sendReq(u5, v5) {
        if (this.canOpenWithLink(v5)) {
            Log.i(kTag, 'sendReq, use link');
            return this.openWeChatWithLink(u5, v5);
        }
        Log.i(kTag, 'sendReq, use want');
        return this.openWechatWithWant(u5, v5);
    }
    openWechat(t5) {
        return this.openWechatWithWant(t5, undefined);
    }
    handleWant(q5, r5) {
        this.eventHandler = r5;
        if (q5.parameters && typeof q5.parameters[kWantCallerBundleNameKey] === 'string') {
            let s5 = q5.parameters[kWantCallerBundleNameKey];
            if (s5 !== kWechatBundleName && !kWechatBundleNameCandidates.includes(s5)) {
                return false;
            }
            this.handleWantInternal(q5);
            return true;
        }
        else {
            return false;
        }
    }
    isWXAppInstalled() {
        try {
            return bundleManager.canOpenLink("weixin://");
        }
        catch (n5) {
            let o5 = n5?.code;
            let p5 = n5?.message ?? '';
            if (o5 !== undefined) {
                if (o5 === 17700056) {
                    p5 += ` Please include "weixin" inside the "querySchemes" element of module.json5 in your app module.`;
                }
                Log.e(kTag, `isWXAppInstalled get error ${p5}`);
            }
            else {
                Log.e(kTag, `isWXAppInstalled get error ${n5}`);
            }
            return false;
        }
    }
}
WXApiImpl.NextId = 0;
