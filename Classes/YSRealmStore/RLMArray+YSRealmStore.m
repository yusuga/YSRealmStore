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

- (BOOL)ys_containsObject:(RLMObject*)object
{
#if 1
    if (object == nil) return NO;
    NSAssert([[object class] primaryKey], @"Primary key is required.");
    return [self indexOfObject:object] != NSNotFound;
#else
    // test
    if (object == nil) return NO;
    for (RLMObject *obj in self) {
        if ([obj isEqualToObject:object]) {
            return YES;
        }
    }
    return NO;
#endif
}

- (void)ys_addUniqueObject:(RLMObject*)object
{
    if (object == nil) return;
    NSAssert([[object class] primaryKey], @"Primary key is required.");
    if (![self ys_containsObject:object]) {
        [self addObject:object];
    }
}

- (void)ys_removeObject:(RLMObject*)object
{
    if (object == nil) return;
    NSAssert([[object class] primaryKey], @"Primary key is required.");
    if ([self ys_containsObject:object]) {
        [self removeObjectAtIndex:[self indexOfObject:object]];
    }
}

/*
- (NSInteger)ys_indexOfObject:(RLMObject*)object
{
    if (object) {
        NSInteger idx = 0;
        for (RLMObject *obj in self) {
            if ([obj isEqual:object]) {
                return idx;
            }
            idx++;
        }
    }
    return NSNotFound;
}
 */


@end
