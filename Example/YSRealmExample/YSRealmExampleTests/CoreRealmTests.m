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
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    [TwitterRealm addOrUpdateTweet:tweet];
    
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
    XCTAssertEqual([entities.urls count], 3);
    for (Url *url in entities.urls) {
        XCTAssertNotNil(url);
        XCTAssertGreaterThan(url.url.length, 0);
    }
}

- (void)testInsertTweetOfEmptyArray
{
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweetOfContainEmptyArray]];
    [TwitterRealm addOrUpdateTweet:tweet];
    
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
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweetOfContainNSNull]];
    [TwitterRealm addOrUpdateTweet:tweet];
    
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
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweetOfKeyIsNotEnough]];
    [TwitterRealm addOrUpdateTweet:tweet];
    
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
    Tweet *tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    [TwitterRealm addOrUpdateTweet:tweet];
    
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    XCTAssertNotNil(addedTweet);
    
    tweet = [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
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

@end
