//
//  RGLaunchManager.h
//  RGLaunch
//
//  Created by ranger on 2018/2/9.
//  Copyright © 2018年 ranger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGLaunchManager : NSObject

+ (instancetype)sharedManager;

- (void)launchWithConfig:(NSDictionary *)config options:(NSDictionary *)options;

#define RGLAUNCH(config,options) \
[[RGLaunchManager sharedManager] launchWithConfig:config options:options]
@end
