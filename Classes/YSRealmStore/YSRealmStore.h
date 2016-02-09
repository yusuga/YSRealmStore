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

///-----------------
/// @name Initialize
///-----------------

- (instancetype)initWithConfiguration:(RLMRealmConfiguration *)configuration;
@property (nonatomic, readonly) RLMRealmConfiguration *configuration;

- (RLMRealm *)realm;
- (RLMRealm *)realmWithError:(NSError **)errorPtr;
- (BOOL)inMemory;
- (BOOL)encrypted;
+ (dispatch_queue_t)queue;

///------------------
/// @name Transaction
///------------------

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock;
- (YSRealmWriteTransaction*)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                                completion:(YSRealmStoreWriteTransactionCompletion)completion;

///----------------------
/// @name Operation Write
///----------------------

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;
- (YSRealmOperation*)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreOperationCompletion)completion;

///-----------------------
/// @name Operation Delete
///-----------------------

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;
- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmStoreOperationCompletion)completion;

- (void)deleteAllObjects;
- (void)deleteAllObjectsWithCompletion:(YSRealmStoreWriteTransactionCompletion)completion;

///----------------------
/// @name Operation Fetch
///----------------------

- (id)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;
- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion;

///---------------
/// @name File
///---------------

- (BOOL)addSkipBackupAttributeToRealmFile;
- (void)removeRealmFileWithError:(NSError **)errorPtr;

///--------------
/// @name Utility
///--------------

+ (NSString*)realmPathWithFileName:(NSString *)fileName;

+ (NSData *)defaultEncryptionKey;
+ (NSData *)encryptionKeyForKeychainIdentifier:(NSString *)identifier;

@end
