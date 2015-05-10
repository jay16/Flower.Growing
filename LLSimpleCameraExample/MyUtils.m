//
//  MyUtils.m
//  LLSimpleCameraExample
//
//  Created by lijunjie on 15/5/10.
//  Copyright (c) 2015年 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyUtils.h"
#import "const.h"

@implementation MyUtils


+ (NSString *)getConfigFilePath {
    //获取应用程序沙盒的Documents目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    
    //得到完整的文件名
    NSString *filename = [NSString stringWithFormat:@"%@.plist", CONFIG_FILENAME];
    NSString *pathname = [path stringByAppendingPathComponent:filename];
    
    return pathname;
}

+ (BOOL) checkFileExist: (NSString*) pathname isDir: (BOOL) isDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:pathname isDirectory:&isDir];
    return isExist;
}

// 读取登陆信息配置档，有则读取，无则使用默认值
+ (NSMutableDictionary*) readConfigFile:(NSString*) pathname {
    NSMutableDictionary *dict = [NSMutableDictionary alloc];
    //NSLog(@"pathname: %@", pathname);
    if([self checkFileExist:pathname isDir:false]) {
        dict = [dict initWithContentsOfFile:pathname];
    } else {
        dict = [dict init];
        [dict setObject:[NSString stringWithFormat:@"%d",TIMER_INTERVAL] forKey:@"TimerInterval"];
        [dict setObject:[NSString stringWithFormat:@"%d", CAMERA_INTERVAL] forKey:@"CameraInterval"];
    }
    //NSLog(@"config: %@", dict);
    return dict;
}
@end
