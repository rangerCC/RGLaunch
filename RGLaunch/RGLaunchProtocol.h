//
//  RGLaunchProtocol.h
//  RGLaunch
//
//  Created by ranger on 2018/2/9.
//  Copyright © 2018年 ranger. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RGLaunchProtocol <NSObject>

@optional
- (void)runWithOptions:(NSDictionary *)options;
- (void)runAfterPrepared;

@end
