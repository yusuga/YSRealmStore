//
//  NSDate+YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/07.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "NSDate+YSRealmStore.h"

@implementation NSDate (YSRealmStore)

+ (NSDate*)ys_realmDefaultDate
{
    return [NSDate dateWithTimeIntervalSince1970:0.];
}

- (BOOL)ys_isRealmDefaultDate
{
    return [self isEqualToDate:[NSDate ys_realmDefaultDate]];
}

@end
