//
//  YSRealmWriteTransaction.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/12/08.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSRealmWriteTransaction.h"

@interface YSRealmWriteTransaction ()

@property (nonatomic) RLMRealmConfiguration *configuration;

@property (nonatomic, readwrite, getter=isInterrupted) BOOL interrupted;
@property (nonatomic, readwrite, getter=isCancelled) BOOL cancelled;

@end

@implementation YSRealmWriteTransaction

#pragma mark - Life cycle

- (instancetype)initWithConfiguration:(RLMRealmConfiguration *)configuration
{
    if (self = [super init]) {
        NSParameterAssert(configuration);
        self.configuration = configuration;
    }
    return self;
}

- (void)dealloc
{
#ifdef DDLogInfo
    DDLogInfo(@"%s", __func__);
#endif
}

#pragma mark - Realm

- (RLMRealm *)realm
{
    return [RLMRealm realmWithConfiguration:self.configuration error:nil];
}

#pragma mark - Transaction

+ (void)writeTransactionWithConfiguration:(RLMRealmConfiguration *)configuration
                               writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
{
    YSRealmWriteTransaction *trans = [[self alloc] initWithConfiguration:configuration];
    [trans writeTransactionWithWriteBlock:writeBlock];
}

+ (instancetype)writeTransactionWithConfiguration:(RLMRealmConfiguration *)configuration
                                            queue:(dispatch_queue_t)queue
                                       writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                       completion:(YSRealmWriteTransactionCompletion)completion
{
    YSRealmWriteTransaction *trans = [[self alloc] initWithConfiguration:configuration];
    [trans writeTransactionWithQueue:queue writeBlock:writeBlock completion:completion];
    return trans;
}

#pragma mark - Transaction Private

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
{
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    
    if (writeBlock) writeBlock(self, realm);
    
    if (self.isCancelled) {
        [realm cancelWriteTransaction];
    } else {
        [realm commitWriteTransaction];
    }
}

- (void)writeTransactionWithQueue:(dispatch_queue_t)queue
                       writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                       completion:(YSRealmWriteTransactionCompletion)completion
{
    dispatch_async(queue, ^{
        [self writeTransactionWithWriteBlock:writeBlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            /**
             *  Realm (0.88.0)
             *
             *  autorefresh == YES の場合は、BackgroundThreadのRealmのcommit時に
             *  関連するRealms(この場合MainThreadのRealmとか)にも内部的に通知されて最新のデータを指すように更新される。
             *  ただし、MainThreadのQueuing順によっては、内部での更新通知より先にここが呼ばれる可能性もあるので
             *  明示的にrefreshを行うことで確実に最新データを参照するように更新させる。
             *
             *  refreshは内部でhas_changedがチェックされ、autorefreshと明示的なrefreshが2重で実行されることはなかったので
             *  コスト面でも問題ないと思われる。
             */
            [[self realm] refresh]; // Ensure update
            if (completion) completion(self);
        });
    });
}

#pragma mark - State

- (void)interrupt
{
    self.interrupted = YES;
}

- (void)cancel
{
    self.cancelled = YES;
}

@end
