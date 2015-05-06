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

@protocol YSRealmStoreProtocol <NSObject>

@optional
- (void)migrationWithMigration:(RLMMigration *)migration
              oldSchemaVersion:(NSUInteger) oldSchemaVersion;
- (NSUInteger)schemaVersion;

@end

@interface YSRealmStore : NSObject <YSRealmStoreProtocol>

///-----------
/// Initialize
///-----------

- (instancetype)initWithRealmName:(NSString*)realmName;
- (instancetype)initWithRealmName:(NSString *)realmName
                         inMemory:(BOOL)inMemory;

- (instancetype)initEncryptionWithRealmName:(NSString *)realmName;
- (instancetype)initEncryptionWithRealmName:(NSString *)realmName
                         keychainIdentifier:(NSString *)keychainIdentifier;

@property (copy, nonatomic, readonly) NSString *realmPath;
@property (nonatomic, readonly) BOOL inMemory;
@property (nonatomic, readonly) BOOL encrypted;

- (RLMRealm*)realm;
+ (dispatch_queue_t)queue;

///------------
/// Transaction
///------------

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock;
- (YSRealmWriteTransaction*)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                                completion:(YSRealmStoreWriteTransactionCompletion)completion;

///----------------
/// Operation Write
///----------------

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;
- (YSRealmOperation*)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreOperationCompletion)completion;

///-----------------
/// Operation Delete
///-----------------

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;
- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmStoreOperationCompletion)completion;

- (void)deleteAllObjects;
- (void)deleteAllObjectsWithCompletion:(YSRealmStoreWriteTransactionCompletion)completion;

///----------------
/// Operation Fetch
///----------------

- (id)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;
- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion;

@end
