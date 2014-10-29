//
//  CoreRealmTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TwitterRealm.h"
#import "JsonGenerator.h"

@interface CoreRealmTests : XCTestCase

@end

@implementation CoreRealmTests

- (void)setUp
{
    [super setUp];
    [TwitterRealm deleteAllObjects];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInsertTweet
{
    [self addTweetWithObject:[JsonGenerator tweet]];
    
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
    [self addSampleTweetsWithCount:count];
    
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
    [self addTweetWithObject:[JsonGenerator tweetOfContainEmptyArray]];
    
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
    [self addTweetWithObject:[JsonGenerator tweetOfContainNSNull]];
    
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
    [self addTweetWithObject:[JsonGenerator tweetOfKeyIsNotEnough]];
    
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
    [self addTweetWithObject:[JsonGenerator tweet]];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertNotNil(addedTweet);
    
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    tweet.text = @"";
    tweet.user = nil;
    tweet.entities = nil;
    [TwitterRealm addOrUpdateTweet:tweet];
    
    XCTAssertEqual([[Tweet allObjects] count], 1);
    addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertEqualObjects(addedTweet.text, @"");
    XCTAssertNil(tweet.user);
    XCTAssertNil(tweet.entities);
}

- (void)testEqual
{
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    [TwitterRealm addOrUpdateTweet:tweet];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    
    XCTAssertEqualObjects(tweet, addedTweet);
}

- (void)testUpdate
{
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    [TwitterRealm addOrUpdateTweet:tweet];
    
    [TwitterRealm updateTweet:^{
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

#pragma mark - Query

- (void)testPredicateWithInt64Max
{
    [self addSampleTweetsWithCount:10];
    [TwitterRealm addOrUpdateTweet:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithID:INT64_MAX]]];
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"id = %@", @(INT64_MAX)]];
    XCTAssertEqual([results count], 1);
    Tweet *tweet = [results firstObject];
    XCTAssertEqual(tweet.id, INT64_MAX);
}

- (void)testFetchTweetWithUserID
{
    [self addSampleTweetsWithCount:10];
    
    int64_t id = 5;
    
    RLMResults *results = [Tweet objectsWithPredicate:[NSPredicate predicateWithFormat:@"user.id = %@", @(id)]];
    XCTAssertEqual([results count], 1);
    Tweet *tweet = [results firstObject];
    XCTAssertEqual(tweet.id, id);
    XCTAssertEqual(tweet.user.id, id);
}

- (void)testToManyWithBEGINSWITH
{
#warning Unsupported 0.87.1
#if 0
    for (NSUInteger i = 0; i < 10; i++) {
        [self addTweetWithObject:[JsonGenerator tweetWithTweetID:i userID:i urlCount:0]];
    }
    
    int64_t id = INT64_MAX;
    NSUInteger urlCount = 3;
    [self addTweetWithObject:[JsonGenerator tweetWithTweetID:id userID:id urlCount:urlCount]];
    
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
#warning Unsupported 0.87.1
#if 0
    for (NSUInteger i = 0; i < 10; i++) {
        [self addTweetWithObject:[JsonGenerator tweetWithTweetID:i userID:i urlCount:0]];
    }
    
    int64_t id = INT64_MAX;
    NSUInteger urlCount = 3;
    [self addTweetWithObject:[JsonGenerator tweetWithTweetID:id userID:id urlCount:urlCount]];
    
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

#pragma mark - Utility

- (void)addTweetWithObject:(NSDictionary*)object
{
    [TwitterRealm addOrUpdateTweet:[[Tweet alloc] initWithObject:object]];
}

- (void)addSampleTweetsWithCount:(NSUInteger)count
{
    for (NSUInteger id = 0; id < count; id++) {
        Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:id userID:id]];
        [TwitterRealm addOrUpdateTweet:tweet];
    }
}

#pragma mark Test

- (void)testURLCount
{
    NSUInteger count = 5;
    [TwitterRealm addOrUpdateTweet:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithTweetID:INT64_MAX
                                                                                          userID:INT64_MAX
                                                                                        urlCount:count]]];
    RLMResults *result = [Tweet allObjects];
    XCTAssertEqual([result count], 1);
    Tweet *tweet = [result firstObject];
    XCTAssertEqual([tweet.entities.urls count], count);
}

@end
