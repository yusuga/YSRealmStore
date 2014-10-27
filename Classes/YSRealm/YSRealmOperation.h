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

+ (instancetype)addOperationWithRealmPath:(NSString*)realmPath
                                    objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                      completion:(YSRealmCompletion)completion;

+ (instancetype)updateOperationWithRealmPath:(NSString*)realmPath
                                 updateBlock:(YSRealmOperationUpdateBlock)updateBlock
                                  completion:(YSRealmCompletion)completion;

+ (instancetype)deleteOperationWithRealmPath:(NSString*)realmPath
                                objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                  completion:(YSRealmCompletion)completion;

- (void)cancel;
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished) BOOL finished;

@end
