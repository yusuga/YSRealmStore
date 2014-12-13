//
//  RLMArray+YSRealm.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/12/14.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "RLMArray.h"

@interface RLMArray (YSRealm)

- (BOOL)ys_containsObject:(RLMObject*)object;
- (void)ys_addUniqueObject:(RLMObject*)object;
- (void)ys_removeObject:(RLMObject*)object;

@end
