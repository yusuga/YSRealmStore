//
//  Tweet.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "Tweet.h"
#import "RLMObject+YSRealmStore.h"

@implementation Tweet

/**
 initWithObjects:をOverrideする理由 (Realm 0.87.4)
 
 - NSNullは許容できないので、手動でNSNullを除外する必要がある
 - デフォルトのinitWithObjects:を使用する場合は、Propertyのキーが
 初期化するオブジェクトに含まれているか、defaultPropertyValuesで値を設定する必要がある。
 もしも仕様変更でキーが削除された場合には必ずクラッシュする。
 (辞書側のキーが増える分には問題ない。キーが削除された場合を考慮する必要がある。)
 
 以上、2つの理由からinitWithObjects:で手動で初期化した方が安全と判断。
 APIやDBを自分で制御できる場合ならデフォルトの実装をそのまま使用した方が楽。(JSONにnullを含めないや下位互換を考慮した仕様変更をする)
 
 ---
 
 RLMObjectの空オブジェクト表現
 - RLMObjectはnilが許容できるので空オブジェクトのインサートを防ぐためにnilを使用する
 
 ---
 
 空配列をどうするか
 - 空オブジェクトが増えることになるから除外する
 */

- (instancetype)initWithObject:(id)object
{
    if (self = [super init]) {
        self.id = [[self ys_objectOrNilWithDictionary:object forKey:@"id"] longLongValue];
        
        /**
         文字列の空オブジェクト表現
         - 文字列にnilは許容できないので空文字列を使用する (Realm 0.87.4)
         */
        self.text = [self ys_stringWithDictionary:object forKey:@"text"];        
        
        self.user = [[User alloc] initWithObject:[self ys_objectOrNilWithDictionary:object forKey:@"user"]];
        
        self.entities = [[Entities alloc] initWithObject:[self ys_objectOrNilWithDictionary:object forKey:@"entities"]];
        
        self.retweeted = [[self ys_objectOrNilWithDictionary:object forKey:@"retweeted"] boolValue];
    }
    return self;
}

+ (NSString *)primaryKey
{
    return @"id";
}

@end
