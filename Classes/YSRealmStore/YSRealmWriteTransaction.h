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

/* Transaction */

+ (void)writeTransactionWithRealmPath:(NSString*)realmPath
                             inMemory:(BOOL)inMemory
                           writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock;

+ (instancetype)writeTransactionWithRealmPath:(NSString*)realmPath
                                        queue:(dispatch_queue_t)queue
                                     inMemory:(BOOL)inMemory
                                   writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                   completion:(YSRealmWriteTransactionCompletion)completion;

/* State */

- (void)interrupt;
@property (readonly, getter=isInterrupted) BOOL interrupted;

- (void)cancel;
@property (readonly, getter=isCancelled) BOOL cancelled;

@end
