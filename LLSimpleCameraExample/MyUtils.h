//
//  MyUtils.h
//  LLSimpleCameraExample
//
//  Created by lijunjie on 15/5/10.
//  Copyright (c) 2015年 Ömer Faruk Gül. All rights reserved.
//

#ifndef LLSimpleCameraExample_MyUtils_h
#define LLSimpleCameraExample_MyUtils_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MyUtils : NSObject

+ (NSString *)getConfigFilePath;
+ (BOOL) checkFileExist: (NSString*) pathname isDir: (BOOL) isDir;
+ (NSMutableDictionary*) readConfigFile:(NSString*) pathname;

@end

#endif
