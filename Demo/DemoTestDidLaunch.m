//
//  DemoTestDidLaunch.m
//  Demo
//
//  Created by TingtingYan on 2018/2/20.
//  Copyright © 2018年 ranger. All rights reserved.
//

#import "DemoTestDidLaunch.h"
#import <RGLaunch/RGLaunch.h>

@interface DemoTestDidLaunch ()<RGLaunchProtocol>
@end

@implementation DemoTestDidLaunch

- (void)runWithOptions:(NSDictionary *)options;
{
    for (int i=0; i<1000000; i++) {
        @autoreleasepool {
            [NSObject new];
        }
    }
    
    NSLog(@"DemoTestDidLaunch finished!");
}

@end
