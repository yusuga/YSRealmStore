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
             // @"uint64" : @([self defaultUint64]),
             @"decimal" : @([self defaultDecimal]),
             @"string" : [Model defaultString],
             @"date" : [Model defaultDate],
             @"data" : [Model defaultData],
             @"rlmInt" : @([self defaultInt64]),
             // @"rlmUint" : @([self defaultUint64]),
             @"rlmBool" : @([self defaultBoolean]),
             @"rlmDouble" : @([self defaultDouble]),
             @"rlmFloat" : @([self defaultFloat])};
}

+ (BOOL)defaultBoolean
{
    return YES;
}

+ (NSInteger)defaultInteger
{
    return NSIntegerMax;
}

+ (int64_t)defaultInt64
{
    return INT64_MAX;
}

+ (int64_t)defaultUint64
{
    return UINT64_MAX;
}

+ (CGFloat)defaultDecimal
{
    return CGFLOAT_MAX;
}

+ (double)defaultDouble
{
    return DBL_MAX;
}

+ (double)defaultFloat
{
    return FLT_MAX;
}

@end
