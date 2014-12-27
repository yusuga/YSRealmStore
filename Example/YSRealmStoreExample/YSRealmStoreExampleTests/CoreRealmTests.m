//
//  CoreRealmTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TwitterRealmStore.h"

@interface CoreRealmTests : XCTestCase

@end

@implementation CoreRealmTests

- (void)setUp
{
    [super setUp];
    
    [[TwitterRealmStore sharedInstance] deleteAllObjects];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Insert

- (void)testInsertTweet
{
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertNotNil(addedTweet);
    
    XCTAssertEqual(addedTweet.id, INT64_MAX);
    XCTAssertGreaterThan(addedTweet.text.length, 0);
    
    User *user = addedTweet.user;
    XCTAssertNotNil(user);
    XCTAssertEqual(user.id, INT64_MAX);
    XCTAssertGreaterThan(user.name.length, 0);
    
    Entities *entities = addedTweet.entities;
    XCTAssertNotNil(entities);
    XCTAssertEqual([entities.urls count], 1);
    for (Url *url in entities.urls) {
        XCTAssertNotNil(url);
        XCTAssertGreaterThan(url.url.length, 0);
    }
}

- (void)testInsertTweets
{
    NSUInteger count = 10;
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:count];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    
    RLMResults *tweets = [[Tweet allObjects] sortedResultsUsingProperty:@"id" ascending:YES];
    for (NSUInteger i = 0; i < [tweets count]; i++) {
        Tweet *tweet = tweets[i];
        XCTAssertEqual(tweet.id, i);
        XCTAssertEqual(tweet.user.id, i);
    }
}

- (void)testInsertTweetOfEmptyArray
{
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweetOfContainEmptyArray]];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertNotNil(addedTweet);
    
    XCTAssertEqual(addedTweet.id, INT64_MAX);
    XCTAssertGreaterThan(addedTweet.text.length, 0);
    
    User *user = addedTweet.user;
    XCTAssertNotNil(user);
    XCTAssertEqual(user.id, INT64_MAX);
    XCTAssertGreaterThan(user.name.length, 0);
    
    Entities *entities = addedTweet.entities;
    XCTAssertNil(entities);
}

- (void)testInsertTweetOfConstainNSNull
{
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweetOfContainNSNull]];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertNotNil(addedTweet);
    
    XCTAssertEqual(addedTweet.id, 0);
    XCTAssertEqual(addedTweet.text.length, 0);
    
    User *user = addedTweet.user;
    XCTAssertNotNil(user);
    XCTAssertEqual(user.id, 0);
    XCTAssertEqual(user.name.length, 0);
    
    Entities *entities = addedTweet.entities;
    XCTAssertNil(entities);
}

- (void)testInsetTweetOfKeyIsNotEnough
{
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweetOfKeyIsNotEnough]];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertNotNil(addedTweet);
    
    XCTAssertEqual(addedTweet.id, 0);
    XCTAssertEqual(addedTweet.text.length, 0);
    
    User *user = addedTweet.user;
    XCTAssertNotNil(user);
    XCTAssertEqual(user.id, 0);
    XCTAssertEqual(user.name.length, 0);
    
    Entities *entities = addedTweet.entities;
    XCTAssertNil(entities);
}

- (void)testUniqueInsert
{
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertNotNil(addedTweet);
    
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    tweet.text = @"";
    tweet.user = nil;
    tweet.entities = nil;
    [self addOrUpdateTweet:tweet];
    
    XCTAssertEqual([[Tweet allObjects] count], 1);
    addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertEqualObjects(addedTweet.text, @"");
    XCTAssertNil(tweet.user);
    XCTAssertNil(tweet.entities);
}

