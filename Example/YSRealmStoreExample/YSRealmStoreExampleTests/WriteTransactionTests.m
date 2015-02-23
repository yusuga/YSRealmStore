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
    
    [[TwitterRealmStore sharedStore] deleteAllObjects];
}

#pragma mark - State

- (void)testStateInWriteTransaction
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) {
            [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
                XCTAssertTrue([NSThread isMainThread]);
                XCTAssertNotNil(transaction);
                XCTAssertFalse(transaction.isInterrupted);
                XCTAssertNotNil(realm);
            }];
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:nil];
            [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
                XCTAssertFalse([NSThread isMainThread]);
                XCTAssertNotNil(transaction);
                XCTAssertFalse(transaction.isInterrupted);
                XCTAssertNotNil(realm);
            } completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction, RLMRealm *realm) {
                XCTAssertTrue([NSThread isMainThread]);
                XCTAssertNotNil(store);
                XCTAssertNotNil(transaction);
                XCTAssertFalse(transaction.isInterrupted);
                XCTAssertNotNil(realm);
                [expectation fulfill];
            }];
            [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
                XCTAssertNil(error, @"error: %@", error);
            }];
        }
    }];
}

- (void)testStateInInterruptWriteTransaction
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) return ;

        XCTestExpectation *expectation = [self expectationWithDescription:nil];
        
        YSRealmWriteTransaction *trans = [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(transaction);
            XCTAssertTrue(transaction.isInterrupted);
            XCTAssertNotNil(realm);
        } completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertNotNil(transaction);
            XCTAssertTrue(transaction.isInterrupted);
            XCTAssertNotNil(realm);
            [expectation fulfill];
        }];
        XCTAssertNotNil(trans);
        [trans interrupt];
        
        [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }];
}

- (void)testStateInAsyncDeleteAllObjects
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) return ;
        
        XCTestExpectation *expectation = [self expectationWithDescription:nil];
        
        [store deleteAllObjectsWithCompletion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertNotNil(store);
            XCTAssertNotNil(transaction);
            XCTAssertFalse(transaction.interrupted);
            XCTAssertNotNil(realm);
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }];
}

#pragma mark - Transaction

- (void)testWriteTransaction
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        NSDictionary *tweetJsonObj = [JsonGenerator tweet];
        NSNumber *tweetID = tweetJsonObj[@"id"];
        
        XCTAssertEqual([[Tweet allObjectsInRealm:[store realm]] count], 0);
        
        if (sync) {
            [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
                [realm addObject:[[Tweet alloc] initWithObject:tweetJsonObj]];
            }];            
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:nil];
            
            [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
                [realm addObject:[[Tweet alloc] initWithObject:tweetJsonObj]];
            } completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction, RLMRealm *realm) {
                [expectation fulfill];
            }];
            
            [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
                XCTAssertNil(error, @"error: %@", error);
            }];
        }
        
        NSLog(@"> %zd", [[Tweet allObjectsInRealm:[store realm]] count]);
        XCTAssertEqual([[Tweet allObjectsInRealm:[store realm]] count], 1);
        
        Tweet *tweet = [Tweet objectInRealm:[store realm] forPrimaryKey:tweetID];
        XCTAssertNotNil(tweet);
    }];    
}

#pragma mark - Interrupt

- (void)testInterruptAsyncWriteTransaction
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) return ;
        
        NSDictionary *tweetJsonObj = [JsonGenerator tweet];
        
        XCTAssertEqual([[Tweet allObjectsInRealm:[store realm]] count], 0);
        
        XCTestExpectation *expectation = [self expectationWithDescription:nil];
        
        YSRealmWriteTransaction *trans = [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(transaction);
            XCTAssertTrue(transaction.isInterrupted);
            XCTAssertNotNil(realm);
            
            if (!transaction.isInterrupted) {
                [realm addObject:[[Tweet alloc] initWithObject:tweetJsonObj]];
            }
        } completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertNotNil(transaction);
            XCTAssertTrue(transaction.isInterrupted);
            XCTAssertNotNil(realm);
            [expectation fulfill];
        }];
        [trans interrupt];
        
        [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
        
        XCTAssertEqual([[Tweet allObjectsInRealm:[store realm]] count], 0);
    }];
}

#pragma mark - Delete

- (void)testDeleteAllObjects
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        NSUInteger count = 10;
        
        [store addTweetsWithCount:count];
        XCTAssertEqual([[Tweet allObjectsInRealm:[store realm]] count], count);
        
        if (sync) {
            [store deleteAllObjects];
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:nil];
            [store deleteAllObjectsWithCompletion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction, RLMRealm *realm) {
                [expectation fulfill];
            }];
            [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
                XCTAssertNil(error, @"error: %@", error);
            }];
        }
        
        XCTAssertEqual([[Tweet allObjectsInRealm:[store realm]] count], 0);
    }];
}

@end
