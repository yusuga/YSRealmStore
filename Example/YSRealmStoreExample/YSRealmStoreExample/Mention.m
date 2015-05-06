//
//  Mention.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/21.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "Mention.h"
#import "NSDictionary+YSRealmStore.h"

@implementation Mention

- (instancetype)initWithValue:(id)value
{
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (self = [super init]) {
        self.id = [[value ys_objectOrNilForKey:@"id"] longLongValue];
        self.name = [value ys_stringOrDefaultStringForKey:@"name"];
    }
    return self;
}

@end
