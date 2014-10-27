//
//  YSRealmTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "YSRealm.h"
#import "TwitterRealm.h"
#import "JsonGenerator.h"

@interface YSRealmTests : XCTestCase

@end

@implementation YSRealmTests

- (void)setUp
{
    [super setUp];
    [TwitterRealm deleteAllObjects];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Thread

- (void)testStateInAdd
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(operation);
            XCTAssertFalse(operation.isCancelled);
            XCTAssertTrue(operation.isExecuting);
            XCTAssertFalse(operation.isFinished);

            return nil;
        } completion:^(YSRealmOperation *operation) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertNotNil(operation);
            XCTAssertFalse(operation.isCancelled);
            XCTAssertFalse(operation.isExecuting);
            XCTAssertTrue(operation.isFinished);
            
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testStateInUpdate
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YSRealm sharedInstance] updateObjectsWithUpdateBlock:^BOOL(YSRealmOperation *operation) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(operation);
            XCTAssertFalse(operation.isCancelled);
            XCTAssertTrue(operation.isExecuting);
            XCTAssertFalse(operation.isFinished);
            
            return NO;
        } completion:^(YSRealmOperation *operation) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertNotNil(operation);
            XCTAssertFalse(operation.isCancelled);
            XCTAssertFalse(operation.isExecuting);
            XCTAssertTrue(operation.isFinished);
            
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testStateInDelete
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YSRealm sharedInstance] deleteObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(operation);
            XCTAssertFalse(operation.isCancelled);
            XCTAssertTrue(operation.isExecuting);
            XCTAssertFalse(operation.isFinished);
            
            return nil;
        } completion:^(YSRealmOperation *operation) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertNotNil(operation);
            XCTAssertFalse(operation.isCancelled);
            XCTAssertFalse(operation.isExecuting);
            XCTAssertTrue(operation.isFinished);
            
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark - Operation

- (void)testAdd
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [wself addTweetWithTweetJsonObject:[JsonGenerator tweet] completion:^{
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testAddObjects
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [wself addTweetsWithCount:10 completion:^{
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testUpdate
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    __weak typeof(self) wself = self;
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [wself addTweetWithTweetJsonObject:tweetJsonObj completion:^{
            
            [[YSRealm sharedInstance] updateObjectsWithUpdateBlock:^BOOL(YSRealmOperation *operation) {
                XCTAssertEqual([[Tweet allObjects] count], 1);
                Tweet *tweet = [[Tweet allObjects] firstObject];
                tweet.text = @"";
                tweet.user = nil;
                tweet.entities = nil;
                
                return YES;
            } completion:^(YSRealmOperation *operation) {
                Tweet *tweet = [[Tweet alloc] initWithObject:tweetJsonObj];
                Tweet *addedTweet = [[Tweet allObjects] firstObject];
                
                XCTAssertEqual(addedTweet.id, tweet.id);
                XCTAssertEqualObjects(addedTweet.text, @"");
                XCTAssertNil(addedTweet.user);
                XCTAssertNil(addedTweet.entities);
                
                [expectation fulfill];
            }];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testDelete
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [wself addTweetWithTweetJsonObject:[JsonGenerator tweet] completion:^{
            
            [[YSRealm sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
                return [[Tweet allObjects] firstObject];
            } completion:^(YSRealmOperation *operation) {
                XCTAssertEqual([[Tweet allObjects] count], 0);
                
                [expectation fulfill];
            }];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testDeleteObjects
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [wself addTweetsWithCount:10 completion:^{
            
            [[YSRealm sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
                return [Tweet allObjects];
            } completion:^(YSRealmOperation *operation) {
                XCTAssertEqual([[Tweet allObjects] count], 0);
                
                [expectation fulfill];
            }];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark - Cancel

- (void)testCancelAdd
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YSRealmOperation *ope = [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
            XCTAssertTrue(operation.isCancelled);
            XCTAssertTrue(operation.isExecuting);
            XCTAssertFalse(operation.isFinished);
            
            return @[[[Tweet alloc] initWithObject:[JsonGenerator tweet]]];
        } completion:^(YSRealmOperation *operation) {
            XCTAssertTrue(operation.isCancelled);
            XCTAssertFalse(operation.isExecuting);
            XCTAssertTrue(operation.isFinished);
            
            XCTAssertEqual([[Tweet allObjects] count], 0);
            
            [expectation fulfill];
        }];
        
        [ope cancel];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testCancelUpdate
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
            return @[[[Tweet alloc] initWithObject:tweetJsonObj]];
        } completion:^(YSRealmOperation *operation) {
            
            YSRealmOperation *ope = [[YSRealm sharedInstance] updateObjectsWithUpdateBlock:^BOOL(YSRealmOperation *operation) {
                XCTAssertTrue(operation.isCancelled);
                XCTAssertTrue(operation.isExecuting);
                XCTAssertFalse(operation.isFinished);
                
                XCTAssertEqual([[Tweet allObjects] count], 1);
                Tweet *tweet = [[Tweet allObjects] firstObject];
                tweet.text = @"";
                tweet.user = nil;
                tweet.entities = nil;
                
                return YES;
            } completion:^(YSRealmOperation *operation) {
                XCTAssertTrue(operation.isCancelled);
                XCTAssertFalse(operation.isExecuting);
                XCTAssertTrue(operation.isFinished);
                
                Tweet *tweet = [[Tweet alloc] initWithObject:tweetJsonObj];
                Tweet *addedTweet = [[Tweet allObjects] firstObject];
                
                XCTAssertEqual(addedTweet.id, tweet.id);
                XCTAssertEqualObjects(addedTweet.text, tweet.text);
                XCTAssertNotNil(addedTweet.user);
                XCTAssertNotNil(addedTweet.entities);
                
                [expectation fulfill];
            }];
            
            [ope cancel];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testCancelDelete
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
            return @[[[Tweet alloc] initWithObject:[JsonGenerator tweet]]];
        } completion:^(YSRealmOperation *operation) {
            
            YSRealmOperation *ope = [[YSRealm sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
                XCTAssertTrue(operation.isCancelled);
                XCTAssertTrue(operation.isExecuting);
                XCTAssertFalse(operation.isFinished);
                
                return [Tweet allObjects];
            } completion:^(YSRealmOperation *operation) {
                XCTAssertTrue(operation.isCancelled);
                XCTAssertFalse(operation.isExecuting);
                XCTAssertTrue(operation.isFinished);
                
                XCTAssertEqual([[Tweet allObjects] count], 1);
                
                [expectation fulfill];
            }];
            
            [ope cancel];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark - Utility

- (void)addTweetWithTweetJsonObject:(NSDictionary*)tweetJsonObject completion:(void(^)(void))completion
{
    [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet alloc] initWithObject:tweetJsonObject];
    } completion:^(YSRealmOperation *operation) {
        XCTAssertEqual([[Tweet allObjects] count], 1);
        completion();
    }];
}

- (void)addTweetsWithCount:(NSUInteger)count completion:(void(^)(void))completion
{
    [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger id = 0; id < count; id++) {
            [tweets addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithID:id]]];
        }
        return tweets;
    } completion:^(YSRealmOperation *operation) {
        XCTAssertEqual([[Tweet allObjects] count], count);
        completion();
    }];
}

@end
