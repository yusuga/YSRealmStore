//
//  RLMArray+YSRealm.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/12/14.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "RLMArray+YSRealm.h"
#import <Realm/Realm.h>

@implementation RLMArray (YSRealm)

- (BOOL)ys_containsObject:(RLMObject*)object
{
    if (object == nil) return NO;
    NSAssert([[object class] primaryKey], @"Primary key is required.");
    return [self indexOfObject:object] != NSNotFound;
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

@end
