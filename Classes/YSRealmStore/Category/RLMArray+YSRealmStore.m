//
//  RLMArray+YSRealm.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/12/14.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "RLMArray+YSRealmStore.h"
#import <Realm/Realm.h>

@implementation RLMArray (YSRealmStore)

- (BOOL)ys_containsObject:(RLMObject *)object
{
    if (!object) return NO;
    
    NSString *primaryKey = [[object class] primaryKey];
    NSAssert(primaryKey.length, @"%s, Primary key is required. class: %@", __func__, NSStringFromClass([object class]));
    if (!primaryKey.length) return NO;
    
    return [self indexOfObjectWhere:@"%K = %@", primaryKey, [object valueForKey:primaryKey]] != NSNotFound;
}

- (void)ys_uniqueAddObject:(RLMObject*)object
{
    if (!object) return;
    if (![self ys_containsObject:object]) {
        [self addObject:object];
    }
}

- (void)ys_removeObject:(RLMObject*)object
{
    if (!object) return;
    if ([self ys_containsObject:object]) {
        [self removeObjectAtIndex:[self indexOfObject:object]];
    }
}

@end
