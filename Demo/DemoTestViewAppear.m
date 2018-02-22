//
//  DemoTestViewAppear.m
//  Demo
//
//  Created by TingtingYan on 2018/2/20.
//  Copyright © 2018年 ranger. All rights reserved.
//

#import "DemoTestViewAppear.h"
#import <RGLaunch/RGLaunch.h>

@interface DemoTestViewAppear ()<RGLaunchProtocol>
@end

@implementation DemoTestViewAppear

- (void)runWithOptions:(NSDictionary *)options;
{
    for (int i=0; i<1000000; i++) {
        @autoreleasepool {
            [NSObject new];
        }
    }
    
    NSLog(@"DemoTestViewAppear finished!");
}

@end
