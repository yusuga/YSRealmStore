//
//  YSRealmTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TwitterRealmStore.h"

@interface OperationTests : XCTestCase

@end

@implementation OperationTests

- (void)setUp
{
    [super setUp];
    
    [[TwitterRealmStore sharedStore] deleteAllObjects];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - State
#pragma mark Add

- (void)testStateInSyncAdd
{
    [[TwitterRealmStore sharedStore] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertNotNil(realm);
        return nil;
    }];
}

- (void)testStateInAsyncAdd
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertNotNil(realm);
        return nil;
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(store);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertNotNil(realm);
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
    [[TwitterRealmStore sharedStore] deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertNotNil(realm);
        return nil;
    }];
}

- (void)testStateInAsyncDelete
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertNotNil(realm);
        return nil;
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(store);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertNotNil(realm);
        [expectation fulfill];
    }];
    XCTAssertNotNil(ope);
    
    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

#pragma mark Fetch

- (void)testStateInSyncFetch
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    RLMResults *results = [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertNotNil(realm);
        return nil;
    }];
    XCTAssertNil(results);
}

- (void)testStateInAsyncFetch
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertNotNil(realm);
        return nil;
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm, RLMResults *results) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(store);
        XCTAssertNotNil(operation);
        XCTAssertFalse(operation.isCancelled);
        XCTAssertNotNil(realm);
        XCTAssertNil(results);
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
    [[TwitterRealmStore sharedStore] addTweetWithTweetJsonObject:[JsonGenerator tweet]];
}

- (void)testAddObjects
{
    [[TwitterRealmStore sharedStore] addTweetsWithCount:10];
}

- (void)testAsyncAddObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    NSNumber *tweetID = tweetJsonObj[@"id"];
    
    YSRealmOperation *ope = [[TwitterRealmStore sharedStore] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        return [[Tweet alloc] initWithObject:tweetJsonObj];
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        Tweet *tweet = [Tweet objectInRealm:realm forPrimaryKey:tweetID];
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
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [store addTweetWithTweetJsonObject:tweetJsonObj];
    
    [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        Tweet *tweet = [[Tweet allObjectsInRealm:realm] firstObject];
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
        return tweet;
    }];
    
    Tweet *tweet = [[Tweet alloc] initWithObject:tweetJsonObj];
    Tweet *addedTweet = [[Tweet allObjectsInRealm:store.realm] firstObject];
    
    XCTAssertEqual(addedTweet.id, tweet.id);
    XCTAssertEqualObjects(addedTweet.text, @"");
    XCTAssertNil(addedTweet.user);
    XCTAssertNil(addedTweet.entities);
}

- (void)testAsyncUpdateObject
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [store addTweetWithTweetJsonObject:tweetJsonObj];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        RLMResults *results = [Tweet allObjectsInRealm:realm];
        XCTAssertEqual([results count], 1);
        Tweet *tweet = [results firstObject];
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
        return tweet;
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        Tweet *tweet = [[Tweet alloc] initWithObject:tweetJsonObj];
        Tweet *addedTweet = [[Tweet allObjectsInRealm:realm] firstObject];
        
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
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    int64_t tweetID = 0;
    int64_t userID = 0;
    NSMutableDictionary *tweetObj = [JsonGenerator tweetWithTweetID:tweetID userID:userID].mutableCopy;
    
    [store addTweetWithTweetJsonObject:tweetObj];
    XCTAssertNotNil([User objectInRealm:store.realm forPrimaryKey:@(userID)]);
    
    NSMutableDictionary *userObj = ((NSDictionary*)tweetObj[@"user"]).mutableCopy;
    NSString *updatedName = @"UPDATED_NAME";
    XCTAssertFalse([userObj[@"name"] isEqualToString:updatedName]);
    [userObj setObject:updatedName forKey:@"name"];
    [tweetObj setObject:userObj forKey:@"user"];

    [store addTweetWithTweetJsonObject:tweetObj];
    
    XCTAssertEqual([[User allObjectsInRealm:store.realm] count], 1);
    User *user = [User objectInRealm:store.realm forPrimaryKey:@(userID)];
    XCTAssertEqualObjects(user.name, updatedName);
}

#pragma mark Delete

- (void)testDeleteObject
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    [store addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
    [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        return [[Tweet allObjectsInRealm:realm] firstObject];
    }];
    
    XCTAssertEqual([[Tweet allObjectsInRealm:store.realm] count], 0);
}

