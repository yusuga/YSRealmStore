//
//  YSRealm.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSRealmOperation.h"

@interface YSRealm : NSObject

+ (instancetype)sharedInstance;
- (RLMRealm*)realm;

/* Add */

- (void)addObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

- (YSRealmOperation*)addObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                     completion:(YSRealmCompletion)completion;

/* Update */

- (void)updateObjectsWithUpdateBlock:(YSRealmOperationUpdateBlock)updateBlock;

- (YSRealmOperation*)updateObjectsWithUpdateBlock:(YSRealmOperationUpdateBlock)updateBlock
                                       completion:(YSRealmCompletion)completion;

/* Delete */

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmCompletion)completion;

/* Fetch */

- (YSRealmOperation*)fetchObjectsWithPrimaryKey:(NSString*)primaryKey
                                     fetchBlock:(YSRealmOperationFetchBlock)fetchBlock
                                     completion:(YSRealmFetchCompletion)completion;

@end
