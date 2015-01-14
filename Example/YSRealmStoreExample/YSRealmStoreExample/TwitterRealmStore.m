//
//  Utility.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/11/18.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "TwitterRealmStore.h"
#import "NSData+YSRealmStore.h"

@implementation TwitterRealmStore

+ (void)initialize
{
    if (self == [TwitterRealmStore class]) {
        [RLMRealm setSchemaVersion:8 withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
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
            if (oldSchemaVersion < 8) {
                /**
                 *  NSData *color を追加
                 */
                [migration enumerateObjects:@"User" block:^(RLMObject *oldObject, RLMObject *newObject) {
                    User *user = (id)newObject;
                    user.color = [NSData ys_realmDefaultData];
                }];
            }
        }];
    }
}

+ (instancetype)sharedStore
{
    static TwitterRealmStore *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance =  [[self alloc] initWithRealmName:@"twitter"];
        DDLogInfo(@"class = %@; path = %@", NSStringFromClass([self class]), [__instance realm].path);
    });
    return __instance;
}

- (void)addTweetWithTweetJsonObject:(NSDictionary*)tweetJsonObject
{
    [self writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        return [[Tweet alloc] initWithObject:tweetJsonObject];
    }];
    
    RLMRealm *realm = [self realm];
    NSNumber *twID = tweetJsonObject[@"id"];
    if ([twID isKindOfClass:[NSNumber class]] && twID) {
        NSAssert2([Tweet objectInRealm:realm forPrimaryKey:twID].id == [twID longLongValue], @"%zd - %zd", [Tweet objectInRealm:realm forPrimaryKey:twID].id, [twID longLongValue]);
    }
}

- (YSRealmWriteTransaction*)addTweetsWithTweetJsonObjects:(NSArray *)tweetJsonObjects
                                               completion:(YSRealmStoreWriteTransactionCompletion)completion
{
    return [[TwitterRealmStore sharedStore] writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
        for (NSDictionary *tweetObj in tweetJsonObjects) {
            if (transaction.isInterrupted) return ;
            [realm addOrUpdateObject:[[Tweet alloc] initWithObject:tweetObj]];
        }
    } completion:completion];
}

- (void)addTweetsWithCount:(NSUInteger)count
{
    [self writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger twID = 0; twID < count; twID++) {
            [tweets addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithID:twID]]];
        }
        return tweets;
    }];
    
    for (NSUInteger twID = 0; twID < count; twID++) {
        NSAssert([Tweet objectInRealm:self.realm forPrimaryKey:@(twID)] != nil, nil);
    }
}

- (RLMResults *)fetchAllTweets
{
    return [[Tweet allObjectsInRealm:[self realm]] sortedResultsUsingProperty:@"id" ascending:NO];
}

@end
