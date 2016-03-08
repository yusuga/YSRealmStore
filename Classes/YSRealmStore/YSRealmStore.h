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

///-----------
/// @name File
///-----------

/**
 *  Add in place compact method
 *  https://github.com/realm/realm-cocoa/issues/1243
 *
 *  RLMRealmを1つもretainしていないタイミングで実行する必要がある。
 */
+ (BOOL)compactRealmFileWithConfiguration:(RLMRealmConfiguration *)configuration
                                    error:(NSError **)errorPtr;
- (unsigned long long)realmFileSize;

- (BOOL)addSkipBackupAttributeToRealmFilesWithError:(NSError **)errorPtr;

- (BOOL)deleteRealmFilesWithError:(NSError **)errorPtr;
+ (BOOL)deleteRealmFilesWithRealmFilePath:(NSString *)realmFilePath
                                    error:(NSError **)errorPtr;

///-----------------
/// @name Encryption
///-----------------

+ (NSString *)defaultKeychainIdentifier;
+ (NSData *)defaultEncryptionKey;
+ (NSData *)encryptionKeyForKeychainIdentifier:(NSString *)identifier;
+ (BOOL)deleteDefaultEncryptionKey;
+ (BOOL)deleteEncryptionKeyWithKeychainIdentifier:(NSString *)identifier;

///--------------
/// @name Utility
///--------------

+ (NSString*)realmPathWithFileName:(NSString *)fileName;

@end
