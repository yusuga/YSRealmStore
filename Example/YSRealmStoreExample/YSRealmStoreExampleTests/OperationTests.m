//
//  YSRealmTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Utility.h"

@interface OperationTests : XCTestCase

@end

@implementation OperationTests

- (void)setUp
{
    [super setUp];
    
    [Utility deleteAllObjects];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - State
#pragma mark Add

- (void)testStateInSyncAdd
{
    [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
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
    
    YSRealmOperation *ope = [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
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
    XCTAssertNotNil(ope);
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark Delete

- (void)testStateInSyncDelete
{
    [[YSRealmStore sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
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
    
    YSRealmOperation *ope = [[YSRealmStore sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
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
    XCTAssertNotNil(ope);
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark Fetch

- (void)testStateInAsyncFetch
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [[YSRealmStore sharedInstance] fetchObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertTrue(operation.isExecuting);
        XCTAssertFalse(operation.isFinished);
        
        return nil;
    } completion:^(YSRealmOperation *operation, RLMResults *results) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertFalse(operation.isExecuting);
        XCTAssertTrue(operation.isFinished);
        
        [expectation fulfill];
    }];
    XCTAssertNotNil(ope);
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark - Operation
#pragma mark Add

- (void)testAddObject
{
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweet]];
}

- (void)testAddObjects
{
    [Utility addTweetsWithCount:10];
}

- (void)testAsyncAddObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    NSNumber *tweetID = tweetJsonObj[@"id"];
    
    YSRealmOperation *ope = [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet alloc] initWithObject:tweetJsonObj];
    } completion:^(YSRealmOperation *operation) {
        Tweet *tweet = [Tweet objectForPrimaryKey:tweetID];
        XCTAssertNotNil(tweet);
        [expectation fulfill];
    }];
    XCTAssertNotNil(ope);
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark Update

- (void)testUpdateObject
{
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [Utility addTweetWithTweetJsonObject:tweetJsonObj];
    
    [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        Tweet *tweet = [[Tweet allObjects] firstObject];
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
        return tweet;
    }];
    
    Tweet *tweet = [[Tweet alloc] initWithObject:tweetJsonObj];
    Tweet *addedTweet = [[Tweet allObjects] firstObject];
    
    XCTAssertEqual(addedTweet.id, tweet.id);
    XCTAssertEqualObjects(addedTweet.text, @"");
    XCTAssertNil(addedTweet.user);
    XCTAssertNil(addedTweet.entities);
}

- (void)testAsyncUpdateObject
{
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [Utility addTweetWithTweetJsonObject:tweetJsonObj];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        XCTAssertEqual([[Tweet allObjects] count], 1);
        Tweet *tweet = [[Tweet allObjects] firstObject];
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
        return tweet;
    } completion:^(YSRealmOperation *operation) {
        Tweet *tweet = [[Tweet alloc] initWithObject:tweetJsonObj];
        Tweet *addedTweet = [[Tweet allObjects] firstObject];
        
        XCTAssertEqual(addedTweet.id, tweet.id);
        XCTAssertEqualObjects(addedTweet.text, @"");
        XCTAssertNil(addedTweet.user);
        XCTAssertNil(addedTweet.entities);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testUpdateNestedObject
{
    int64_t tweetID = 0;
    int64_t userID = 0;
    NSMutableDictionary *tweetObj = [JsonGenerator tweetWithTweetID:tweetID userID:userID].mutableCopy;
    
    [Utility addTweetWithTweetJsonObject:tweetObj];
    XCTAssertNotNil([User objectForPrimaryKey:@(userID)]);
    
    NSMutableDictionary *userObj = ((NSDictionary*)tweetObj[@"user"]).mutableCopy;
    NSString *updatedName = @"UPDATED_NAME";
    XCTAssertFalse([userObj[@"name"] isEqualToString:updatedName]);
    [userObj setObject:updatedName forKey:@"name"];
    [tweetObj setObject:userObj forKey:@"user"];

    [Utility addTweetWithTweetJsonObject:tweetObj];
    
    XCTAssertEqual([[User allObjects] count], 1);
    User *user = [User objectForPrimaryKey:@(userID)];
    XCTAssertEqualObjects(user.name, updatedName);
}

#pragma mark Delete

- (void)testDeleteObject
{
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
    [[YSRealmStore sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet allObjects] firstObject];
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
}

- (void)testDeleteObjects
{
    NSUInteger count = 10;
    [Utility addTweetsWithCount:count];
    
    [[YSRealmStore sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet allObjects] objectsWithPredicate:[NSPredicate predicateWithFormat:@"id < %d", count/2]];
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], count/2);
}

