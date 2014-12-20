//
//  CategoryTests.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/12/14.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RLMObject+YSRealmStore.h"
#import "RLMArray+YSRealmStore.h"
#import "Utility.h"

@interface CategoryTests : XCTestCase

@end

@implementation CategoryTests

- (void)setUp
{
    [super setUp];
    [Utility deleteAllObjects];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRLMArray
{
    YSRealmStore *ysRealm = [YSRealmStore sharedInstance];
    int64_t tweetID = 0;
    NSUInteger userCount = 10;
    
    [Utility addTweetWithTweetJsonObject:[JsonGenerator tweetWithTweetID:tweetID userID:0]];
    [ysRealm writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        for (NSUInteger userID = 0; userID < userCount; userID++) {
            User *user = [User objectForPrimaryKey:@(userID)];
            if (user == nil) {
                user = [[User alloc] initWithObject:[JsonGenerator userWithID:userID]];
            }
            [realm addObject:user];
        }
    }];
    XCTAssertEqual([[User allObjects] count], userCount);
    
    [ysRealm writeTransactionWithWriteBlock:^(RLMRealm *realm, YSRealmWriteTransaction *transaction) {
        Tweet *tweet = [Tweet objectForPrimaryKey:@(tweetID)];
        XCTAssertNotNil(tweet);
        RLMArray *watchers = tweet.watchers;
        XCTAssertNotNil(watchers);
        XCTAssertEqual([watchers count], 0);
        
        User *user0 = [User objectForPrimaryKey:@(0)];
        User *user1 = [User objectForPrimaryKey:@(1)];
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

@end
