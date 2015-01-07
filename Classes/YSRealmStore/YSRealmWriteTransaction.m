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
@property (nonatomic) RLMNotificationToken *notificationToken;

@end

@implementation YSRealmWriteTransaction
@synthesize interrupted = _interrupted;

+ (void)writeTransactionWithRealmPath:(NSString*)realmPath
                           writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
{
    YSRealmWriteTransaction *trans = [[self alloc] initWithRealmPath:realmPath];
    [trans writeTransactionWithWriteBlock:writeBlock];
}

+ (instancetype)writeTransactionWithRealmPath:(NSString*)realmPath
                                   writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                   completion:(YSRealmWriteTransactionCompletion)completion
{
    YSRealmWriteTransaction *trans = [[self alloc] initWithRealmPath:realmPath];
    [trans writeTransactionWithWriteBlock:writeBlock completion:completion];
    return trans;
}

#pragma mark - Init

- (instancetype)initWithRealmPath:(NSString*)realmPath
{
    if (self = [super init]) {
        NSParameterAssert(realmPath != nil);
        self.realmPath = realmPath;
    }
    return self;
}

- (RLMRealm*)realm
{
    return [RLMRealm realmWithPath:self.realmPath];
}

#pragma mark - Transaction

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
{    
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    
    if (writeBlock) writeBlock(self, realm);
    
    [realm commitWriteTransaction];
}

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                            completion:(YSRealmWriteTransactionCompletion)completion
{
    __weak typeof(self) wself = self;
    
    self.notificationToken = [[self realm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [realm removeNotification:wself.notificationToken];
        if (completion) completion(wself);
    }];
    
    dispatch_async([[self class] transactionQueue], ^{
        [wself writeTransactionWithWriteBlock:writeBlock];
    });
}

#pragma mark - State

- (void)interrupt
{
    [self setInterrupted:YES];
}

- (void)setInterrupted:(BOOL)interrupted
{
    @synchronized(self) {
        _interrupted = interrupted;
    }
}

- (BOOL)isInterrupted
{
    @synchronized(self) {
        return _interrupted;
    }
}

#pragma mark - Queue
         
+ (dispatch_queue_t)transactionQueue
{
    static dispatch_queue_t __queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __queue = dispatch_queue_create("jp.co.picos.realm.transaction.queue", NULL);
    });
    return __queue;
}

@end
