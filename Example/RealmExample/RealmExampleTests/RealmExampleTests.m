//
//  RealmExampleTests.m
//  RealmExampleTests
//
//  Created by Yu Sugawara on 2015/01/17.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Realm/Realm.h>
#import "Model.h"
#import <Realm+JSON/RLMObject+JSON.h>

@interface RealmExampleTests : XCTestCase

@end

@implementation RealmExampleTests

- (void)setUp
{
    [super setUp];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
    }];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"defaultRealm.path = %@", realm.path);
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValues
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    BOOL boolean = YES;
    NSInteger integer = NSIntegerMax;
    int64_t int64 = INT64_MAX;
    CGFloat decimal = CGFLOAT_MAX;
    NSString *string = @"string";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0.];
    NSData *data = [NSData data];
    
    [realm transactionWithBlock:^{
        [realm addObject:[[Model alloc] initWithObject:[self dictionaryWithBooleanNum:@(boolean)
                                                                           integerNum:@(integer)
                                                                             int64Num:@(int64)
                                                                           decimalNum:@(decimal)
                                                                               string:string
                                                                                 date:date
                                                                                 data:data]]];
    }];
    
    Model *model = [[Model allObjects] firstObject];
    XCTAssertNotNil(model);
    
    XCTAssertEqual(model.boolean, boolean);
    XCTAssertEqual(model.integer, integer);
    XCTAssertEqual(model.int64, int64);
    XCTAssertEqual(model.decimal, decimal);
    XCTAssertEqualObjects(model.string, string);
    XCTAssertEqualObjects(model.date, date);
    XCTAssertEqualObjects(model.data, data);
    XCTAssertNil(model.subModel);
    XCTAssertNotNil(model.arrayModel);
    XCTAssertEqual([model.arrayModel count], 0);
}

- (void)testModelInit
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm transactionWithBlock:^{
        [realm addObject:[[Model alloc] init]];
    }];
    
    Model *model = [[Model allObjects] firstObject];
    XCTAssertNotNil(model);
    
    XCTAssertEqual(model.boolean, NO);
    XCTAssertEqual(model.integer, 0);
    XCTAssertEqual(model.int64, 0);
    XCTAssertEqual(model.decimal, 0.f);
    XCTAssertEqualObjects(model.string, [Model defaultString]);
    XCTAssertEqualObjects(model.date, [Model defaultDate]);
    XCTAssertEqualObjects(model.data, [Model defaultData]);
    XCTAssertNil(model.subModel);
    XCTAssertNotNil(model.arrayModel);
    XCTAssertEqual([model.arrayModel count], 0);
}

- (void)testSubModelInit
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm transactionWithBlock:^{
        [realm addObject:[[SubModel alloc] init]];
    }];
    
    SubModel *model = [[SubModel allObjects] firstObject];
    XCTAssertNotNil(model);
    
    XCTAssertEqual(model.boolean, [SubModel defaultBoolean]);
    XCTAssertEqual(model.integer, [SubModel defaultInteger]);
    XCTAssertEqual(model.int64, [SubModel defaultInt64]);
    XCTAssertEqual(model.decimal, [SubModel defaultDecimal]);
    XCTAssertEqualObjects(model.string, [Model defaultString]);
    XCTAssertEqualObjects(model.date, [Model defaultDate]);
    XCTAssertEqualObjects(model.data, [Model defaultData]);
}

- (void)testInitWithNSNull
{
    /**
     *  Realm(0.88.0)ではNSNullがサポートされていない。例外が投げられる。
     */
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm transactionWithBlock:^{
        id exc;
        @try {
            [realm addObject:[[Model alloc] initWithObject:[self dictionaryWithBooleanNum:[NSNull null]
                                                                               integerNum:[NSNull null]
                                                                                 int64Num:[NSNull null]
                                                                               decimalNum:[NSNull null]
                                                                                   string:[NSNull null]
                                                                                     date:[NSNull null]
                                                                                     data:[NSNull null]]]];
        }
        @catch (NSException *exception) {
            exc = exception;
        }
        @finally {
            XCTAssertNotNil(exc);
            NSLog(@"%s; exception = %@;", __func__, exc);
        }
    }];
/*
    Model *model = [[Model allObjects] firstObject];
    XCTAssertNotNil(model);
    
    XCTAssertEqual(model.boolean, NO);
    XCTAssertEqual(model.integer, 0);
    XCTAssertEqual(model.decimal, 0.f);
    XCTAssertEqualObjects(model.string, [Model defaultString]);
    XCTAssertEqualObjects(model.date, [Model defaultDate]);
    XCTAssertEqualObjects(model.data, [Model defaultData]);
    XCTAssertNil(model.subModel);
    XCTAssertNotNil(model.arrayModel);
    XCTAssertEqual([model.arrayModel count], 0);
 */
}

#pragma mark - Utility

- (NSDictionary*)dictionaryWithBooleanNum:(id)boolean
                               integerNum:(id)integer
                                 int64Num:(id)int64
                               decimalNum:(id)decimal
                                   string:(id)string
                                     date:(id)date
                                     data:(id)data
{
    return @{@"boolean" : boolean,
             @"integer" : integer,
             @"int64" : int64,
             @"decimal" : decimal,
             @"string" : string,
             @"date" : date,
             @"data" : data};
}

@end
