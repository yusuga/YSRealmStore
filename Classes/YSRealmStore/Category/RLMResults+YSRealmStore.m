//
//  RLMResults+YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/03/11.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "RLMResults+YSRealmStore.h"
#import <Realm/Realm.h>

@implementation RLMResults (YSRealmStore)

- (BOOL)ys_containsObject:(RLMObject *)object
{
    if (!object) return NO;
    
    NSString *primaryKey = [[object class] primaryKey];
    NSAssert(primaryKey.length, @"%s, Primary key is required. class: %@", __func__, NSStringFromClass([object class]));
    if (!primaryKey.length) return NO;
    
    return [self indexOfObjectWhere:@"%K = %@", primaryKey, [object valueForKey:primaryKey]] != NSNotFound;
}

@end
