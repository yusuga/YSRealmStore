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

- (void)tearDown
{    
    [super tearDown];
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
            
            /*
             *  対象オブジェクト
             *  - PrimaryKeyを持つ && Realmに関連付けられている
             *  - PrimaryKeyを持つ && Realmに関連付けられていない
             *  - PrimaryKeyを持たない && Realmに関連付けられている
             *  - PrimaryKeyを持たない && Realmに関連付けられていない
             */
            
            // RLMObject have a primary key
            {
                RLMArray *watchers = tweet.watchers;
                XCTAssertNotNil(watchers);
                XCTAssertEqual([watchers count], 0);
                
                User *user0 = [User objectInRealm:realm forPrimaryKey:@(0)];
                User *user1 = [User objectInRealm:realm forPrimaryKey:@(1)];
                XCTAssertNotNil(user0);
                XCTAssertNotNil(user0.realm);
                XCTAssertNotNil(user1);
                XCTAssertNotNil(user1.realm);
                
                /* ys_containsObject */
                XCTAssertFalse([watchers ys_containsObject:user0]);
                
                [watchers addObject:user0];
                XCTAssertEqual([watchers count], 1);
                XCTAssertTrue([watchers ys_containsObject:user0]);
                XCTAssertFalse([watchers ys_containsObject:user1]);
                
                /* ys_addUniqueObject: */
                [watchers ys_uniqueAddObject:user0];
                XCTAssertEqual([watchers count], 1);
                XCTAssertEqual([watchers count], 1);
                [watchers ys_uniqueAddObject:user1];
                XCTAssertEqual([watchers count], 2);
                
                User *user100 = [[User alloc] initWithValue:[JsonGenerator userWithID:100]];
                [watchers ys_uniqueAddObject:user100];
                XCTAssertNotNil(user100.realm);
                XCTAssertEqual([watchers count], 3);
                [watchers ys_uniqueAddObject:user100];
                XCTAssertEqual([watchers count], 3);
                
                /* ys_removeObject */
                [watchers ys_removeObject:user1];
                XCTAssertEqual([watchers count], 2);
            }
            
#if 0
            // RLMObject does not have a primary key
            {
                Entities *entities = tweet.entities;
                RLMArray *urls = entities.urls;
                XCTAssertEqual([urls count], 1);
                Url *url = [urls firstObject];
                XCTAssertNotNil(url);
                XCTAssertNotNil(url.realm);
                
                Url *sameURL = [[Url alloc] initWithValue:@{@"url" : url.url}];
                XCTAssertNil(sameURL.realm);
                
                RLMResults *allURLs = [Url allObjectsInRealm:realm];
                XCTAssertEqual([allURLs count], 1);
                Url *fetchedURL = [allURLs firstObject];
                
                /* ys_containsObject */
                XCTAssertTrue([urls ys_containsObject:url]); // url is related with the realm.
                
                XCTAssertFalse([urls ys_containsObject:sameURL]); // sameURL.url is the same but value(string) does not compare.
                
                XCTAssertNotEqual(url, fetchedURL); // Pointer is different.
                XCTAssertTrue([urls ys_containsObject:fetchedURL]); // The row of the database matches.
            }
#endif
        }];
    }];
}

- (void)testRLMArray2
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
        
        RLMRealm *realm = [store realm];
        
        Tweet *tweet = [Tweet objectInRealm:realm forPrimaryKey:@(tweetID)];
        XCTAssertNotNil(tweet);
        
        RLMArray *watchers = tweet.watchers;
        XCTAssertNotNil(watchers);
        XCTAssertEqual([watchers count], 0);
        
        User *user0 = [User objectInRealm:realm forPrimaryKey:@(0)];
        User *user1 = [User objectInRealm:realm forPrimaryKey:@(1)];
        XCTAssertNotNil(user0);
        XCTAssertNotNil(user0.realm);
        XCTAssertNotNil(user1);
        XCTAssertNotNil(user1.realm);
        
        XCTAssertFalse([watchers ys_containsObject:user0]);
        
        [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
            [watchers addObject:user0];
        }];
        
        XCTAssertEqual([watchers count], 1);
        XCTAssertTrue([watchers ys_containsObject:user0]);
        XCTAssertFalse([watchers ys_containsObject:user1]);
        
        RLMResults *results = [watchers objectsWhere:@"id >= 0"];
        NSLog(@"%zd, %zd", [watchers indexOfObject:user0], [watchers indexOfObject:user1]/* == NSNotFound */);
        NSLog(@"%zd", [results indexOfObject:user1]); // crash :( -> Fixed realm-cocoa (0.98.1)
    }];
}

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
            XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __func__]];
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
