//
//  NSData+YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/07.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "NSData+YSRealmStore.h"

@implementation NSData (YSRealmStore)

+ (NSData*)ys_realmDefaultData
{
    return [[NSData alloc] init];
}

- (BOOL)ys_isRealmDefaultData
{
    return [self isEqualToData:[NSData ys_realmDefaultData]];
}

@end