- (void)testInsertNestedObject
{
    int64_t tweetID = 0;
    int64_t userID = 0;
    NSDictionary *tweetObj = [JsonGenerator tweetWithTweetID:tweetID userID:userID];
    
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:tweetObj];
    XCTAssertNotNil([User objectForPrimaryKey:@(userID)]);
    
    int64_t tweetID2 = 1;
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:tweetID2 userID:userID]];
    
    XCTAssertNotNil([Tweet objectForPrimaryKey:@(tweetID)]);
    XCTAssertNotNil([Tweet objectForPrimaryKey:@(tweetID)].user);
    XCTAssertEqual([Tweet objectForPrimaryKey:@(tweetID)].user.id, userID);
    XCTAssertNotNil([Tweet objectForPrimaryKey:@(tweetID2)]);
    XCTAssertNotNil([Tweet objectForPrimaryKey:@(tweetID2)].user);
    XCTAssertEqual([Tweet objectForPrimaryKey:@(tweetID2)].user.id, userID);
    
    XCTAssertEqual([[Tweet allObjects] count], 2);
    XCTAssertEqual([[User allObjects] count], 1);
}

#pragma mark - Equal

- (void)testEqual
{
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    [self addOrUpdateTweet:tweet];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    
    XCTAssertEqualObjects(tweet, addedTweet);
}

#pragma mark - Update

- (void)testUpdate
{
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    [self addOrUpdateTweet:tweet];
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 1);
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertEqualObjects(tweet, addedTweet);
    XCTAssertEqual(addedTweet.id, INT64_MAX);
    XCTAssertEqualObjects(addedTweet.text, @"");
    XCTAssertNil(addedTweet.user);
    XCTAssertNil(addedTweet.entities);
}

#pragma mark - Delete

- (void)testDeleteRelationObject
{
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        [realm deleteObjects:[User allObjects]];
    }];
    
    Tweet *tweet = [[Tweet allObjects] firstObject];
    XCTAssertNil(tweet.user);
}

- (void)testDeleteRelationObjects
{
    int64_t count = 10;
    for (int64_t twID = 0; twID < count; twID++) {
        [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:twID userID:0]];
    }
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], 1);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        [realm deleteObjects:[User allObjects]];
    }];
    
    for (Tweet *tweet in [Tweet allObjects]) {
        XCTAssertNil(tweet.user);
    }
}

- (void)testDeleteToManyRelationObjects
{
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:0 userID:0 urlCount:5]];
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        [realm deleteObjects:[Url allObjects]];
    }];
    
    /* RLMArray は空配列になるだけでオブジェクトは削除されない */
    XCTAssertEqual([[Entities allObjects] count], 1);
    Entities *entities = [[Entities allObjects] firstObject];
    XCTAssertEqual([entities.urls count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (Entities *entities in [Entities allObjects]) {
            if ([entities.urls count] == 0) {
                [realm deleteObject:entities];
            }
        }
    }];
    
    XCTAssertEqual([[Entities allObjects] count], 0);
    Tweet *tweet = [[Tweet allObjects] firstObject];
    XCTAssertNil(tweet.entities);
}

- (void)testDeleteNestedRelationObjects
{
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:0 userID:0 urlCount:5]];
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        Tweet *tweet = [[Tweet allObjects] firstObject];
        for (Url *url in tweet.entities.urls) {
            [realm deleteObject:url];
        }
        [realm deleteObject:tweet.entities];
        [realm deleteObject:tweet];
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
    XCTAssertEqual([[Entities allObjects] count], 0);
    XCTAssertEqual([[Url allObjects] count], 0);
}

- (void)testDeleteMultipleToManyRelationObjects
{
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:10];
    
    NSUInteger watchersCount = 3;
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (Tweet *tweet in [Tweet allObjects]) {
            for (NSUInteger userID = 0; userID < watchersCount; userID++) {
                User *user = [User objectForPrimaryKey:@(userID)];
                if (user == nil) {
                    user = [[User alloc] initWithObject:[JsonGenerator userWithID:userID]];
                }
                [tweet.watchers addObject:user];
            }
        }
    }];
    
    for (Tweet *tweet in [Tweet allObjects]) {
        XCTAssertEqual([tweet.watchers count], watchersCount);
    }
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        [realm deleteObjects:[User allObjects]];
    }];
    
    for (Tweet *tweet in [Tweet allObjects]) {
        XCTAssertEqual([tweet.watchers count], 0);
    }
}