- (void)testAsyncDeleteObject
{
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [[YSRealmStore sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [[Tweet allObjects] firstObject];
    } completion:^(YSRealmOperation *operation) {
        XCTAssertEqual([[Tweet allObjects] count], 0);
        
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testDeleteNestedRelationObjects
{
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:0 userID:0 urlCount:5]];
    
    [[YSRealmStore sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        NSMutableArray *objs = @[].mutableCopy;
        
        Tweet *tweet = [[Tweet allObjects] firstObject];
        [objs addObject:tweet];
        if (tweet.entities) {
            [objs addObject:tweet.entities];
            for (Url *url in tweet.entities.urls) {
                [objs addObject:url];
            }
        }
        
        return objs;
    }];
    
    XCTAssertEqual([[Tweet allObjects] count], 0);
    XCTAssertEqual([[Entities allObjects] count], 0);
    XCTAssertEqual([[Url allObjects] count], 0);
}

#pragma mark Fetch

- (void)testAsyncFetchObjects
{
    NSUInteger count = 10;
    [Utility addTweetsWithCount:count];
    NSString *primaryKey = @"id";
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [[YSRealmStore sharedInstance] fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        RLMResults *tweets = [Tweet allObjects];
        return [tweets sortedResultsUsingProperty:primaryKey ascending:YES];
    } completion:^(YSRealmOperation *operation, RLMResults *results) {
        XCTAssertEqual([results count], count);
        for (NSUInteger i = 0; i < [results count]; i++) {
            XCTAssertEqual(((Tweet*)[results objectAtIndex:i]).id, i);
        }        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testAsyncFetchObjectsWitchDontHavePrimaryKey
{
    YSRealmStore *ysRealm = [YSRealmStore sharedInstance];
    NSUInteger count = 10;
    
    [ysRealm writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        for (NSUInteger i = 0; i < count; i++) {
            [realm addObject:[[Url alloc] initWithObject:@{@"url" : [NSString stringWithFormat:@"http://%zd.com", i]}]];
        }
    }];
    XCTAssertEqual([[Url allObjects] count], count);
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    [ysRealm fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        return [Url allObjects];
    } completion:^(YSRealmOperation *operation, RLMResults *results) {
        XCTAssertNil(results);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark - Cancel
#pragma mark Add

- (void)testCancelAddObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
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

    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testCancelWriteWithNotReturnObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^NSArray *(YSRealmOperation *operation) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isExecuting);
        XCTAssertFalse(operation.isFinished);
        
        return nil;
    } completion:^(YSRealmOperation *operation) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertFalse(operation.isExecuting);
        XCTAssertTrue(operation.isFinished);
        
        XCTAssertEqual([[Tweet allObjects] count], 0);
        
        [expectation fulfill];
    }];
    [ope cancel];
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark Update

- (void)testCancelUpdateObject
{
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [Utility addTweetWithTweetJsonObject:tweetJsonObj];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isExecuting);
        XCTAssertFalse(operation.isFinished);
        
        XCTAssertEqual([[Tweet allObjects] count], 1);
        Tweet *tweet = [[Tweet allObjects] firstObject];
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
        
        return tweet;
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
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testCancelUpdateObjectWithNotReturnObject
{
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [Utility addTweetWithTweetJsonObject:tweetJsonObj];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [[YSRealmStore sharedInstance] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isExecuting);
        XCTAssertFalse(operation.isFinished);
        
        XCTAssertEqual([[Tweet allObjects] count], 1);
        Tweet *tweet = [[Tweet allObjects] firstObject];
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
        
        return nil;
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
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark Delete

- (void)testCancelDeleteObject
{
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [[YSRealmStore sharedInstance] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation) {
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

    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

@end
