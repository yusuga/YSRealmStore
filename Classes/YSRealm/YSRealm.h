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

- (YSRealmOperation*)addObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                     completion:(YSRealmCompletion)completion;

- (YSRealmOperation*)updateObjectsWithUpdateBlock:(YSRealmOperationUpdateBlock)updateBlock
                                       completion:(YSRealmCompletion)completion;

- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmCompletion)completion;

@end