#pragma mark - Cancel

- (void)testCancelAddObject
{
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:tweet];
    [realm cancelWriteTransaction];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
}

- (void)testCancelUpdateObject
{
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [self addOrUpdateTweet:[[Tweet alloc] initWithObject:tweetJsonObj]];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    addedTweet.text = @"";
    addedTweet.user = nil;
    addedTweet.entities = nil;
    
    XCTAssertEqualObjects(addedTweet.text, @"");
    XCTAssertNil(addedTweet.user);
    XCTAssertNil(addedTweet.entities);
    
    [realm cancelWriteTransaction];
    
    XCTAssertEqual(addedTweet.id, [tweetJsonObj[@"id"] longLongValue]);
    XCTAssertEqualObjects(addedTweet.text, tweetJsonObj[@"text"]);
    XCTAssertNotNil(addedTweet.user);
    XCTAssertNotNil(addedTweet.entities);
}

- (void)testCancelDeleteObject
{
    [self addOrUpdateTweet:[[Tweet alloc] initWithObject:[JsonGenerator tweet]]];
    
    XCTAssertGreaterThan([[Tweet allObjects] count], 0);
    XCTAssertGreaterThan([[User allObjects] count], 0);
    XCTAssertGreaterThan([[Entities allObjects] count], 0);
    XCTAssertGreaterThan([[Url allObjects] count], 0);
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    [realm deleteAllObjects];
    XCTAssertEqual([[Tweet allObjects] count], 0);
    XCTAssertEqual([[User allObjects] count], 0);
    XCTAssertEqual([[Entities allObjects] count], 0);
    XCTAssertEqual([[Url allObjects] count], 0);
    
    [realm cancelWriteTransaction];

    XCTAssertGreaterThan([[Tweet allObjects] count], 0);
    XCTAssertGreaterThan([[User allObjects] count], 0);
    XCTAssertGreaterThan([[Entities allObjects] count], 0);
    XCTAssertGreaterThan([[Url allObjects] count], 0);
}

#pragma mark - Query

- (void)testPredicateWithInt64Max
{
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:10];
    [self addOrUpdateTweet:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithID:INT64_MAX]]];
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"id = %lld", INT64_MAX]];
    XCTAssertEqual([results count], 1);
    Tweet *tweet = [results firstObject];
    XCTAssertEqual(tweet.id, INT64_MAX);
}

- (void)testPredicateWithUint64Max
{
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:10];
    [self addOrUpdateTweet:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithID:UINT64_MAX]]];
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"id = %llu", UINT64_MAX]];
    XCTAssertEqual([results count], 1);
    Tweet *tweet = [results firstObject];
    XCTAssertEqual(tweet.id, UINT64_MAX);
}

- (void)testFetchTweetWithUserID
{
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:10];
    
    int64_t id = 5;
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"user.id = %@", @(id)]];
    XCTAssertEqual([results count], 1);
    Tweet *tweet = [results firstObject];
    XCTAssertEqual(tweet.id, id);
    XCTAssertEqual(tweet.user.id, id);
}

- (void)testFetchTweetWithUser
{
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:10];
    
    int64_t id = 5;
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"user = %@", [User objectForPrimaryKey:@(id)]]];
    XCTAssertEqual([results count], 1);
    Tweet *tweet = [results firstObject];
    XCTAssertEqual(tweet.id, id);
    XCTAssertEqual(tweet.user.id, id);
}

