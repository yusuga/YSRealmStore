//
//  WriteTransactionTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/12/08.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Utility.h"

@interface WriteTransactionTests : XCTestCase

@end

@implementation WriteTransactionTests

- (void)setUp
{
    [super setUp];
    
    [Utility deleteAllObjects];
}

#pragma mark - State

- (void)testStateInWriteTransaction
{
    [[YSRealm sharedInstance] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(realm);
        XCTAssertNotNil(transaction);
        XCTAssertFalse(transaction.isInterrupted);
        XCTAssertTrue(transaction.isExecuting);
        XCTAssertFalse(transaction.isFinished);
    }];
}

- (void)testStateInAsyncWriteTransaction
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [[YSRealm sharedInstance] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(realm);
        XCTAssertNotNil(transaction);
        XCTAssertFalse(transaction.isInterrupted);
        XCTAssertTrue(transaction.isExecuting);
        XCTAssertFalse(transaction.isFinished);
    } completion:^(YSRealmWriteTransaction *transaction) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(transaction);
        XCTAssertFalse(transaction.isInterrupted);
        XCTAssertFalse(transaction.isExecuting);
        XCTAssertTrue(transaction.isFinished);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testStateInInterruptAsyncWriteTransaction
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmWriteTransaction *trans = [[YSRealm sharedInstance] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(realm);
        XCTAssertNotNil(transaction);
        XCTAssertTrue(transaction.isInterrupted);
        XCTAssertTrue(transaction.isExecuting);
        XCTAssertFalse(transaction.isFinished);
    } completion:^(YSRealmWriteTransaction *transaction) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(transaction);
        XCTAssertTrue(transaction.isInterrupted);
        XCTAssertFalse(transaction.isExecuting);
        XCTAssertTrue(transaction.isFinished);
        [expectation fulfill];
    }];
    XCTAssertNotNil(trans);
    [trans interrupt];
    
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
    
    [[YSRealm sharedInstance] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
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
    
    [[YSRealm sharedInstance] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        [realm addObject:[[Tweet alloc] initWithObject:tweetJsonObj]];
    } completion:^(YSRealmWriteTransaction *transaction) {
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
    
    YSRealmWriteTransaction *trans = [[YSRealm sharedInstance] writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(realm);
        XCTAssertNotNil(transaction);
        XCTAssertTrue(transaction.isInterrupted);
        XCTAssertTrue(transaction.isExecuting);
        XCTAssertFalse(transaction.isFinished);
        if (!transaction.isInterrupted) {
            [realm addObject:[[Tweet alloc] initWithObject:tweetJsonObj]];
        }
    } completion:^(YSRealmWriteTransaction *transaction) {
        [expectation fulfill];
    }];
    [trans interrupt];
    
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
}

@end
