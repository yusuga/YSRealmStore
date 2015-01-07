//
//  User.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "User.h"
#import "NSDictionary+YSRealmStore.h"
#import "NSString+YSRealmStore.h"
#import "NSData+YSRealmStore.h"

@implementation User

- (instancetype)initWithObject:(id)object
{
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (self = [super init]) {
        self.id = [[object ys_objectOrNilForKey:@"id"] longLongValue];
        self.name = [object ys_stringOrDefaultStringForKey:@"name"];
        self.screen_name = [object ys_stringOrDefaultStringForKey:@"screen_name"];        
    }
    return self;
}

+ (NSString *)primaryKey
{
    return @"id";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"color" : [NSData ys_realmDefaultData]};
}

@end
