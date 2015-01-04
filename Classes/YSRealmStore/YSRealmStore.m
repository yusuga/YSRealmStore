//
//  YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSRealmStore.h"

@interface YSRealmStore ()

@property (nonatomic) NSMutableArray *operations;

@end

@implementation YSRealmStore

- (instancetype)init
{
    if (self = [super init]) {
        self.operations = [NSMutableArray array];
        DDLogDebug(@"%@; self.realm.path = %@", NSStringFromClass([self class]), self.realm.path);
    }
    return self;
}

#pragma mark - Realm

- (RLMRealm*)realm
{
    return [RLMRealm defaultRealm];
}

#pragma mark - Transaction

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
{
    [YSRealmWriteTransaction writeTransactionWithRealmPath:[[self realm] path]
                                                writeBlock:writeBlock];
}

- (YSRealmWriteTransaction *)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                                 completion:(YSRealmStoreWriteTransactionCompletion)completion
{
    __weak typeof(self) wself = self;
    YSRealmWriteTransaction *trans = [YSRealmWriteTransaction writeTransactionWithRealmPath:[[self realm] path] writeBlock:writeBlock completion:^(YSRealmWriteTransaction *transaction) {
        [wself.operations removeObject:transaction];
        if (completion) completion(wself, transaction);
    }];
    [self.operations addObject:trans];
    return trans;
}

#pragma mark - Operation
#pragma mark Write

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    [YSRealmOperation writeOperationWithRealmPath:[[self realm] path]
                                     objectsBlock:objectsBlock];
}

- (YSRealmOperation*)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    YSRealmOperation *ope = [YSRealmOperation writeOperationWithRealmPath:[[self realm] path] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation) {
        [wself.operations removeObject:operation];
        if (completion) completion(wself, operation);
    }];
    [self.operations addObject:ope];
    return ope;
}

#pragma mark Delete

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    [YSRealmOperation deleteOperationWithRealmPath:[[self realm] path]
                                      objectsBlock:objectsBlock];
}

- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmStoreOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    YSRealmOperation *ope = [YSRealmOperation deleteOperationWithRealmPath:[[self realm] path] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation) {
        [wself.operations removeObject:operation];
        if (completion) completion(wself, operation);
    }];
    [self.operations addObject:ope];
    return ope;
}

- (void)deleteAllObjects
{
    [YSRealmWriteTransaction writeTransactionWithRealmPath:[[self realm] path] writeBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        [realm deleteAllObjects];
    }];
}

- (void)deleteAllObjectsWithCompletion:(YSRealmStoreWriteTransactionCompletion)completion
{
    __weak typeof(self) wself = self;
    YSRealmWriteTransaction *trans = [YSRealmWriteTransaction writeTransactionWithRealmPath:[[self realm] path] writeBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        [realm deleteAllObjects];
    } completion:^(YSRealmWriteTransaction *transaction) {
        [wself.operations removeObject:transaction];
        if (completion) completion(wself, transaction);
    }];
    [self.operations addObject:trans];
}

#pragma mark Fetch

- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    YSRealmOperation *ope = [YSRealmOperation fetchOperationWithRealmPath:[[self realm] path] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation, RLMResults *results) {
        [wself.operations removeObject:operation];
        if (completion) completion(wself, operation, results);
    }];
    [self.operations addObject:ope];
    return ope;
}

@end