- (void)testNil
{
    NSMutableDictionary *tweetObj = [JsonGenerator tweetWithTweetID:0 userID:0].mutableCopy;
    [tweetObj removeObjectForKey:@"entities"];
    
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:tweetObj];
    [[TwitterRealmStore sharedInstance] addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:1 userID:1]];
    
    XCTAssertEqual([[Tweet allObjects] count], 2);
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"entities = nil"]];
    XCTAssertEqual([results count], 1);
    Tweet *tweet = [results firstObject];
    XCTAssertEqual(tweet.id, 0);
    XCTAssertNil(tweet.entities);
    
    results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"entities != nil"]];
    XCTAssertEqual([results count], 1);
    tweet = [results firstObject];
    XCTAssertEqual(tweet.id, 1);
    XCTAssertNotNil(tweet.entities);
}

- (void)testANYWithPrimitiveValue
{
    NSUInteger count = 10;
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:count];
    XCTAssertEqual([[Tweet allObjects] count], count);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (Tweet *tweet in [[Tweet allObjects] sortedResultsUsingProperty:@"id" ascending:YES]) {
            for (NSUInteger userID = 0; userID <= tweet.id; userID++) {
                User *user = [User objectForPrimaryKey:@(userID)];
                if (user == nil) {
                    user = [[User alloc] initWithObject:[JsonGenerator userWithID:userID]];
                }
                [tweet.watchers addObject:user];
            }
        }
    }];
    
    XCTAssertEqual([[User allObjects] count], count);
    
    for (NSUInteger i = 0; i < count; i++) {
        RLMResults *tweets = [Tweet objectsWhere:@"ANY watchers.id = %d", i];
        XCTAssertEqual([tweets count], count - i);
    }
}

- (void)testANYWithPrimitiveValues
{
    NSUInteger count = 10;
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:count];
    XCTAssertEqual([[Tweet allObjects] count], count);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (Tweet *tweet in [[Tweet allObjects] sortedResultsUsingProperty:@"id" ascending:YES]) {
            for (NSUInteger userID = 0; userID <= tweet.id; userID++) {
                User *user = [User objectForPrimaryKey:@(userID)];
                if (user == nil) {
                    user = [[User alloc] initWithObject:[JsonGenerator userWithID:userID]];
                }
                [tweet.watchers addObject:user];
            }
        }
    }];
    
    XCTAssertEqual([[User allObjects] count], count);
    
    NSMutableArray *ids = @[].mutableCopy;
    for (NSUInteger i = 0; i < count; i++) {
        [ids addObject:@(i)];
    }
    XCTAssertEqual([ids count], count);
    
    RLMResults *tweets = [Tweet objectsWhere:@"ANY watchers.id IN %@", ids];
    XCTAssertEqual([tweets count], count);
}

- (void)testANYWithObject
{
    NSUInteger count = 10;
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:count];
    XCTAssertEqual([[Tweet allObjects] count], count);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (Tweet *tweet in [[Tweet allObjects] sortedResultsUsingProperty:@"id" ascending:YES]) {
            for (NSUInteger userID = 0; userID <= tweet.id; userID++) {
                User *user = [User objectForPrimaryKey:@(userID)];
                if (user == nil) {
                    user = [[User alloc] initWithObject:[JsonGenerator userWithID:userID]];
                }
                [tweet.watchers addObject:user];
            }
        }
    }];
    
    XCTAssertEqual([[User allObjects] count], count);
    
    for (NSUInteger i = 0; i < count; i++) {
        RLMResults *tweets = [Tweet objectsWhere:@"ANY watchers = %@", [User objectForPrimaryKey:@(i)]];
        XCTAssertEqual([tweets count], count - i);
    }
}

- (void)testANYWithObjects
{
    NSUInteger count = 10;
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:count];
    XCTAssertEqual([[Tweet allObjects] count], count);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (Tweet *tweet in [[Tweet allObjects] sortedResultsUsingProperty:@"id" ascending:YES]) {
            for (NSUInteger userID = 0; userID <= tweet.id; userID++) {
                User *user = [User objectForPrimaryKey:@(userID)];
                if (user == nil) {
                    user = [[User alloc] initWithObject:[JsonGenerator userWithID:userID]];
                }
                [tweet.watchers addObject:user];
            }
        }
    }];
    
    XCTAssertEqual([[User allObjects] count], count);
    
    NSMutableArray *users = @[].mutableCopy;
    for (NSUInteger i = 0; i < count; i++) {
        [users addObject:[User objectForPrimaryKey:@(i)]];
    }
    XCTAssertEqual([users count], count);
    
    RLMResults *tweets = [Tweet objectsWhere:@"ANY watchers IN %@", users];
    XCTAssertEqual([tweets count], count);
}