- (void)testDeleteObjects
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    NSUInteger count = 10;
    [store addTweetsWithCount:count];
    
    [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        return [[Tweet allObjectsInRealm:realm] objectsWithPredicate:[NSPredicate predicateWithFormat:@"id < %d", count/2]];
    }];
    
    XCTAssertEqual([[Tweet allObjectsInRealm:store.realm] count], count/2);
}

- (void)testAsyncDeleteObject
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    [store addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        return [[Tweet allObjectsInRealm:realm] firstObject];
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], 0);
        
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

- (void)testDeleteNestedRelationObjects
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    [store addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:0 userID:0 urlCount:5]];
    
    [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        NSMutableArray *objs = @[].mutableCopy;
        
        Tweet *tweet = [[Tweet allObjectsInRealm:realm] firstObject];
        [objs addObject:tweet];
        if (tweet.entities) {
            [objs addObject:tweet.entities];
            for (Url *url in tweet.entities.urls) {
                [objs addObject:url];
            }
        }
        
        return objs;
    }];
    
    XCTAssertEqual([[Tweet allObjectsInRealm:store.realm] count], 0);
    XCTAssertEqual([[Entities allObjectsInRealm:store.realm] count], 0);
    XCTAssertEqual([[Url allObjectsInRealm:store.realm] count], 0);
}

#pragma mark Fetch

- (void)testFetchObjects
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    NSUInteger count = 10;
    
    [store addTweetsWithCount:count];
    NSString *primaryKey = @"id";
    
    RLMResults *results = [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        RLMResults *tweets = [Tweet allObjectsInRealm:realm];
        return [tweets sortedResultsUsingProperty:primaryKey ascending:YES];
    }];
    
    XCTAssertEqual([results count], count);
    for (NSUInteger i = 0; i < [results count]; i++) {
        XCTAssertEqual(((Tweet*)[results objectAtIndex:i]).id, i);
    }
}

- (void)testAsyncFetchObjects
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    NSUInteger count = 10;
    
    [store addTweetsWithCount:count];
    NSString *primaryKey = @"id";
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        RLMResults *tweets = [Tweet allObjectsInRealm:realm];
        return [tweets sortedResultsUsingProperty:primaryKey ascending:YES];
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm, RLMResults *results) {
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
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    NSUInteger count = 10;
    
    [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
        for (NSUInteger i = 0; i < count; i++) {
            [realm addObject:[[Url alloc] initWithObject:@{@"url" : [NSString stringWithFormat:@"http://%zd.com", i]}]];
        }
    }];
    XCTAssertEqual([[Url allObjectsInRealm:store.realm] count], count);
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        return [Url allObjectsInRealm:realm];
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm, RLMResults *results) {
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
    
    YSRealmOperation *ope = [[TwitterRealmStore sharedStore] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        
        return @[[[Tweet alloc] initWithObject:[JsonGenerator tweet]]];
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        
        XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], 0);
        
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
    
    YSRealmOperation *ope = [[TwitterRealmStore sharedStore] writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        return nil;
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        
        XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], 0);
        
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
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [store addTweetWithTweetJsonObject:tweetJsonObj];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        
        RLMResults *results = [Tweet allObjectsInRealm:realm];
        XCTAssertEqual([results count], 1);
        Tweet *tweet = [results firstObject];
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
        
        return tweet;
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        
        Tweet *tweet = [[Tweet alloc] initWithObject:tweetJsonObj];
        Tweet *addedTweet = [[Tweet allObjectsInRealm:realm] firstObject];
        
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
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    NSDictionary *tweetJsonObj = [JsonGenerator tweet];
    [store addTweetWithTweetJsonObject:tweetJsonObj];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        
        RLMResults *results = [Tweet allObjectsInRealm:realm];
        XCTAssertEqual([results count], 1);
        Tweet *tweet = [results firstObject];
        tweet.text = @"";
        tweet.user = nil;
        tweet.entities = nil;
        
        return nil;
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        
        Tweet *tweet = [[Tweet alloc] initWithObject:tweetJsonObj];
        Tweet *addedTweet = [[Tweet allObjectsInRealm:realm] firstObject];
        
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
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    
    [store addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    
    YSRealmOperation *ope = [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        
        return [Tweet allObjectsInRealm:realm];
    } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertTrue(operation.isCancelled);
        XCTAssertNotNil(realm);
        
        XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], 1);
        
        [expectation fulfill];
    }];
    [ope cancel];

    [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
        XCTAssertNil(error, @"error: %@", error);
    }];
}

@end