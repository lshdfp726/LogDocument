//
//  SaveLogTools.m
//  SaveLog
//
//  Created by fns on 2017/8/24.
//  Copyright © 2017年 lsh726. All rights reserved.
//

#import "SaveLogTools.h"

#define CREASHPATH [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Log"] stringByAppendingPathComponent:@"Exception.log"]

@implementation SaveLogTools
+ (void)LogToPath:(NSString *)path {
    NSError *error = nil;
    NSFileManager *defaluManager = [NSFileManager defaultManager];
    [defaluManager removeItemAtPath:path error:&error];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    NSSetUncaughtExceptionHandler(&LSH_NSUncaughtExceptionHandler);
}

void LSH_NSUncaughtExceptionHandler(NSException *exception) {
    NSString *name   = [exception name];
    NSString *reason = [exception reason];
    NSArray *symbols = [exception callStackSymbols]; //异常发生时的调用栈
    NSMutableString *symbolStr = [[NSMutableString alloc] init];
    for (NSString *item in symbols) {
        [symbolStr appendString:item];
        [symbolStr appendString:@"\r\n"];
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logStr = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logStr]) {
        [fileManager createDirectoryAtPath:logStr withIntermediateDirectories:YES attributes:nil error:nil];//withIntermediateDirectories YES 以父母路为路径创建一个文件
    }
    NSString *logFilePath = CREASHPATH;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@"crash时间:%@ \r\ncreash名字:%@\r\ncreash原因:%@\r\n堆栈:%@ \r\n\r\n",dateStr,name,reason,symbols];
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}
@end