- (void)testAlternativeMethodOfCountFunction
{
    NSUInteger count = 10;
    [[TwitterRealmStore sharedInstance] addTweetsWithCount:count];
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t tweetID = 0; tweetID < count; tweetID++) {
            if (tweetID < count/2) {
                Tweet *tweet = [Tweet objectForPrimaryKey:@(tweetID)];
                
                NSUInteger watchersCount = arc4random_uniform(5) + 1;
                for (NSUInteger userID = 0; userID < watchersCount; userID++) {
                    User *user = [User objectForPrimaryKey:@(userID)];
                    if (user == nil) {
                        user = [[User alloc] initWithObject:[JsonGenerator userWithID:userID]];
                    }
                    [tweet.watchers addObject:user];
                }
            }
        }
    }];
    XCTAssertEqual([[Tweet allObjects] count], count);
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"ANY watchers.id >= 0"]];
    XCTAssertEqual([results count], count/2);
    for (Tweet *tweet in results) {
        XCTAssertGreaterThan([tweet.watchers count], 0);
    }
    
    results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"!(ANY watchers.id >= 0)"]];
    XCTAssertEqual([results count], count/2);
    for (Tweet *tweet in results) {
        XCTAssertEqual([tweet.watchers count], 0);
    }
}

- (void)testCount
{
#warning Unsupported (Realm 0.88.0)
#if 0
    [Utility addTweetsWithCount:1];
    XCTAssertEqual([[Tweet allObjects] count], 1);
    
    NSUInteger watchersCount = 3;
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        Tweet *tweet = [[Tweet allObjects] firstObject];
        for (NSUInteger userID = 0; userID < watchersCount; userID++) {
            User *user = [User objectForPrimaryKey:@(userID)];
            if (user == nil) {
                user = [[User alloc] initWithObject:[JsonGenerator userWithID:userID]];
            }
            [tweet.watchers addObject:user];
        }
    }];
    
    XCTAssertEqual([[User allObjects] count], watchersCount);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"watchers.@count = %d", watchersCount];
    XCTAssertTrue([[Tweet objectsWithPredicate:predicate] count]);
#endif
}

- (void)testCount2
{
#warning Unsupported (Realm 0.88.0)
#if 0
    for (NSUInteger i = 0; i < 10; i++) {
        [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:i userID:i urlCount:0]];
    }
    
    int64_t id = INT64_MAX;
    NSUInteger urlCount = 3;
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:id userID:id urlCount:urlCount]];
    
#if 1
    NSArray *predicates = @[[NSPredicate predicateWithFormat:@"entities.urls.@count = %@", @(urlCount)]];
#else
    NSArray *predicates = @[[NSPredicate predicateWithFormat:@"entities.urls.@count = %@", @(urlCount)],
                            [NSPredicate predicateWithFormat:@"entities.urls.@count = 3"]];
#endif
    
    for (NSPredicate *predicate in predicates) {
        RLMResults *results = [Tweet objectsWithPredicate:predicate];
        XCTAssertEqual([results count], 1);
        Tweet *tweet = [results firstObject];
        XCTAssertEqual(tweet.id, id);
        XCTAssertEqual(tweet.user.id, id);
        XCTAssertEqual([tweet.entities.urls count], urlCount);
    }
#endif
}

- (void)testToManyWithBEGINSWITH
{
#warning Unsupported (Realm 0.87.1)
#if 0
    for (NSUInteger i = 0; i < 10; i++) {
        [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:i userID:i urlCount:0]];
    }
    
    int64_t id = INT64_MAX;
    NSUInteger urlCount = 3;
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:id userID:id urlCount:urlCount]];
    
