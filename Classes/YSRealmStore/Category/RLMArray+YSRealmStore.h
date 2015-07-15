//
//  RLMArray+YSRealm.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/12/14.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "RLMArray.h"

@interface RLMArray (YSRealmStore)

- (BOOL)ys_containsObject:(RLMObject*)object;
- (void)ys_uniqueAddObject:(RLMObject*)object;
- (void)ys_removeObject:(RLMObject*)object;

@end
