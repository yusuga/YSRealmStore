//
//  YSRealmOperation.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
@class YSRealmOperation;

typedef id(^YSRealmOperationObjectsBlock)(YSRealmOperation *operation);
typedef BOOL(^YSRealmOperationUpdateBlock)(YSRealmOperation *operation);
typedef void(^YSRealmCompletion)(YSRealmOperation *operation);

@interface YSRealmOperation : NSObject

/* Add */

+ (void)addOperationWithRealmPath:(NSString*)realmPath
                     objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

+ (instancetype)addOperationWithRealmPath:(NSString*)realmPath
                                    objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                      completion:(YSRealmCompletion)completion;

/* Update */

+ (void)updateOperationWithRealmPath:(NSString*)realmPath
                         updateBlock:(YSRealmOperationUpdateBlock)updateBlock;

+ (instancetype)updateOperationWithRealmPath:(NSString*)realmPath
                                 updateBlock:(YSRealmOperationUpdateBlock)updateBlock
                                  completion:(YSRealmCompletion)completion;

/* Delete */

+ (void)deleteOperationWithRealmPath:(NSString*)realmPath
                        objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

+ (instancetype)deleteOperationWithRealmPath:(NSString*)realmPath
                                objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                  completion:(YSRealmCompletion)completion;

/* State */

- (void)cancel;
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished) BOOL finished;

/* Queue */

+ (dispatch_queue_t)operationDispatchQueue;

@end
