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

- (instancetype)initWithValue:(id)value
{
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (self = [super init]) {
        for (NSDictionary *urlObj in [value ys_objectOrNilForKey:@"urls"]) {
            Url *url = [[Url alloc] initWithValue:urlObj];
            if (url) {
                [self.urls addObject:url];
            }
        }
        for (NSDictionary *mentionObj in [value ys_objectOrNilForKey:@"mentions"]) {
            Mention *mention = [[Mention alloc] initWithValue:mentionObj];
            if (mention) {
                [self.mentions addObject:mention];
            }
        }
        
        // Propertyの値が全て空の場合はnilを返して空オブジェクトをInsertさせない
        if ([self.urls count] == 0 && [self.mentions count] == 0) {
            return nil;
        }
    }
    return self;
}

@end
