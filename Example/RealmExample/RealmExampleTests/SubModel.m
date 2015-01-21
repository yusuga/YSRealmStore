//
//  SubModel.m
//  RealmExample
//
//  Created by Yu Sugawara on 2015/01/17.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "SubModel.h"
#import "Model.h"

@implementation SubModel

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"boolean" : @([self defaultBoolean]),
             @"integer" : @([self defaultInteger]),
             @"int64" : @([self defaultInt64]),
             @"decimal" : @([self defaultDecimal]),
             @"string" : [Model defaultString],
             @"date" : [Model defaultDate],
             @"data" : [Model defaultData]};
}

+ (BOOL)defaultBoolean
{
    return YES;
}

+ (NSInteger)defaultInteger
{
    return NSIntegerMax/2;
}

+ (int64_t)defaultInt64
{
    return INT64_MAX/2;
}

+ (CGFloat)defaultDecimal
{
    return CGFLOAT_MAX/2.f;
}

@end
