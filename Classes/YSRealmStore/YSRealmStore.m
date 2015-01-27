//
//  YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSRealmStore.h"

@interface YSRealmStore ()

@property (nonatomic) NSString *realmPath;
@property (nonatomic) NSMutableArray *operations;

@end

@implementation YSRealmStore

#pragma mark - Life cycle

- (instancetype)init
{
    if (self = [super init]) {
        self.operations = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithRealmName:(NSString *)realmName
{
    if (self = [self init]) {
        if (realmName) {
            self.realmPath = [[self class] realmPathWithFileName:realmName];
        }
    }
    return self;
}

#pragma mark -

- (RLMRealm *)realm
{
    if (self.realmPath) {
        return [RLMRealm realmWithPath:self.realmPath];
    } else {
        return [RLMRealm defaultRealm];
    }
}

+ (dispatch_queue_t)queue
{
    static dispatch_queue_t __queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __queue = dispatch_queue_create("jp.YuSugawara.YSRealmStore..queue", NULL);
    });
    return __queue;
}

#pragma mark - Transaction

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
{
    [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realmPath
                                                writeBlock:writeBlock];
}

- (YSRealmWriteTransaction *)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                                 completion:(YSRealmStoreWriteTransactionCompletion)completion
{
    __weak typeof(self) wself = self;    
    YSRealmWriteTransaction *trans = [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realmPath queue:[YSRealmStore queue] writeBlock:writeBlock completion:^(YSRealmWriteTransaction *transaction) {
        [wself.operations removeObject:transaction];
        if (completion) completion(wself, transaction, wself.realm);
    }];
    [self.operations addObject:trans];
    return trans;
}

#pragma mark - Operation
#pragma mark Write

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    [YSRealmOperation writeOperationWithRealmPath:self.realmPath
                                     objectsBlock:objectsBlock];
}

- (YSRealmOperation*)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    YSRealmOperation *ope = [YSRealmOperation writeOperationWithRealmPath:self.realmPath queue:[YSRealmStore queue] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation) {
        [wself.operations removeObject:operation];
        if (completion) completion(wself, operation, wself.realm);
    }];
    [self.operations addObject:ope];
    return ope;
}

#pragma mark Delete

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    [YSRealmOperation deleteOperationWithRealmPath:self.realmPath
                                      objectsBlock:objectsBlock];
}

- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmStoreOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    YSRealmOperation *ope = [YSRealmOperation deleteOperationWithRealmPath:self.realmPath queue:[YSRealmStore queue] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation) {
        [wself.operations removeObject:operation];
        if (completion) completion(wself, operation, wself.realm);
    }];
    [self.operations addObject:ope];
    return ope;
}

- (void)deleteAllObjects
{
    [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realmPath writeBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
        [realm deleteAllObjects];
    }];
}

- (void)deleteAllObjectsWithCompletion:(YSRealmStoreWriteTransactionCompletion)completion
{
    __weak typeof(self) wself = self;
    YSRealmWriteTransaction *trans = [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realmPath queue:[YSRealmStore queue] writeBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
        [realm deleteAllObjects];
    } completion:^(YSRealmWriteTransaction *transaction) {
        [wself.operations removeObject:transaction];
        if (completion) completion(wself, transaction, wself.realm);
    }];
    [self.operations addObject:trans];
}

#pragma mark Fetch

- (RLMResults *)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    return [YSRealmOperation fetchOperationWithRealmPath:self.realmPath
                                            objectsBlock:objectsBlock];
}

- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    YSRealmOperation *ope = [YSRealmOperation fetchOperationWithRealmPath:self.realmPath  queue:[YSRealmStore queue] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation, RLMResults *results) {
        [wself.operations removeObject:operation];
        if (completion) completion(wself, operation, wself.realm, results);
    }];
    [self.operations addObject:ope];
    return ope;
}

#pragma mark - Utility

+ (NSString*)realmPathWithFileName:(NSString*)fileName
{
    NSParameterAssert(fileName);
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES)[0];
    path = [path stringByAppendingPathComponent:fileName];
    
    if ([path pathExtension].length == 0) {
        path = [path stringByAppendingPathExtension:@"realm"];
    }
    return path;
}

@end
