//
//  YSRealmStore.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSRealmOperation.h"
#import "YSRealmWriteTransaction.h"
@class YSRealmStore;

typedef void(^YSRealmStoreOperationCompletion)(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm);
typedef void(^YSRealmStoreFetchOperationCompletion)(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm, RLMResults *results);
typedef void(^YSRealmStoreWriteTransactionCompletion)(YSRealmStore *store, YSRealmWriteTransaction *transaction, RLMRealm *realm);

@interface YSRealmStore : NSObject

- (instancetype)init;
- (instancetype)initWithRealmName:(NSString*)realmName;

- (RLMRealm*)realm;
+ (dispatch_queue_t)queue;

/* Transaction */

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock;
- (YSRealmWriteTransaction*)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                                completion:(YSRealmStoreWriteTransactionCompletion)completion;

/* Operation */

// Wirte

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;
- (YSRealmOperation*)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreOperationCompletion)completion;

// Delete

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;
- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmStoreOperationCompletion)completion;

- (void)deleteAllObjects;
- (void)deleteAllObjectsWithCompletion:(YSRealmStoreWriteTransactionCompletion)completion;

// Fetch

- (RLMResults*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;
- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion;

@end