#if 1
    NSArray *predicates = @[[NSPredicate predicateWithFormat:@"entities.urls.url BEGINSWITH %@", @"h"]];
#else
    NSArray *predicates = @[[NSPredicate predicateWithFormat:@"entities.urls.url BEGINSWITH %@", @"h"],
                            [NSPredicate predicateWithFormat:@"entities.urls.url BEGINSWITH 'h'"]];
#endif
    for (NSPredicate *predicate in predicates) {
        RLMResults *results = [Tweet objectsWithPredicate:predicate];
        XCTAssertEqual([results count], 1);
        Tweet *tweet = [results firstObject];
        XCTAssertEqual(tweet.id, id);
        XCTAssertEqual(tweet.user.id, id);
        XCTAssertEqual([tweet.entities.urls count], urlCount);
    }
#endif
}

#pragma mark - RLMResults

- (void)testRLMResultsWithEqualBool
{
    int64_t tweetID = 0;
    int64_t userID = 0;
    NSMutableDictionary *tweetObj = [JsonGenerator tweetWithTweetID:tweetID userID:userID].mutableCopy;
    [tweetObj setObject:@YES forKey:@"retweeted"];
    
    RLMResults *results = [Tweet objectsWhere:@"retweeted = 1"];
    XCTAssertEqual([results count], 0);
    NSLog(@"%@", results);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        [realm addObject:[[Tweet alloc] initWithObject:tweetObj]];
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 1);
    XCTAssertEqual([results count], 1);
}

- (void)testRLMResultsWithEqualInteger
{
    NSUInteger count = 10;
    RLMResults *results = [Tweet objectsWhere:@"id = 5"];
    XCTAssertEqual([results count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            [realm addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:i userID:i]]];
        }
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    XCTAssertEqual([results count], 1);
}

- (void)testRLMResultsWithEqualIntegerAndEqualBool
{
    NSUInteger count = 10;
    RLMResults *results = [Tweet objectsWhere:@"id = 5 AND retweeted = 1"];
    XCTAssertEqual([results count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            NSMutableDictionary *tweetObj = [JsonGenerator tweetWithTweetID:i userID:i].mutableCopy;
            [tweetObj setObject:@YES forKey:@"retweeted"];
            [realm addObject:[[Tweet alloc] initWithObject:tweetObj]];
        }
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    XCTAssertEqual([results count], 1);
}

- (void)testRLMResultsWithGreaterThanOrEqual
{
    NSUInteger count = 10;
    RLMResults *results = [Tweet objectsWhere:@"id >= %d", count/2];
    XCTAssertEqual([results count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            [realm addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:i userID:i]]];
        }
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    XCTAssertEqual([results count], count/2);
}

- (void)testRLMResultsWithIntegerInObject
{
    NSUInteger count = 10;
    RLMResults *results = [Tweet objectsWhere:@"user.id = 5"];
    XCTAssertEqual([results count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            [realm addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:i userID:i]]];
        }
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    XCTAssertEqual([results count], 1);
}

- (void)testRLMResultsWithLessThanIntegerInObject
{
    NSUInteger count = 10;
    RLMResults *results = [Tweet objectsWhere:@"user.id < %d", count/2];
    XCTAssertEqual([results count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            [realm addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:i userID:i]]];
        }
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    XCTAssertEqual([results count], count/2);
}

- (void)testRLMResultsWithObject
{
    int64_t userID = 5;
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        [realm addObject:[[User alloc] initWithObject:[JsonGenerator userWithID:userID]]];
    }];
    
    User *user = [User objectForPrimaryKey:@(userID)];
    XCTAssertNotNil(user);
    
    NSUInteger count = 10;
    RLMResults *results = [Tweet objectsWhere:@"user = %@", user];
    XCTAssertEqual([results count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            [realm addOrUpdateObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:i userID:i]]];
        }
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    XCTAssertEqual([results count], 1);
}

