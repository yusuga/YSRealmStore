//
//  WriteTransactionTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/12/08.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TwitterRealmStore.h"

@interface WriteTransactionTests : XCTestCase

@end

@implementation WriteTransactionTests

- (void)setUp
{
    [super setUp];
    
    [[TwitterRealmStore sharedStore] deleteAllObjects];
}

#pragma mark - State

- (void)testStateInWriteTransaction
{
    [[[YSRealmStore alloc] init] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(realm);
        XCTAssertNotNil(transaction);
        XCTAssertFalse(transaction.isInterrupted);
    }];
}

- (void)testStateInAsyncWriteTransaction
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmStore *store = [[YSRealmStore alloc] init];
    
    [store writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(realm);
        XCTAssertNotNil(transaction);
        XCTAssertFalse(transaction.isInterrupted);
    } completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(store);
        XCTAssertNotNil(transaction);
        XCTAssertFalse(transaction.isInterrupted);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testStateInInterruptAsyncWriteTransaction
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmWriteTransaction *trans = [[[YSRealmStore alloc] init] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(realm);
        XCTAssertNotNil(transaction);
        XCTAssertTrue(transaction.isInterrupted);
    } completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(transaction);
        XCTAssertTrue(transaction.isInterrupted);
        [expectation fulfill];
    }];
    XCTAssertNotNil(trans);
    [trans interrupt];
    
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testStateInAsyncDeleteAllObjects
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [[TwitterRealmStore sharedStore] deleteAllObjectsWithCompletion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(store);
        XCTAssertNotNil(transaction);
        XCTAssertFalse(transaction.interrupted);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark - Transaction

- (void)testWriteTransaction
{
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    NSNumber *tweetID = tweetJsonObj[@"id"];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
    
    [[[YSRealmStore alloc] init] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        [realm addObject:[[Tweet alloc] initWithObject:tweetJsonObj]];
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 1);
    
    Tweet *tweet = [Tweet objectForPrimaryKey:tweetID];
    XCTAssertNotNil(tweet);
}

- (void)testAsyncWriteTransaction
{
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    NSNumber *tweetID = tweetJsonObj[@"id"];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [[[YSRealmStore alloc] init] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        [realm addObject:[[Tweet alloc] initWithObject:tweetJsonObj]];
    } completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction) {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 1);
    
    Tweet *tweet = [Tweet objectForPrimaryKey:tweetID];
    XCTAssertNotNil(tweet);
}

#pragma mark - Interrupt

- (void)testInterruptAsyncWriteTransaction
{
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmWriteTransaction *trans = [[[YSRealmStore alloc] init] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(realm);
        XCTAssertNotNil(transaction);
        XCTAssertTrue(transaction.isInterrupted);
        if (!transaction.isInterrupted) {
            [realm addObject:[[Tweet alloc] initWithObject:tweetJsonObj]];
        }
    } completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction) {
        [expectation fulfill];
    }];
    [trans interrupt];
    
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
}

#pragma mark - Delete

- (void)testDeleteAllObjects
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    NSUInteger count = 10;
    [store addTweetsWithCount:count];
    XCTAssertEqual([[Tweet allObjects] count], count);
    
    [store deleteAllObjects];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
}

- (void)testAsyncDeleteAllObjects
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    NSUInteger count = 10;
    [store addTweetsWithCount:count];
    XCTAssertEqual([[Tweet allObjects] count], count);
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [store deleteAllObjectsWithCompletion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction) {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
}

@end
