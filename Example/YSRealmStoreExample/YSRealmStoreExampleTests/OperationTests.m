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
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) {
            [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                XCTAssertTrue([NSThread isMainThread]);
                XCTAssertNotNil(operation);
                XCTAssertFalse(operation.isCancelled);
                XCTAssertNotNil(realm);
                return nil;
            }];
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
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
    }];
}

#pragma mark Delete

- (void)testStateInSyncDelete
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) {
            [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                XCTAssertTrue([NSThread isMainThread]);
                XCTAssertNotNil(operation);
                XCTAssertFalse(operation.isCancelled);
                XCTAssertNotNil(realm);
                return nil;
            }];
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
            
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
    }];
}

#pragma mark Fetch

- (void)testStateInSyncFetch
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) {
            RLMResults *results = [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                XCTAssertTrue([NSThread isMainThread]);
                XCTAssertNotNil(operation);
                XCTAssertFalse(operation.isCancelled);
                XCTAssertNotNil(realm);
                return nil;
            }];
            XCTAssertNil(results);
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
            
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
    }];
}

#pragma mark - Operation
#pragma mark Add

- (void)testAddObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (!sync) return ;
        [store addTweetWithTweetJsonObject:[JsonGenerator tweet]];
    }];
}

- (void)testAddObjects
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (!sync) return ;
        [store addTweetsWithCount:10];
    }];
}

- (void)testAsyncAddObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) return ;
        
        XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
        
        NSDictionary *tweetJsonObj = [JsonGenerator tweet];
        NSNumber *tweetID = tweetJsonObj[@"id"];
        
        YSRealmOperation *ope = [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
            return [[Tweet alloc] initWithValue:tweetJsonObj];
        } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
            Tweet *tweet = [Tweet objectInRealm:realm forPrimaryKey:tweetID];
            XCTAssertNotNil(tweet);
            [expectation fulfill];
        }];
        XCTAssertNotNil(ope);
        
        [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }];
}

#pragma mark Update

- (void)testUpdateObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        NSDictionary *tweetJsonObj = [JsonGenerator tweet];
        int64_t tweetID = [tweetJsonObj[@"id"] longLongValue];
        XCTAssertGreaterThan(tweetID, 0);
        [store addTweetWithTweetJsonObject:tweetJsonObj];
        
        Tweet*(^updateTweet)(RLMRealm *realm) = ^Tweet*(RLMRealm *realm) {
            Tweet *tweet = [Tweet objectInRealm:realm forPrimaryKey:@(tweetID)];
            tweet.text = @"";
            tweet.user = nil;
            tweet.entities = nil;
            return tweet;
        };
        
        if (sync) {
            [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                return updateTweet(realm);
            }];
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
            [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                return updateTweet(realm);
            } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
                [expectation fulfill];
            }];
            [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
                XCTAssertNil(error, @"error: %@", error);
            }];
        }
        
        Tweet *tweet = [Tweet objectInRealm:[store realm] forPrimaryKey:@(tweetID)];
        XCTAssertEqual(tweet.id, tweetID);
        XCTAssertEqualObjects(tweet.text, @"");
        XCTAssertNil(tweet.user);
        XCTAssertNil(tweet.entities);
    }];
}

- (void)testUpdateNestedObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (!sync) return ;
        
        int64_t tweetID = 0;
        int64_t userID = 0;
        NSMutableDictionary *tweetObj = [JsonGenerator tweetWithTweetID:tweetID userID:userID].mutableCopy;
        
        [store addTweetWithTweetJsonObject:tweetObj];
        XCTAssertNotNil([User objectInRealm:[store realm] forPrimaryKey:@(userID)]);
        
        NSMutableDictionary *userObj = ((NSDictionary*)tweetObj[@"user"]).mutableCopy;
        NSString *updatedName = @"UPDATED_NAME";
        XCTAssertFalse([userObj[@"name"] isEqualToString:updatedName]);
        [userObj setObject:updatedName forKey:@"name"];
        [tweetObj setObject:userObj forKey:@"user"];
        
        [store addTweetWithTweetJsonObject:tweetObj];
        
        XCTAssertEqual([[User allObjectsInRealm:[store realm]] count], 1);
        User *user = [User objectInRealm:[store realm] forPrimaryKey:@(userID)];
        XCTAssertEqualObjects(user.name, updatedName);
    }];
}

#pragma mark Delete

- (void)testDeleteObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (!sync) return ;
        
        [store addTweetWithTweetJsonObject:[JsonGenerator tweet]];
        
        [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
            return [[Tweet allObjectsInRealm:realm] firstObject];
        }];
        
        XCTAssertEqual([[Tweet allObjectsInRealm:[store realm]] count], 0);
    }];
}

- (void)testDeleteObjects
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        NSUInteger count = 10;
        [store addTweetsWithCount:count];
        
        if (sync) {
            [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                return [[Tweet allObjectsInRealm:realm] objectsWithPredicate:[NSPredicate predicateWithFormat:@"id < %d", count/2]];
            }];
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
            [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                return [[Tweet allObjectsInRealm:realm] objectsWithPredicate:[NSPredicate predicateWithFormat:@"id < %d", count/2]];
            } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
                [expectation fulfill];
            }];
            [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
                XCTAssertNil(error, @"error: %@", error);
            }];
        }
        
        XCTAssertEqual([[Tweet allObjectsInRealm:[store realm]] count], count/2);
    }];
}

