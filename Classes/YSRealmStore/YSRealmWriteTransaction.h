//
//  YSRealmWriteTransaction.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/12/08.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
@class YSRealmWriteTransaction;

typedef void(^YSRealmWriteTransactionWriteBlock)(YSRealmWriteTransaction *transaction, RLMRealm *realm);
typedef void(^YSRealmWriteTransactionCompletion)(YSRealmWriteTransaction *transaction);

@interface YSRealmWriteTransaction : NSObject

///------------
/// Transaction
///------------

+ (void)writeTransactionWithConfiguration:(RLMRealmConfiguration *)configuration
                               writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock;

+ (instancetype)writeTransactionWithConfiguration:(RLMRealmConfiguration *)configuration
                                            queue:(dispatch_queue_t)queue
                                       writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                       completion:(YSRealmWriteTransactionCompletion)completion;

///------
/// State
///------

- (void)interrupt;
@property (nonatomic, readonly, getter=isInterrupted) BOOL interrupted;

- (void)cancel;
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

@end
