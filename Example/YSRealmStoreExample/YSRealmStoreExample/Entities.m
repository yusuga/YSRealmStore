//
//  Entities.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "Entities.h"
#import "NSDictionary+YSRealmStore.h"

@implementation Entities

- (instancetype)initWithObject:(id)object
{
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (self = [super init]) {
        for (NSDictionary *urlJson in [object ys_objectOrNilForKey:@"urls"]) {
            Url *url = [[Url alloc] initWithObject:urlJson];
            if (url) {
                [self.urls addObject:url];
            }
        }
        
        // Propertyの値が全て空の場合はnilを返して空オブジェクトをInsertさせない
        if ([self.urls count] == 0) {
            return nil;
        }
    }
    return self;
}

@end
