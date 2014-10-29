//
//  YSRealm.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSRealm.h"

@interface YSRealm ()

@property (nonatomic) NSMutableArray *operations;

@end

@implementation YSRealm

+ (instancetype)sharedInstance
{
    static id __sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance =  [[self alloc] init];
    });
    return __sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.operations = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Realm

- (RLMRealm*)realm
{
    return [RLMRealm defaultRealm];
}

#pragma mark - Operation
#pragma mark Add

- (void)addObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    NSParameterAssert(objectsBlock != NULL);
    
    [YSRealmOperation addOperationWithRealmPath:[[self realm] path] objectsBlock:objectsBlock];
}

- (YSRealmOperation*)addObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                     completion:(YSRealmCompletion)completion
{
    NSParameterAssert(objectsBlock != NULL);
    NSParameterAssert(completion != NULL);
    
    __weak typeof(self) wself = self;
    YSRealmOperation *ope = [YSRealmOperation addOperationWithRealmPath:[[self realm] path] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation) {
        [wself.operations removeObject:operation];
        completion(operation);
    }];
    [self.operations addObject:ope];
    return ope;
}

#pragma mark Update

- (void)updateObjectsWithUpdateBlock:(YSRealmOperationUpdateBlock)updateBlock
{
    NSParameterAssert(updateBlock != NULL);
    
    [YSRealmOperation updateOperationWithRealmPath:[[self realm] path] updateBlock:updateBlock];
}

- (YSRealmOperation*)updateObjectsWithUpdateBlock:(YSRealmOperationUpdateBlock)updateBlock
                                       completion:(YSRealmCompletion)completion
{
    NSParameterAssert(updateBlock != NULL);
    NSParameterAssert(completion != NULL);
    
    __weak typeof(self) wself = self;
    YSRealmOperation *ope = [YSRealmOperation updateOperationWithRealmPath:[[self realm] path] updateBlock:updateBlock completion:^(YSRealmOperation *operation) {
        [wself.operations removeObject:operation];
        completion(operation);
    }];
    [self.operations addObject:ope];
    return ope;
}

#pragma mark Delete

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    NSParameterAssert(objectsBlock != NULL);
    
    [YSRealmOperation deleteOperationWithRealmPath:[[self realm] path] objectsBlock:objectsBlock];
}

- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmCompletion)completion
{
    NSParameterAssert(objectsBlock != NULL);
    NSParameterAssert(completion != NULL);
    
    __weak typeof(self) wself = self;
    YSRealmOperation *ope = [YSRealmOperation deleteOperationWithRealmPath:[[self realm] path] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation) {
        [wself.operations removeObject:operation];
        completion(operation);
    }];
    [self.operations addObject:ope];
    return ope;
}

@end
