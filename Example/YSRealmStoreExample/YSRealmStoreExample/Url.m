//
//  Url.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "Url.h"
#import "NSDictionary+YSRealmStore.h"

@implementation Url

- (instancetype)initWithValue:(id)value
{
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (self = [super init]) {
        self.url = [value ys_stringOrDefaultStringForKey:@"url"];
    }
    
    return self;
}

@end
