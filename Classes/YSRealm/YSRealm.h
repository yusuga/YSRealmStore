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

/* Wirte */

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

- (YSRealmOperation*)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmOperationCompletion)completion;

/* Delete */

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock;

- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmOperationCompletion)completion;

/* Fetch */

- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmOperationFetchCompletion)completion;

@end
