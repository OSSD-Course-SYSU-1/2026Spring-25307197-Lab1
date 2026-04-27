export declare enum LogLevel {
    verbose = 0,
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
    fatal = 5
}
export interface LogInterface {
    print(level: LogLevel, tag: string, message: string): void;
}
export declare class Log {
    private static log;
    static setLogImpl(x1: LogInterface): void;
    static d(u1: string, v1: string, ...w1: Object[]): void;
    static i(r1: string, s1: string, ...t1: Object[]): void;
    static w(o1: string, p1: string, ...q1: Object[]): void;
    static e(l1: string, m1: string, ...n1: Object[]): void;
    private static printf;
}
