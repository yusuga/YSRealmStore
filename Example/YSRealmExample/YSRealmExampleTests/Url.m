//
//  Url.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "Url.h"
#import "RLMObject+YSRealm.h"

@implementation Url

- (instancetype)initWithObject:(id)object
{
    if (self = [super init]) {
        self.url = [self ys_stringWithObject:object forKey:@"url"];
    }
    return self;
}

@end
