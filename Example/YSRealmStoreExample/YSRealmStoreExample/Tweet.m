//
//  Tweet.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "Tweet.h"
#import "NSDictionary+YSRealmStore.h"
#import "NSString+YSRealmStore.h"

@implementation Tweet

/**
 initWithObjects:をOverrideする理由 (Realm 0.88.0)
 
 - NSNullが例外になるケースがある。
 - RLMObject, RLMArrayが空オブジェクトの表現がオブジェクト。(nilを使いたい気もする)
 
 APIやDBを自分で制御できる場合ならデフォルトの initWithObject: をそのまま使用した方が楽。
 (その場合はJSONにnull(NSNull)を含めない、下位互換を考慮した仕様変更をする)
 
 ---
 
 YSRealmStoreでの空オブジェクトのルール (Realm 0.88.0)
 
 - RLMObject, RLMArray
 nilを許容出来るので、オブジェクトのInsertを防ぐためにnilを使用する。
 
 - NSString, NSDate, NSData
 nilを許容出来ないため、直接またはdefaultPropertyValuesで既定値を返す。
 
 ---
 
 */

- (instancetype)initWithObject:(id)object
{
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (self = [super init]) {
        self.id = [[object ys_objectOrNilForKey:@"id"] longLongValue];
        self.text = [object ys_stringOrDefaultStringForKey:@"text"];
        self.user = [[User alloc] initWithObject:[object ys_objectOrNilForKey:@"user"]];
        self.entities = [[Entities alloc] initWithObject:[object ys_objectOrNilForKey:@"entities"]];
        self.retweeted = [[object ys_objectOrNilForKey:@"retweeted"] boolValue];
    }
    return self;
}

+ (NSString *)primaryKey
{
    return @"id";
}

@end
