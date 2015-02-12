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

@end

@implementation YSRealmStore

#pragma mark - Life cycle

- (instancetype)initWithRealmName:(NSString *)realmName
{
    if (self = [super init]) {
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
    return [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realmPath queue:[YSRealmStore queue] writeBlock:writeBlock completion:^(YSRealmWriteTransaction *transaction) {
        if (completion) completion(self, transaction, self.realm);
    }];
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
    return [YSRealmOperation writeOperationWithRealmPath:self.realmPath queue:[YSRealmStore queue] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation) {
        if (completion) completion(self, operation, self.realm);
    }];
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
    return [YSRealmOperation deleteOperationWithRealmPath:self.realmPath queue:[YSRealmStore queue] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation) {
        if (completion) completion(self, operation, self.realm);
    }];
}

- (void)deleteAllObjects
{
    [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realmPath writeBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
        [realm deleteAllObjects];
    }];
}

- (void)deleteAllObjectsWithCompletion:(YSRealmStoreWriteTransactionCompletion)completion
{
    [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realmPath queue:[YSRealmStore queue] writeBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
        [realm deleteAllObjects];
    } completion:^(YSRealmWriteTransaction *transaction) {
        if (completion) completion(self, transaction, self.realm);
    }];
}

#pragma mark Fetch

- (id)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    return [YSRealmOperation fetchOperationWithRealmPath:self.realmPath
                                            objectsBlock:objectsBlock];
}

- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion
{
    return [YSRealmOperation fetchOperationWithRealmPath:self.realmPath  queue:[YSRealmStore queue] objectsBlock:objectsBlock completion:^(YSRealmOperation *operation, RLMResults *results) {
        if (completion) completion(self, operation, self.realm, results);
    }];
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
