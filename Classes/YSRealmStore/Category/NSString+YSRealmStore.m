//
//  NSString+YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/07.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "NSString+YSRealmStore.h"

@implementation NSString (YSRealmStore)

+ (NSString*)ys_realmDefaultString
{
    return @"";
}

- (BOOL)ys_isRealmDefaultString
{
    return [self isEqualToString:[NSString ys_realmDefaultString]];
}

@end
