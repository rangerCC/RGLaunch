//
//  RGLaunchService.h
//  RGLaunch
//
//  Created by ranger on 2018/2/9.
//  Copyright © 2018年 ranger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGLaunchService : NSObject

- (void)startTasks:(NSDictionary *)tasks config:(NSDictionary *)config options:(NSDictionary *)options;

@end

FOUNDATION_EXPORT NSString * const kRGLaunchAppDidLaunch;        //1
FOUNDATION_EXPORT NSString * const kRGLaunchAppOnLoad;           //2
FOUNDATION_EXPORT NSString * const kRGLaunchAppRunloopChanged;   //3
FOUNDATION_EXPORT NSString * const kRGLaunchAppOtherFreeTime;    //4
