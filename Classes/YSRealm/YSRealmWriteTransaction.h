//
//  YSRealmWriteTransaction.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/12/08.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
@class YSRealmWriteTransaction;

typedef void(^YSRealmWriteTransactionWriteBlock)(RLMRealm *realm, YSRealmWriteTransaction *transaction);
typedef void(^YSRealmWriteTransactionCompletion)(YSRealmWriteTransaction *transaction);

@interface YSRealmWriteTransaction : NSObject

/* Transaction */

+ (void)writeTransactionWithRealmPath:(NSString*)realmPath
                           writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock;

+ (instancetype)writeTransactionWithRealmPath:(NSString*)realmPath
                                   writeBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                   completion:(YSRealmWriteTransactionCompletion)completion;

/* State */

- (void)interrupt;
@property (readonly, getter=isInterrupted) BOOL interrupted;
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished) BOOL finished;

/* Queue */

+ (dispatch_queue_t)transactionQueue;

@end
