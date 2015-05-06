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
 
 - NSNullは例外
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
 
 deleteObjects:時の挙動メモ
 
 - Userを削除したらTweetのUserはnilになる。
 - Urlを削除したらEntitiesは空配列になる(オブジェクトは削除されない)。そのEntitiesを削除すればTweetのEntitiesはnilになる。
 - Userを削除すればWatchersにも反映される(RLMArray内のオブジェクトに対しても反映される)。
 
 ---
 
 */

- (instancetype)initWithValue:(id)value
{
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (self = [super init]) {
        self.id = [[value ys_objectOrNilForKey:@"id"] longLongValue];
        self.text = [value ys_stringOrDefaultStringForKey:@"text"];
        self.user = [[User alloc] initWithValue:[value ys_objectOrNilForKey:@"user"]];
        self.entities = [[Entities alloc] initWithValue:[value ys_objectOrNilForKey:@"entities"]];
        self.retweeted = [[value ys_objectOrNilForKey:@"retweeted"] boolValue];
    }
    return self;
}

+ (NSString *)primaryKey
{
    return @"id";
}

@end
