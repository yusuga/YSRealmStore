//
//  CategoryTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/12/14.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TwitterRealmStore.h"
#import "RLMObject+YSRealmStore.h"
#import "RLMArray+YSRealmStore.h"
#import "RLMResults+YSRealmStore.h"
#import "NSDictionary+YSRealmStore.h"
#import "NSString+YSRealmStore.h"
#import "NSDate+YSRealmStore.h"
#import "NSData+YSRealmStore.h"
#import "Utility.h"

@interface CategoryTests : XCTestCase

@end

@implementation CategoryTests

- (void)setUp
{
    [super setUp];
    [[TwitterRealmStore sharedStore] deleteAllObjects];
}

#pragma mark - RLMObject

#pragma mark - RLMArray

- (void)testRLMArray
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        if (!sync) return ;
        
        int64_t tweetID = 0;
        NSUInteger userCount = 10;
        
        [store addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:tweetID userID:0]];
        
        [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            for (NSUInteger userID = 0; userID < userCount; userID++) {
                User *user = [User objectInRealm:realm forPrimaryKey:@(userID)];
                if (user == nil) {
                    user = [[User alloc] initWithValue:[JsonGenerator userWithID:userID]];
                }
                [realm addObject:user];
            }
        }];
        XCTAssertEqual([[User allObjectsInRealm:[store realm]] count], userCount);
        
        [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            Tweet *tweet = [Tweet objectInRealm:realm forPrimaryKey:@(tweetID)];
            XCTAssertNotNil(tweet);
            RLMArray *watchers = tweet.watchers;
            XCTAssertNotNil(watchers);
            XCTAssertEqual([watchers count], 0);
            
            User *user0 = [User objectInRealm:realm forPrimaryKey:@(0)];
            User *user1 = [User objectInRealm:realm forPrimaryKey:@(1)];
            XCTAssertNotNil(user0);
            XCTAssertNotNil(user1);
            
            // ys_containsObject
            XCTAssertFalse([watchers ys_containsObject:user0]);
            
            [watchers addObject:user0];
            XCTAssertEqual([watchers count], 1);
            XCTAssertTrue([watchers ys_containsObject:user0]);
            XCTAssertFalse([watchers ys_containsObject:user1]);
            
            // ys_addUniqueObject:
            [watchers ys_addUniqueObject:user0];
            XCTAssertEqual([watchers count], 1);
            [watchers ys_addUniqueObject:user1];
            XCTAssertEqual([watchers count], 2);
            
            // ys_removeObject
            [watchers ys_removeObject:user1];
            XCTAssertEqual([watchers count], 1);
        }];
    }];
}
/*
- (void)testRLMArrayOfStandalone
{
    RLMArray *urls = [[RLMArray alloc] initWithObjectClassName:@"Url"];
    Url *url = [[Url alloc] initWithObject:@{@"url" : @"http://realm.io"}];
    
    [urls addObject:url];
    XCTAssertEqual([urls count], 1);
    
    XCTAssertTrue([urls ys_containsObject:url]);
    
    [urls ys_addUniqueObject:url];
    XCTAssertEqual([urls count], 1);
    
    [urls ys_removeObject:url];
    XCTAssertEqual([urls count], 0);
    
    Url *url2 = [[Url alloc] initWithObject:@{@"url" : @"http://realm.io"}];
    [url2 isEqual:url];
}
 */
/*
- (void)testRLMArrayOfNonPrimaryKeyObject
{
    YSRealm *ysRealm = [YSRealm sharedInstance];
    int64_t tweetID = 0;
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:tweetID userID:0 urlCount:1]];
    
    [ysRealm writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        Tweet *tweet = [Tweet objectInRealm:realm forPrimaryKey:@(tweetID)];
        XCTAssertNotNil(tweet);
        
        Url *url = [[Url alloc] initWithObject:@{@"url" : @"http://realm.io"}];        
        [tweet.entities.urls addObject:url];
        XCTAssertEqual([tweet.entities.urls count], 2);
        
        XCTAssertTrue([tweet.entities.urls ys_containsObject:url]);
        
        [tweet.entities.urls indexOfObject:url];
    }];
}
*/

#pragma mark - RLMResults

- (void)testRLMResults
{
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        int64_t tweetID = 0;
        NSUInteger userCount = 10;
        
        [store addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:tweetID userID:0]];
        
        [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            for (NSUInteger userID = 0; userID < userCount; userID++) {
                User *user = [User objectInRealm:realm forPrimaryKey:@(userID)];
                if (user == nil) {
                    user = [[User alloc] initWithValue:[JsonGenerator userWithID:userID]];
                }
                [realm addObject:user];
            }
        }];
        XCTAssertEqual([[User allObjectsInRealm:[store realm]] count], userCount);
        
        NSUInteger targetMaxID = userCount/2;
        XCTAssertGreaterThan(targetMaxID, 0);
        
        __block RLMResults *users;
        RLMResults*(^fetchUsers)(RLMRealm *realm) = ^RLMResults*(RLMRealm *realm) {
            return [User objectsInRealm:realm where:@"id IN %@", ^NSArray*{
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:targetMaxID];
                for (NSUInteger userID = 0; userID < targetMaxID; userID++) {
                    [arr addObject:@(userID)];
                }
                return [NSArray arrayWithArray:arr];
            }()];
        };
        
        if (sync) {
            users = [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                return fetchUsers(realm);
            }];
        } else {
            XCTestExpectation *expectation = [self expectationWithDescription:nil];
            [store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
                return fetchUsers(realm);
            } completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm, RLMResults *results) {
                users = results;
                [expectation fulfill];
            }];
            [self waitForExpectationsWithTimeout:10. handler:^(NSError *error) {
                XCTAssertNil(error, @"error: %@", error);
            }];
        }
        XCTAssertEqual([users count], targetMaxID);
        
        for (NSUInteger userID = 0; userID < userCount + 1; userID++) {
            User *user = [User objectInRealm:[store realm] forPrimaryKey:@(userID)];
            if (userID < targetMaxID) {
                XCTAssertTrue([users ys_containsObject:user]);
            } else {
                XCTAssertFalse([users ys_containsObject:user]);
            }
        }
    }];
}

#pragma mark - Dictionary

- (void)testObjectOrNil
{
    NSString *key = @"key";
    NSString *value = @"value";
    
    XCTAssertNotNil([@{key : value} ys_objectOrNilForKey:key]);
    XCTAssertNil([@{key : [NSNull null]} ys_objectOrNilForKey:key]);
}

#pragma mark - NString

- (void)testDefaultString
{
    XCTAssertTrue([[NSString ys_realmDefaultString] ys_isRealmDefaultString]);
    XCTAssertFalse([@"test" ys_isRealmDefaultString]);
}

#pragma mark - NSDate

- (void)testDefaultDate
{
    XCTAssertTrue([[NSDate ys_realmDefaultDate] ys_isRealmDefaultDate]);
    XCTAssertFalse([[NSDate dateWithTimeIntervalSinceNow:0.] ys_isRealmDefaultDate]);
}

#pragma mark - NSData

- (void)testDefaultData
{
    XCTAssertTrue([[NSData ys_realmDefaultData] ys_isRealmDefaultData]);
    XCTAssertFalse([[@"test" dataUsingEncoding:NSUTF8StringEncoding] ys_isRealmDefaultData]);
}

@end
