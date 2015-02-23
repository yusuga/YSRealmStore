//
//  YSRealmWriteTransaction.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/12/08.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSRealmWriteTransaction.h"

@interface YSRealmWriteTransaction ()

@property (copy, nonatomic) NSString *realmPath;
@property (nonatomic) BOOL inMemory;

@property (readwrite, getter=isInterrupted) BOOL interrupted;

@end

@implementation YSRealmWriteTransaction

#pragma mark - Life cycle

- (instancetype)initWithRealmPath:(NSString*)realmPath
                         inMemory:(BOOL)inMemory
{
    if (self = [super init]) {
        NSParameterAssert(realmPath != nil);
        self.realmPath = realmPath;
        self.inMemory = inMemory;
    }
    return self;
}

- (void)dealloc
{
    DDLogInfo(@"%s", __func__);
}

#pragma mark - Realm

- (RLMRealm *)realm
{
    if (self.inMemory) {
        return [RLMRealm inMemoryRealmWithIdentifier:[self.realmPath lastPathComponent]];
    } else {
        if (self.realmPath) {
            return [RLMRealm realmWithPath:self.realmPath];
        } else {
            return [RLMRealm defaultRealm];
        }
    }
}

#pragma mark - Transaction

+ (void)writeTransactionWithRealmPath:(NSString*)realmPath
                             inMemory:(BOOL)inMemory
                           writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
{
    YSRealmWriteTransaction *trans = [[self alloc] initWithRealmPath:realmPath
                                                            inMemory:inMemory];
    [trans writeTransactionWithWriteBlock:writeBlock];
}

+ (instancetype)writeTransactionWithRealmPath:(NSString*)realmPath
                                        queue:(dispatch_queue_t)queue
                                     inMemory:(BOOL)inMemory
                                   writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                   completion:(YSRealmWriteTransactionCompletion)completion
{
    YSRealmWriteTransaction *trans = [[self alloc] initWithRealmPath:realmPath
                                                            inMemory:inMemory];
    [trans writeTransactionWithQueue:queue writeBlock:writeBlock completion:completion];
    return trans;
}

#pragma mark - Transaction Private

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
{    
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    
    if (writeBlock) writeBlock(self, realm);
    
    [realm commitWriteTransaction];
}

- (void)writeTransactionWithQueue:(dispatch_queue_t)queue
                       writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                       completion:(YSRealmWriteTransactionCompletion)completion
{
    __block RLMNotificationToken *token = [[self realm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [realm removeNotification:token];
        if (completion) completion(self);
    }];
    
    dispatch_async(queue, ^{
        [self writeTransactionWithWriteBlock:writeBlock];
    });
}

#pragma mark - State

- (void)interrupt
{
    self.interrupted = YES;
}

@end
