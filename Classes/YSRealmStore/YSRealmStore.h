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

typedef void(^YSRealmStoreOperationCompletion)(YSRealmStore *store, YSRealmOperation *operation);
typedef void(^YSRealmStoreFetchOperationCompletion)(YSRealmStore *store, YSRealmOperation *operation, RLMResults *results);
typedef void(^YSRealmStoreWriteTransactionCompletion)(YSRealmStore *store, YSRealmWriteTransaction *transaction);

@interface YSRealmStore : NSObject

/* Realm */

- (RLMRealm*)realm;

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

- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion;

@end
