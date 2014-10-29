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
#pragma mark Add

- (void)testStateInSyncAdd
{
    [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertTrue(operation.isExecuting);
        XCTAssertFalse(operation.isFinished);
        
        return nil;
    }];
}

- (void)testStateInAsyncAdd
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

#pragma mark Update

- (void)testStateInSycnUpdate
{
    [[YSRealm sharedInstance] updateObjectsWithUpdateBlock:^BOOL(YSRealmOperation *operation) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertTrue(operation.isExecuting);
        XCTAssertFalse(operation.isFinished);
        
        return NO;
    }];
}

- (void)testStateInAsyncUpdate
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

#pragma mark Delete

- (void)testStateInSyncDelete
{
    [[YSRealm sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertTrue(operation.isExecuting);
        XCTAssertFalse(operation.isFinished);
        
        return nil;
    }];
}

- (void)testStateInAsyncDelete
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
#pragma mark Add

- (void)testSyncAdd
{
    [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 1);
}

- (void)testAsyncAdd
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

- (void)testAsyncAddObjects
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

#pragma mark Update

- (void)testSyncUpdate
{
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet alloc] initWithObject:tweetJsonObj];
    }];
    
    [[YSRealm sharedInstance] updateObjectsWithUpdateBlock:^BOOL(YSRealmOperation *operation) {
        Tweet *tweet = [[Tweet allObjects] firstObject];
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
        
        return YES;
    }];
    
    Tweet *tweet = [[Tweet alloc] initWithObject:tweetJsonObj];
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    
    XCTAssertEqual(addedTweet.id, tweet.id);
    XCTAssertEqualObjects(addedTweet.text, @"");
    XCTAssertNil(addedTweet.user);
    XCTAssertNil(addedTweet.entities);
}

- (void)testAsyncUpdate
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

#pragma mark Delete

- (void)testSyncDelete
{
    [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet alloc] initWithObject:[JsonGenerator tweet]];
    }];
    
    [[YSRealm sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet allObjects] firstObject];
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
}

- (void)testAsyncDelete
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
#pragma mark Add

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

- (void)testCancelAdd1000Tweets
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
            XCTAssertFalse(operation.isCancelled);
            XCTAssertTrue(operation.isExecuting);
            XCTAssertFalse(operation.isFinished);
            
            DDLogWarn(@"will create tweets");
            NSUInteger count = 1000;
            NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:count];
            for (NSUInteger i = 0; i < count; i++) {
                [tweets addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithID:i]]];
            }
            DDLogWarn(@"did create tweets");
            
            [wself cancelOperation:operation afterDelay:0.01];
            
            return tweets;
        } completion:^(YSRealmOperation *operation) {
            XCTAssertTrue(operation.isCancelled);
            XCTAssertFalse(operation.isExecuting);
            XCTAssertTrue(operation.isFinished);
            
            XCTAssertEqual([[Tweet allObjects] count], 0);
            
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:100. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testCancelAdd10000Tweets
{
#if TARGET_IPHONE_SIMULATOR
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YSRealm sharedInstance] addObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
            XCTAssertFalse(operation.isCancelled);
            XCTAssertTrue(operation.isExecuting);
            XCTAssertFalse(operation.isFinished);
            
            DDLogWarn(@"will create tweets");
            NSUInteger count = 10000;
            NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:count];
            for (NSUInteger i = 0; i < count; i++) {
                [tweets addObject:[[Tweet alloc] initWithObject:[JsonGenerator tweetWithID:i]]];
            }
            DDLogWarn(@"did create tweets");
            
            [wself cancelOperation:operation afterDelay:0.01];
            
            return tweets;
        } completion:^(YSRealmOperation *operation) {
            XCTAssertTrue(operation.isCancelled);
            XCTAssertFalse(operation.isExecuting);
            XCTAssertTrue(operation.isFinished);
            
            XCTAssertEqual([[Tweet allObjects] count], 0);
            
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:30. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
#endif
}

#pragma mark Update

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

- (void)testCancelUpdate1000Tweets
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [wself addTweetsWithCount:1000 completion:^{
            [[YSRealm sharedInstance] updateObjectsWithUpdateBlock:^BOOL(YSRealmOperation *operation) {
                XCTAssertFalse(operation.isCancelled);
                XCTAssertTrue(operation.isExecuting);
                XCTAssertFalse(operation.isFinished);
                
                DDLogWarn(@"will forin all tweets");
                for (Tweet *tweet in [Tweet allObjects]) {
                    tweet.text = @"";
                    tweet.user = nil;
                    tweet.entities = nil;
                }
                DDLogWarn(@"did forin all tweets");
                
                [operation cancel];
                
                return YES;
            } completion:^(YSRealmOperation *operation) {
                XCTAssertTrue(operation.isCancelled);
                XCTAssertFalse(operation.isExecuting);
                XCTAssertTrue(operation.isFinished);
                
                for (Tweet *tweet in [Tweet allObjects]) {
                    XCTAssertGreaterThan(tweet.text.length, 0);
                    XCTAssertNotNil(tweet.user);
                    XCTAssertNotNil(tweet.entities);
                }
                
                [expectation fulfill];
            }];
        }];
    });
    
    [self waitForExpectationsWithTimeout:30. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark Delete

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

- (void)testCancelDelete10000Tweets
{
#if TARGET_IPHONE_SIMULATOR
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger count = 100000;
        
        [wself addTweetsWithCount:count completion:^{
            [[YSRealm sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
                XCTAssertFalse(operation.isCancelled);
                XCTAssertTrue(operation.isExecuting);
                XCTAssertFalse(operation.isFinished);
                
                RLMResults *tweets = [Tweet allObjects];
                [wself cancelOperation:operation afterDelay:0.001];
                
                return tweets;
            } completion:^(YSRealmOperation *operation) {
                XCTAssertTrue(operation.isCancelled);
                XCTAssertFalse(operation.isExecuting);
                XCTAssertTrue(operation.isFinished);
                
                XCTAssertEqual([[Tweet allObjects] count], count);
                
                [expectation fulfill];
            }];
        }];
    });
    
    [self waitForExpectationsWithTimeout:30. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
#endif
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

- (void)cancelOperation:(YSRealmOperation*)operation afterDelay:(NSTimeInterval)delay
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:delay];
        dispatch_async(dispatch_get_main_queue(), ^{
            [operation cancel];
            DDLogWarn(@"Cancel operation: %@", operation);
        });
    });
}

@end
