import util from '@ohos.util';
export var LogLevel;
(function (c2) {
    c2[c2["verbose"] = 0] = "verbose";
    c2[c2["debug"] = 1] = "debug";
    c2[c2["info"] = 2] = "info";
    c2[c2["warn"] = 3] = "warn";
    c2[c2["error"] = 4] = "error";
    c2[c2["fatal"] = 5] = "fatal";
})(LogLevel || (LogLevel = {}));
class LogDefaultImpl {
    print(y1, z1, a2) {
        let b2 = (() => {
            switch (y1) {
                case LogLevel.verbose: return console.log;
                case LogLevel.debug: return console.debug;
                case LogLevel.info: return console.info;
                case LogLevel.warn: return console.warn;
                case LogLevel.error: return console.error;
                case LogLevel.fatal: return console.assert;
            }
        })();
        b2('[' + z1 + '] ' + a2);
    }
}
export class Log {
    static setLogImpl(x1) {
        Log.log = x1;
    }
    static d(u1, v1, ...w1) { Log.printf(LogLevel.debug, u1, v1, ...w1); }
    static i(r1, s1, ...t1) { Log.printf(LogLevel.info, r1, s1, ...t1); }
    static w(o1, p1, ...q1) { Log.printf(LogLevel.warn, o1, p1, ...q1); }
    static e(l1, m1, ...n1) { Log.printf(LogLevel.error, l1, m1, ...n1); }
    static printf(h1, i1, j1, ...k1) {
        Log.log.print(h1, i1, util.format(j1, ...k1));
    }
}
Log.log = new LogDefaultImpl;