- (void)testDeleteNestedRelationObjects
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (!sync) return ;
        
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
        
        XCTAssertEqual([[Tweet allObjectsInRealm:[store realm]] count], 0);
        XCTAssertEqual([[Entities allObjectsInRealm:[store realm]] count], 0);
        XCTAssertEqual([[Url allObjectsInRealm:[store realm]] count], 0);
    }];
}

#pragma mark Fetch

- (void)testFetchObjects
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        NSUInteger count = 10;
        
        [store addTweetsWithCount:count];
        NSString *primaryKey = @"id";
        
        __block RLMResults *objects;
        
        if (sync) {
            objects = [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                RLMResults *tweets = [Tweet allObjectsInRealm:realm];
                return [tweets sortedResultsUsingProperty:primaryKey ascending:YES];
            }];
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
            
            [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                RLMResults *tweets = [Tweet allObjectsInRealm:realm];
                return [tweets sortedResultsUsingProperty:primaryKey ascending:YES];
            } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm, RLMResults *results) {
                objects = results;
                [expectation fulfill];
            }];
            
            [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
                XCTAssertNil(error, @"error: %@", error);
            }];
        }
        
        XCTAssertEqual([objects count], count);
        for (NSUInteger i = 0; i < [objects count]; i++) {
            XCTAssertEqual(((Tweet*)[objects objectAtIndex:i]).id, i);
        }
    }];
}

- (void)testAsyncFetchObjectsWithDontHavePrimaryKey
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (!sync) return ;
        
        NSUInteger count = 10;
        
        [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            for (NSUInteger i = 0; i < count; i++) {
                [realm addObject:[[Url alloc] initWithValue:@{@"url" : [NSString stringWithFormat:@"http://%zd.com", i]}]];
            }
        }];
        XCTAssertEqual([[Url allObjectsInRealm:[store realm]] count], count);
        
        XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
        [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
            return [Url allObjectsInRealm:realm];
        } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm, RLMResults *results) {
            XCTAssertNil(results);
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }];
}

#pragma mark - Cancel
#pragma mark Add

- (void)testCancelAddObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) return ;
        
        XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
        
        [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(realm);
            
            XCTAssertFalse(operation.isCancelled);
            [operation cancel];
            XCTAssertTrue(operation.isCancelled);
            
            return @[[[Tweet alloc] initWithValue:[JsonGenerator tweet]]];
        } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertTrue(operation.isCancelled);
            XCTAssertNotNil(realm);
            
            XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], 0);
            
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }];
}

- (void)testCancelWriteWithNotReturnObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) return ;
        
        XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
        
        [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(realm);
            
            XCTAssertFalse(operation.isCancelled);
            [operation cancel];
            XCTAssertTrue(operation.isCancelled);
            
            return nil;
        } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertTrue(operation.isCancelled);
            XCTAssertNotNil(realm);
            
            XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], 0);
            
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }];
}

#pragma mark Update

- (void)testCancelUpdateObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (sync) return ;
        
        NSDictionary *tweetJsonObj = [JsonGenerator tweet];
        [store addTweetWithTweetJsonObject:tweetJsonObj];
        
        XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
        
        [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(realm);
            
            XCTAssertFalse(operation.isCancelled);
            [operation cancel];
            XCTAssertTrue(operation.isCancelled);
            
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
            
            Tweet *tweet = [[Tweet alloc] initWithValue:tweetJsonObj];
            Tweet *addedTweet = [[Tweet allObjectsInRealm:realm] firstObject];
            
            XCTAssertEqual(addedTweet.id, tweet.id);
            XCTAssertEqualObjects(addedTweet.text, tweet.text);
            XCTAssertNotNil(addedTweet.user);
            XCTAssertNotNil(addedTweet.entities);
            
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }];
}

- (void)testCancelUpdateObjectWithNotReturnObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        NSDictionary *tweetJsonObj = [JsonGenerator tweet];
        [store addTweetWithTweetJsonObject:tweetJsonObj];
        
        XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
        
        [store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(realm);
            
            XCTAssertFalse(operation.isCancelled);
            [operation cancel];
            XCTAssertTrue(operation.isCancelled);
            
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
            
            Tweet *tweet = [[Tweet alloc] initWithValue:tweetJsonObj];
            Tweet *addedTweet = [[Tweet allObjectsInRealm:realm] firstObject];
            
            XCTAssertEqual(addedTweet.id, tweet.id);
            XCTAssertEqualObjects(addedTweet.text, tweet.text);
            XCTAssertNotNil(addedTweet.user);
            XCTAssertNotNil(addedTweet.entities);
            
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }];
}

#pragma mark Delete

- (void)testCancelDeleteObject
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        [store addTweetWithTweetJsonObject:[JsonGenerator tweet]];
        
        XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
        
        [store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
            XCTAssertFalse([NSThread isMainThread]);
            XCTAssertNotNil(realm);
            
            XCTAssertFalse(operation.isCancelled);
            [operation cancel];
            XCTAssertTrue(operation.isCancelled);
            
            return [Tweet allObjectsInRealm:realm];
        } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm) {
            XCTAssertTrue([NSThread isMainThread]);
            XCTAssertTrue(operation.isCancelled);
            XCTAssertNotNil(realm);
            
            XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], 1);
            
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:5. handler:^(NSError *error) {
            XCTAssertNil(error, @"error: %@", error);
        }];
    }];
}

@end