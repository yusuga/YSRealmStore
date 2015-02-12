//
//  YSRealmOperation.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
@class YSRealmOperation;

typedef id(^YSRealmOperationObjectsBlock)(YSRealmOperation *operation, RLMRealm *realm);

typedef void(^YSRealmOperationCompletion)(YSRealmOperation *operation);
typedef void(^YSRealmOperationFetchCompletion)(YSRealmOperation *operation, RLMResults *results);

@interface YSRealmOperation : NSObject

/* Write */

+ (void)writeOperationWithRealmPath:(NSString*)realmPath
                       objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

+ (instancetype)writeOperationWithRealmPath:(NSString*)realmPath
                                      queue:(dispatch_queue_t)queue
                               objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                 completion:(YSRealmOperationCompletion)completion;

/* Delete */

+ (void)deleteOperationWithRealmPath:(NSString*)realmPath
                        objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

+ (instancetype)deleteOperationWithRealmPath:(NSString*)realmPath
                                       queue:(dispatch_queue_t)queue
                                objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                  completion:(YSRealmOperationCompletion)completion;

/* Fetch */

+ (id)fetchOperationWithRealmPath:(NSString*)realmPath
                     objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

+ (instancetype)fetchOperationWithRealmPath:(NSString*)realmPath
                                      queue:(dispatch_queue_t)queue
                               objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                 completion:(YSRealmOperationFetchCompletion)completion;

/* State */

- (void)cancel;
@property (readonly, getter=isCancelled) BOOL cancelled;

@end
