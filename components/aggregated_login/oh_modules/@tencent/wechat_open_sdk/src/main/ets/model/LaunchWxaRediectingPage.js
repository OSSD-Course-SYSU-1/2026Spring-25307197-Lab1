import { Command } from "./Constants";
import { BaseReq, BaseResp } from "./Base";
export class LaunchWxaRedirectingPageReq extends BaseReq {
    checkArgs() {
        if (!this.invokeTicket || this.invokeTicket.length === 0) {
            return false;
        }
        return true;
    }
    serializeTo(u2) {
        super.serializeTo(u2);
        u2['invokeTicket'] = this.invokeTicket;
        u2['mediaUri'] = this.mediaUri;
    }
    deserializeFrom(t2) {
        super.deserializeFrom(t2);
        this.invokeTicket = t2['invokeTicket'];
        this.mediaUri = t2['mediaUri'];
    }
    get type() {
        return Command.kCommandWxaRedirectingPage;
    }
}
export class LaunchWxaRedirectingPageResp extends BaseResp {
    serializeTo(s2) {
        super.serializeTo(s2);
    }
    deserializeFrom(r2) {
        super.deserializeFrom(r2);
    }
    get type() {
        return Command.kCommandWxaRedirectingPage;
    }
}
