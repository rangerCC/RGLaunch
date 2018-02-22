//
//  RGLaunchService.m
//  RGLaunch
//
//  Created by ranger on 2018/2/9.
//  Copyright © 2018年 ranger. All rights reserved.
//

#import "RGLaunchService.h"
#import "RGLaunchProtocol.h"

NSString * const kRGLaunchAppDidLaunch = @"kRGLaunchAppDidLaunch";
NSString * const kRGLaunchAppOnLoad = @"kRGLaunchAppOnLoad";
NSString * const kRGLaunchAppRunloopChanged = @"kRGLaunchAppRunloopChanged";
NSString * const kRGLaunchAppOtherFreeTime = @"kRGLaunchAppOtherFreeTime";

@interface RGLaunchService ()

// 启动任务配置列表
@property (nonatomic, copy) NSDictionary *tasks;

// 全局配置
@property (nonatomic, copy) NSDictionary *config;

// 运行参数
@property (nonatomic, copy) NSDictionary *options;

// 启动任务列表(tasks)
@property (nonatomic, strong) NSMutableDictionary *launchTasks;

// 启动任务集合(tasks block化)
@property (nonatomic, strong) NSMutableDictionary *launchBlocks;

@end

@implementation RGLaunchService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _launchTasks = [[NSMutableDictionary alloc] initWithCapacity:10];
        _launchBlocks = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    return self;
}

- (void)startTasks:(NSDictionary *)tasks config:(NSDictionary *)config options:(NSDictionary *)options
{
    self.tasks = tasks;
    self.config = config;
    self.options = options;
    
    // 将 view_appear 和 free_time 任务扔到下个 runloop 执行
    [self addRunloopObserver];
    
    // 解析任务配置表
    [self parseTasks];
    
    // 执行启动任务，先执行 did_launch 和 roo_onload
    [self launch];
}

#pragma mark -
- (void)addRunloopObserver
{
    if ([[NSRunLoop currentRunLoop].currentMode isEqualToString:@"UIInitializationRunLoopMode"]) {
        // 创建观察者
        CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, NO, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            [self launchInitTaskOnStage3:YES];
            CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopDefaultMode);
        });
        
        // 添加观察者到主 runloop
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopDefaultMode);
    
    } else {
        
        [self launchInitTaskOnStage3:NO];
        
    }
    
}

- (void)parseTasks
{
    __weak typeof(self) weakSelf = self;
    
    [self.tasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        dispatch_block_t launchBlock = [^(){
            [weakSelf executeInitTasks:obj forKey:key];
        } copy];
        
        weakSelf.launchBlocks[key] = launchBlock;
    }];
}

- (void)launch
{
    // did launch
    [self launchInitTaskOnStage1];
    
    // view appear
    [self launchInitTaskOnStage2];
}

#pragma mark - Launch Stages
- (void)launchInitTaskOnStage1
{
    [self executeLaunchBlock:kRGLaunchAppDidLaunch];
}

- (void)launchInitTaskOnStage2
{
    [self executeLaunchBlock:kRGLaunchAppOnLoad];
}

- (void)launchInitTaskOnStage3:(BOOL)runloopModeChanged
{
    if (runloopModeChanged) {
        
        [self executeLaunchBlock:kRGLaunchAppRunloopChanged];
        
        [self launchInitTaskOnStage4];
        
        return;
    }
    
    // 扔到下个 runloop 去执行
    __weak typeof(self) weakSelf = self;
    [self excuteOnNextRunloop:^{
        
        [weakSelf executeLaunchBlock:kRGLaunchAppRunloopChanged];
        
        [weakSelf launchInitTaskOnStage4];
        
    }];
}

- (void)launchInitTaskOnStage4
{
    // 扔到下个 runloop 去执行
    __weak typeof(self) weakSelf = self;
    
    [self excuteOnNextRunloop:^{
        
        [weakSelf executeLaunchBlock:kRGLaunchAppOtherFreeTime];
        
        for (NSString *key in [weakSelf launchTasks].allKeys) {
            
            id task = weakSelf.launchTasks[key];
            
            if (task &&
                [task conformsToProtocol:@protocol(RGLaunchProtocol)] &&
                [task respondsToSelector:@selector(runAfterPrepared)]) {
                
                [task runAfterPrepared];
                
            }
        }
        
    }];
}

#pragma mark -

- (void)excuteOnNextRunloop:(dispatch_block_t)block
{
    if (!block) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

- (void)executeLaunchBlock:(NSString *)key
{
    if (!key) return;
    
    dispatch_block_t launchBlock = self.launchBlocks[key];
    
    if (launchBlock) launchBlock();
}

- (void)executeInitTasks:(NSArray *)tasks forKey:(NSString *)key
{
    if (!tasks) return;
    
    __weak typeof(self) weakSelf = self;
    [tasks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf startLaunchTask:obj];
    }];
}

- (void)startLaunchTask:(NSDictionary *)task
{
    if (!task || ![task isKindOfClass:[NSDictionary class]]) return;
    
    NSString *clazz = task[@"class"];
    if (!clazz) {
        NSAssert(NO, @"Launch Class Can't Be NULL!");
        return;
    }
    
    Class cls = NSClassFromString(clazz);
    if (!cls) {
        NSAssert(NO, @"Launch Class Does Not Exsit!");
        return;
    }
    
    id <RGLaunchProtocol> taskInstance = nil;
    @synchronized (self) {
        taskInstance = self.launchTasks[clazz];
        if (!taskInstance) {
            taskInstance = [[cls alloc] init];
            self.launchTasks[clazz] = taskInstance;
        } else {
            NSAssert(NO, @"Duplicated Launch Class [%@]!", clazz);
        }
    }
    
    if (taskInstance &&
        [taskInstance respondsToSelector:@selector(runWithOptions:)]) {
        [taskInstance runWithOptions:self.options];
    }
}
@end
