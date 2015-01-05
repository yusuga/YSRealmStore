//
//  User.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "User.h"
#import "RLMObject+YSRealmStore.h"

@implementation User

- (instancetype)initWithObject:(id)object
{
    if (self = [super init]) {
        self.id = [[self ys_objectOrNilWithDictionary:object forKey:@"id"] longLongValue];
        self.name = [self ys_stringWithDictionary:object forKey:@"name"];
        self.screen_name = [self ys_stringWithDictionary:object forKey:@"screen_name"];
    }
    return self;
}

+ (NSString *)primaryKey
{
    return @"id";
}

@end
