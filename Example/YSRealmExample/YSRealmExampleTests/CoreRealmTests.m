//
//  CoreRealmTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Utility.h"

@interface CoreRealmTests : XCTestCase

@end

@implementation CoreRealmTests

- (void)setUp
{
    [super setUp];
    
    [Utility deleteAllObjects];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInsertTweet
{
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
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
    [Utility addTweetsWithCount:count];
    
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
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetOfContainEmptyArray]];
    
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
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetOfContainNSNull]];
    
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
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetOfKeyIsNotEnough]];
    
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
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
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

- (void)testEqual
{
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    [self addOrUpdateTweet:tweet];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    
    XCTAssertEqualObjects(tweet, addedTweet);
}

- (void)testUpdate
{
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    [self addOrUpdateTweet:tweet];
    
    [self updateObject:^{
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

- (void)testCancelAdd
{
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:tweet];
    [realm cancelWriteTransaction];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
}

- (void)testCancelUpdate
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

- (void)testCancelDelete
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
    [Utility addTweetsWithCount:10];
    [self addOrUpdateTweet:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithID:INT64_MAX]]];
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"id = %@", @(INT64_MAX)]];
    XCTAssertEqual([results count], 1);
    Tweet *tweet = [results firstObject];
    XCTAssertEqual(tweet.id, INT64_MAX);
}

- (void)testFetchTweetWithUserID
{
    [Utility addTweetsWithCount:10];
    
    int64_t id = 5;
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"user.id = %@", @(id)]];
    XCTAssertEqual([results count], 1);
    Tweet *tweet = [results firstObject];
    XCTAssertEqual(tweet.id, id);
    XCTAssertEqual(tweet.user.id, id);
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

- (void)testToManyWithCount
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

#pragma mark - Test

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

- (void)updateObject:(void(^)(void))updating
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    if (updating) updating();
    [realm commitWriteTransaction];
}

@end
