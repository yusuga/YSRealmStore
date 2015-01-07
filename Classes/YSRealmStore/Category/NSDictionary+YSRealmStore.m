//
//  NSDictionary+YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/07.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "NSDictionary+YSRealmStore.h"
#import "NSString+YSRealmStore.h"

@implementation NSDictionary (YSRealmStore)

- (id)ys_objectOrNilForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if (obj == [NSNull null]) {
        return nil;
    } else {
        return obj;
    }
}

- (NSString *)ys_stringOrDefaultStringForKey:(NSString *)key
{
    NSString *str = [self ys_objectOrNilForKey:key];
    if (str) {
        return str;
    } else {
        return [NSString ys_realmDefaultString];
    }
}

@end
