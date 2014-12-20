//
//  Utility.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/11/18.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (void)initialize
{
    if (self == [Utility class]) {
        [RLMRealm setSchemaVersion:4 withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
            DDLogDebug(@"oldSchemaVersion: %zd", oldSchemaVersion);
            if (oldSchemaVersion < 2) {
                /**
                 *  あとからUserのIDをPrimaryKeyに変更した。マイグレーションのメモ。 (Realm 0.87.4)
                 *  IDがない場合そのままだと例外が発生するが、すでにIDがある場合にPrimaryKeyなので変更不可で変更しようとすると例外が発生する。
                 *  IDがない物に対してIDを設定する。(以下は本来であればIDが重複しないようにする必要があるので重複IDのUserは削除するようにしなければいけない。)
                 */
                [migration enumerateObjects:@"User" block:^(RLMObject *oldObject, RLMObject *newObject) {
                    static int64_t userID = 0;
                    if (((User*)newObject).id == 0) {
                        NSLog(@"user %@", newObject);
                        ((User*)newObject).id = userID++;
                    }
                }];
            }
        }];
        DDLogDebug(@"path: %@", [RLMRealm defaultRealmPath]);
    }
}

+ (void)deleteAllObjects
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
    
    NSAssert([[Tweet allObjects] count] == 0, nil);
    NSAssert([[User allObjects] count] == 0, nil);
    NSAssert([[Entities allObjects] count] == 0, nil);
    NSAssert([[Url allObjects] count] == 0, nil);
}

+ (void)addTweetWithTweetJsonObject:(NSDictionary*)tweetJsonObject
{
    [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet alloc] initWithObject:tweetJsonObject];
    }];
    
    NSNumber *twID = tweetJsonObject[@"id"];
    if ([twID isKindOfClass:[NSNumber class]] && twID) {
        NSAssert2([Tweet objectForPrimaryKey:twID].id == [twID longLongValue], @"%zd - %zd", [Tweet objectForPrimaryKey:twID].id, [twID longLongValue]);
    }
}

+ (void)addTweetsWithCount:(NSUInteger)count
{
    [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger twID = 0; twID < count; twID++) {
            [tweets addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithID:twID]]];
        }
        return tweets;
    }];
    
    for (NSUInteger twID = 0; twID < count; twID++) {
        NSAssert([Tweet objectForPrimaryKey:@(twID)] != nil, nil);
    }
}

@end
