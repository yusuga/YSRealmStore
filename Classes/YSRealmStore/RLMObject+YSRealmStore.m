//
//  RLMObject+YSRealm.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "RLMObject+YSRealmStore.h"

@implementation RLMObject (YSRealmStore)

+ (NSString *)ys_objectOrNilWithDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    id obj = [dictionary objectForKey:key];
    if (obj == [NSNull null]) {
        return nil;
    } else {
        return obj;
    }
}

- (NSString *)ys_objectOrNilWithDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    return [[self class] ys_objectOrNilWithDictionary:dictionary forKey:key];
}

+ (NSString *)ys_stringWithDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    NSString *value = [self ys_objectOrNilWithDictionary:dictionary forKey:key];
    if (value) return value;
    return @"";
}

- (NSString *)ys_stringWithDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    return [[self class] ys_stringWithDictionary:dictionary forKey:key];
}

@end
