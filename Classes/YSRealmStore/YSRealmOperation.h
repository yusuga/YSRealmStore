//
//  YSRealmOperation.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "YSRealmCancellableProtocol.h"
@class YSRealmOperation;

typedef id(^YSRealmOperationObjectsBlock)(YSRealmOperation *operation, RLMRealm *realm);

typedef void(^YSRealmOperationCompletion)(YSRealmOperation *operation);
typedef void(^YSRealmOperationFetchCompletion)(YSRealmOperation *operation, RLMResults *results);

@interface YSRealmOperation : NSObject <YSRealmCancellableProtocol>

///------
/// Write
///------

+ (void)writeOperationWithConfiguration:(RLMRealmConfiguration *)configuration
                           objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

+ (instancetype)writeOperationWithConfiguration:(RLMRealmConfiguration *)configuration
                                          queue:(dispatch_queue_t)queue
                                   objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                     completion:(YSRealmOperationCompletion)completion;

///-------
/// Delete
///-------

+ (void)deleteOperationWithConfiguration:(RLMRealmConfiguration *)configuration
                            objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

+ (instancetype)deleteOperationWithConfiguration:(RLMRealmConfiguration *)configuration
                                           queue:(dispatch_queue_t)queue
                                    objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                      completion:(YSRealmOperationCompletion)completion;

///------
/// Fetch
///------

+ (id)fetchOperationWithConfiguration:(RLMRealmConfiguration *)configuration
                         objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

+ (instancetype)fetchOperationWithConfiguration:(RLMRealmConfiguration *)configuration
                                          queue:(dispatch_queue_t)queue
                                   objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                     completion:(YSRealmOperationFetchCompletion)completion;

///------
/// State
///------

- (void)cancel;
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

@end
