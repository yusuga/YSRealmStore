//
//  Tweet.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Realm/Realm.h>
#import "User.h"
#import "Entities.h"

@interface Tweet : RLMObject

@property NSNumber<RLMInt> *id;
@property NSString *text;
@property User *user;
@property Entities *entities;
@property RLMArray<User> *watchers;
@property BOOL retweeted;

/**
 *  Unavailable Methods
 *  YSRealmStoreは初期化によってRealmがdefaultRealm以外に変更される可能性があるので、
 *  通常のFetchクラスメソッドを使用すると予期しない結果が起こる場合がある。
 *  (以下のFetchクラスメソッドはdefaultRealmが引数にされている。)
 *  以下をunavailableにしてrealmを引数に取るクラスメソッドのみ使用するようにする。
 */

+ (RLMResults *)allObjects __attribute__((unavailable("Use +allObjectsInRealm: instead.")));
+ (RLMResults *)objectsWhere:(NSString *)predicateFormat, ... __attribute__((unavailable("Use +objectsInRealm:where: instead.")));
+ (RLMResults *)objectsWithPredicate:(NSPredicate *)predicate __attribute__((unavailable("Use +objectsInRealm:withPredicate: instead.")));
+ (instancetype)objectForPrimaryKey:(id)primaryKey __attribute__((unavailable("Use +objectInRealm:forPrimaryKey: instead.")));

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Tweet>
RLM_ARRAY_TYPE(Tweet)
