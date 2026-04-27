import { Log } from '../log/Log';
import { BaseReq, BaseResp } from './Base';
import { Command } from './Constants';
export class LaunchMiniProgramReq extends BaseReq {
    constructor() {
        super(...arguments);
        this.kTag = 'wxopensdk::LaunchMiniProgramReq';
    }
    checkArgs() {
        if (!this.userName || this.userName.length === 0) {
            Log.e(this.kTag, "userName is invalid");
            return false;
        }
        return true;
    }
    serializeTo(q2) {
        super.serializeTo(q2);
        q2['userName'] = this.userName;
        q2['path'] = this.path;
        q2['miniprogramType'] = this.miniprogramType;
        q2['extraData'] = this.extraData;
    }
    deserializeFrom(p2) {
        super.deserializeFrom(p2);
        this.userName = p2['userName'];
        this.path = p2['path'];
        this.miniprogramType = p2['miniprogramType'];
        this.extraData = p2['extraData'];
    }
    get type() {
        return Command.kCommandLaunchMiniProgram;
    }
}
export class LaunchMiniProgramResp extends BaseResp {
    serializeTo(o2) {
        super.serializeTo(o2);
        o2['extMsg'] = this.extMsg;
    }
    deserializeFrom(n2) {
        super.deserializeFrom(n2);
        this.extMsg = n2['extMsg'];
    }
    get type() {
        return Command.kCommandLaunchMiniProgram;
    }
}
