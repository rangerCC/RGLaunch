//
//  RGLaunchManager.m
//  RGLaunch
//
//  Created by ranger on 2018/2/9.
//  Copyright © 2018年 ranger. All rights reserved.
//

#import "RGLaunchManager.h"
#import "RGLaunchService.h"

@interface RGLaunchManager ()

@property (nonatomic, strong) RGLaunchService *service;

@end

@implementation RGLaunchManager

static RGLaunchManager *__instance;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^{
        if (__instance == nil) {
            __instance = [[self class] new];
        }
    });
    return __instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        if (__instance == nil) {
            __instance = [super allocWithZone:zone];
        }
    });
    return __instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Public API
- (void)launchWithConfig:(NSDictionary *)config options:(NSDictionary *)options
{
    NSAssert([NSThread currentThread]==[NSThread mainThread], @"you must start launch at main thread!");
    
    if (!config || ![config isKindOfClass:[NSDictionary class]] || config.count<=0) {
        return;
    }
    
    // global param
    NSDictionary *global = config[@"global"];
    NSLog(@"\n global=%@", global);
    
    // tasks
    NSDictionary *tasks = config[@"tasks"];
    [self.service startTasks:tasks config:config options:options];
}

#pragma mark - Getter
- (RGLaunchService *)service
{
    if (!_service) {
        _service = [[RGLaunchService alloc] init];
    }
    return _service;
}

@end
