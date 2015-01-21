//
//  Model.m
//  RealmExample
//
//  Created by Yu Sugawara on 2015/01/17.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "Model.h"

@implementation Model

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"string" : [self defaultString],
             @"date" : [self defaultDate],
             @"data" : [self defaultData]};
}

+ (NSString*)defaultString
{
    return @"";
}

+ (NSDate*)defaultDate
{
    return [NSDate dateWithTimeIntervalSince1970:0.];
}

+ (NSData*)defaultData
{
    return [NSData data];
}

@end
