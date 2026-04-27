import common from '@ohos.app.ability.common';
import Want from "@ohos.app.ability.Want";
import { BaseReq, BaseResp, SendReqResultWrap } from '../model/Base';
export interface WXApi {
    sendReq(context: common.UIAbilityContext, req: BaseReq): SendReqResultWrap;
    openWechat(context: common.UIAbilityContext): SendReqResultWrap;
    handleWant(want: Want, eventHandler: WXApiEventHandler): boolean;
    isWXAppInstalled(): boolean;
}
export interface WXApiEventHandler {
    onReq(req: BaseReq): void;
    onResp(req: BaseResp): void;
}
export declare class WXAPIFactory {
    static createWXAPI(s7: string): WXApi;
    static createReq(p7: object): BaseReq | undefined;
    static createResp(m7: object): BaseResp | undefined;
}
