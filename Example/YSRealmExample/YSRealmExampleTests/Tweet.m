//
//  Tweet.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "Tweet.h"
#import <YSNSFoundationAdditions/NSDictionary+YSNSFoundationAdditions.h>
#import "RLMObject+YSRealm.h"

@implementation Tweet

/**
 initWithObjects:をOverrideする理由
 
 - NSNullは許容できないので、手動でNSNullを除外する必要がある
 - デフォルトのinitWithObjects:を使用する場合は、Propertyのキーが
 初期化するオブジェクトに含まれているか、defaultPropertyValuesで値を設定する必要がある。
 もしも仕様変更でキーが削除された場合には必ずクラッシュする。
 (辞書側のキーが増える分には問題ない。キーが削除された場合を考慮する必要がある。)
 
 以上の2つの理由からinitWithObjects:で手動で初期化する。
 
 
 RLMObjectの空オブジェクト表現
 - RLMObjectはnilが許容できるので空オブジェクトのインサートを防ぐためにnilを使用する
 
 空配列をどうするか
 - 空オブジェクトが増えることになるから除外する
 */

- (instancetype)initWithObject:(id)object
{
    if (self = [super init]) {
        self.id = [[object ys_objectOrNilForKey:@"id"] longLongValue];
        
        /**
         文字列の空オブジェクト表現
         - 文字列にnilは許容できないので空文字列を使用する
         */
        self.text = [self ys_stringWithObject:object forKey:@"text"];
        
        self.user = [[User alloc] initWithObject:[object ys_objectOrNilForKey:@"user"]];
        
        self.entities = [[Entities alloc] initWithObject:[object ys_objectOrNilForKey:@"entities"]];
    }
    return self;
}

+ (NSString *)primaryKey
{
    return @"id";
}

#if 0
+ (NSDictionary *)defaultPropertyValues
{
    return @{@"text" : @""};
}
#endif

@end
