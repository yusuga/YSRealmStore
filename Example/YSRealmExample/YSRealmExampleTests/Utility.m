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
        [RLMRealm setSchemaVersion:1 withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
            DDLogDebug(@"oldSchemaVersion: %zd", oldSchemaVersion);
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
    [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet alloc] initWithObject:tweetJsonObject];
    }];
    
    NSNumber *twID = tweetJsonObject[@"id"];
    if ([twID isKindOfClass:[NSNumber class]] && twID) {
        NSAssert2([Tweet objectForPrimaryKey:twID].id == [twID longLongValue], @"%zd - %zd", [Tweet objectForPrimaryKey:twID].id, [twID longLongValue]);
    }
}

+ (void)addTweetsWithCount:(NSUInteger)count
{
    [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
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
