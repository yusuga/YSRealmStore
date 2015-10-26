//
//  RLMResults+YSRealmStore.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/03/11.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <realm/RLMResults.h>

@interface RLMResults (YSRealmStore)

- (BOOL)ys_containsObject:(RLMObject*)object;

@end