- (void)testRLMResultsWithObjects
{
    NSUInteger userCount = 5;
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < userCount; i++) {
            [realm addObject:[[User alloc] initWithObject:[JsonGenerator userWithID:i]]];
        }
    }];
    XCTAssertEqual([[User allObjects] count], userCount);
    
    RLMResults *users = [User allObjects];
    
    NSUInteger count = 10;
    RLMResults *results = [Tweet objectsWhere:@"user IN %@", users];
    XCTAssertEqual([results count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            [realm addOrUpdateObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:i userID:i]]];
        }
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    XCTAssertEqual([results count], userCount);
}

- (void)testRLMResultsWithANYObject
{
    int64_t userID = 5;
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        [realm addObject:[[User alloc] initWithObject:[JsonGenerator userWithID:userID]]];
    }];
    
    User *user = [User objectForPrimaryKey:@(userID)];
    XCTAssertNotNil(user);
    
    NSUInteger count = 10;
    RLMResults *results = [Tweet objectsWhere:@"ANY watchers = %@", user];
    XCTAssertEqual([results count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:i userID:i]];
            if (i == userID) {
                User *user = [User objectForPrimaryKey:@(userID)];
                XCTAssertNotNil(user);
                [tweet.watchers addObject:user];
            }
            [realm addOrUpdateObject:tweet];
        }
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    XCTAssertEqual([results count], 1);
}

- (void)testRLMResultsWithANYObjects
{
    NSUInteger userCount = 5;
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < userCount; i++) {
            [realm addObject:[[User alloc] initWithObject:[JsonGenerator userWithID:i]]];
        }
    }];
    XCTAssertEqual([[User allObjects] count], userCount);
    
    RLMResults *users = [User allObjects];
    
    NSUInteger count = 100;
    RLMResults *results = [Tweet objectsWhere:@"ANY watchers IN %@", users];
    XCTAssertEqual([results count], 0);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:i userID:i]];
            
            for (int64_t userID = 0; userID < arc4random_uniform(userCount) + 1; userID++) {
                User *user = [User objectForPrimaryKey:@(userID)];
                XCTAssertNotNil(user);
                [tweet.watchers addObject:user];
            }
            
            [realm addOrUpdateObject:tweet];
        }
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count);
    XCTAssertEqual([[User allObjects] count], count);
    XCTAssertEqual([results count], count);
}

- (void)testRLMResultsWithDeleteObject
{
    NSUInteger count = 10;
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        for (int64_t i = 0; i < count; i++) {
            [realm addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:i userID:i]]];
        }
    }];
    
    RLMResults *results = [Tweet objectsWhere:@"user.id >= 0"];
    XCTAssertEqual([results count], count);
    
    [self realmWriteTransaction:^(RLMRealm *realm) {
        [realm deleteObjects:[User allObjects]];
    }];
    
    XCTAssertEqual([results count], 0);
}

#pragma mark - Test JsonGenerator

- (void)testURLCount
{
    NSUInteger count = 5;
    [self addOrUpdateTweet:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:INT64_MAX
                                                                                  userID:INT64_MAX
                                                                                urlCount:count]]];
    RLMResults *result = [Tweet allObjects];
    XCTAssertEqual([result count], 1);
    Tweet *tweet = [result firstObject];
    XCTAssertEqual([tweet.entities.urls count], count);
}

#pragma mark - Utility

- (void)addOrUpdateTweet:(Tweet *)tweet
{
    XCTAssertNotNil(tweet);
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:tweet];
    [realm commitWriteTransaction];
    
    int64_t twID = tweet.id;
    XCTAssertEqual([Tweet objectForPrimaryKey:@(twID)].id, tweet.id);
}

- (void)realmWriteTransaction:(void(^)(RLMRealm *realm))transaction
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    if (transaction) transaction(realm);
    [realm commitWriteTransaction];
}

@end
