//
//  UtilityTests.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/02/23.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Utility.h"

@interface UtilityTests : XCTestCase

@end

@implementation UtilityTests

- (void)testEnumerateAllCase
{
    __block NSUInteger count = 0;
    [Utility enumerateAllCase:^(TwitterRealmStore *store, BOOL sync) {
        XCTAssertNotNil(store);
        switch (count++) {
            case 0:
                XCTAssertFalse(store.inMemory);
                XCTAssertTrue(store.encrypted);
                XCTAssertTrue(sync);
                break;
            case 1:
                XCTAssertFalse(store.inMemory);
                XCTAssertTrue(store.encrypted);
                XCTAssertFalse(sync);
                break;
            case 2:
                XCTAssertTrue(store.inMemory);
                XCTAssertFalse(store.encrypted);
                XCTAssertTrue(sync);
                break;
            case 3:
                XCTAssertTrue(store.inMemory);
                XCTAssertFalse(store.encrypted);
                XCTAssertFalse(sync);
                break;
            default:
                XCTFail(@"Unknown case");
                break;
        }
    }];
    XCTAssertEqual(count, 4);
}

@end
