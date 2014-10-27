//
//  RLMObject+YSRealm.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "RLMObject+YSRealm.h"
#import <YSNSFoundationAdditions/NSDictionary+YSNSFoundationAdditions.h>

@implementation RLMObject (YSRealm)

- (NSString *)ys_stringWithObject:(NSDictionary *)object forKey:(NSString *)key
{
    NSString *value = [object ys_objectOrNilForKey:key];
    if (value) return value;
    return @"";
}

@end
