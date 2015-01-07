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
#import "RLMRealm+YSRealmStore.h"
#import "RLMArray+YSRealmStore.h"
#import "NSDictionary+YSRealmStore.h"
#import "NSString+YSRealmStore.h"
#import "NSDate+YSRealmStore.h"
#import "NSData+YSRealmStore.h"

@interface CategoryTests : XCTestCase

@end

@implementation CategoryTests

- (void)setUp
{
    [super setUp];
    [[TwitterRealmStore sharedStore] deleteAllObjects];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - RLMRealm

- (void)testRealmWithFileName
{
    NSString *fileName = @"database";
    RLMRealm *realm = [RLMRealm ys_realmWithFileName:fileName];
    NSString *path = realm.path;
    DDLogDebug(@"%s; path = %@;", __func__, path);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertTrue([fileManager fileExistsAtPath:path]);
    
    NSError *error = nil;
    XCTAssertTrue([fileManager removeItemAtPath:path error:&error]);
    XCTAssertNil(error);
}

#pragma mark - RLMArray

- (void)testRLMArray
{
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    int64_t tweetID = 0;
    NSUInteger userCount = 10;
    
    [store addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:tweetID userID:0]];
    
    [store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
        for (NSUInteger userID = 0; userID < userCount; userID++) {
            User *user = [User objectInRealm:realm forPrimaryKey:@(userID)];
            if (user == nil) {
                user = [[User alloc] initWithObject:[JsonGenerator userWithID:userID]];
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
