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
        NSLog(@"defaultRealm.path = %@", realm.configuration.fileURL);
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
    uint64_t uint64 = UINT64_MAX;
    CGFloat decimal = CGFLOAT_MAX;
    NSString *string = @"string";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0.];
    NSData *data = [NSData data];
    
    NSNumber *rlmInt = @(INT64_MAX);
    NSNumber *rlmUint = @(UINT64_MAX);
    NSNumber *rlmBool = @YES;
    NSNumber *rlmDouble = @(DBL_MAX);
    NSNumber *rlmFloat = @(FLT_MAX);
    
    [realm transactionWithBlock:^{
        [realm addObject:[[Model alloc] initWithValue:[self dictionaryWithBooleanNum:@(boolean)
                                                                          integerNum:@(integer)
                                                                            int64Num:@(int64)
                                                                           uint64Num:@(uint64)
                                                                          decimalNum:@(decimal)
                                                                              string:string
                                                                                date:date
                                                                                data:data
                                                                              rlmInt:rlmInt
                                                                             rlmUint:rlmUint
                                                                             rlmBool:rlmBool
                                                                           rlmDouble:rlmDouble
                                                                            rlmFloat:rlmFloat]]];
    }];
    
    Model *model = [[Model allObjects] firstObject];
    XCTAssertNotNil(model);
    
    XCTAssertEqual(model.boolean, boolean);
    XCTAssertEqual(model.integer, integer);
    XCTAssertEqual(model.int64, int64);
    //    XCTAssertEqual(model.uint64, uint64);
    XCTAssertEqual(model.decimal, decimal);
    XCTAssertEqualObjects(model.string, string);
    XCTAssertEqualObjects(model.date, date);
    XCTAssertEqualObjects(model.data, data);
    XCTAssertNil(model.subModel);
    XCTAssertNotNil(model.arrayModel);
    XCTAssertEqual([model.arrayModel count], 0);
    
    XCTAssertEqualObjects(model.rlmInt, rlmInt);
    //    XCTAssertEqualObjects(model.rlmUint, rlmUint);
    XCTAssertEqualObjects(model.rlmBool, rlmBool);
    XCTAssertEqualObjects(model.rlmDouble, rlmDouble);
    XCTAssertEqualObjects(model.rlmFloat, rlmFloat);
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
    //    XCTAssertEqual(model.uint64, 0);
    XCTAssertEqual(model.decimal, 0.f);
    XCTAssertEqualObjects(model.string, [Model defaultString]);
    XCTAssertEqualObjects(model.date, [Model defaultDate]);
    XCTAssertEqualObjects(model.data, [Model defaultData]);
    XCTAssertNil(model.subModel);
    XCTAssertNotNil(model.arrayModel);
    XCTAssertEqual([model.arrayModel count], 0);
    
    XCTAssertTrue(model.rlmInt == nil);
    //    XCTAssertTrue(model.rlmUint == nil);
    XCTAssertTrue(model.rlmBool == nil);
    XCTAssertTrue(model.rlmDouble == nil);
    XCTAssertTrue(model.rlmFloat == nil);
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
    //    XCTAssertEqual(model.uint64, [SubModel defaultUint64]);
    XCTAssertEqual(model.decimal, [SubModel defaultDecimal]);
    XCTAssertEqualObjects(model.string, [Model defaultString]);
    XCTAssertEqualObjects(model.date, [Model defaultDate]);
    XCTAssertEqualObjects(model.data, [Model defaultData]);
    
    XCTAssertEqualObjects(model.rlmInt, @([SubModel defaultInt64]));
    //    XCTAssertEqualObjects(model.rlmUint, @([SubModel defaultUint64]));
    XCTAssertEqualObjects(model.rlmBool, @([SubModel defaultBoolean]));
    XCTAssertEqualObjects(model.rlmDouble, @([SubModel defaultDouble]));
    XCTAssertEqualObjects(model.rlmFloat, @([SubModel defaultFloat]));
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
            [realm addObject:[[Model alloc] initWithValue:[self dictionaryWithBooleanNum:[NSNull null]
                                                                              integerNum:[NSNull null]
                                                                                int64Num:[NSNull null]
                                                                               uint64Num:[NSNull null]
                                                                              decimalNum:[NSNull null]
                                                                                  string:[NSNull null]
                                                                                    date:[NSNull null]
                                                                                    data:[NSNull null]
                                                                                  rlmInt:[NSNull null]
                                                                                 rlmUint:[NSNull null]
                                                                                 rlmBool:[NSNull null]
                                                                               rlmDouble:[NSNull null]
                                                                                rlmFloat:[NSNull null]]]];
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

#warning Not supported yet (Realm 1.0.1)
#if 0
- (void)testCopyRLMObject
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    BOOL boolean = YES;
    NSInteger integer = NSIntegerMax;
    int64_t int64 = INT64_MAX;
    uint64_t uint64 = UINT64_MAX;
    CGFloat decimal = CGFLOAT_MAX;
    NSString *string = @"string";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0.];
    NSData *data = [NSData data];
    
    NSNumber *rlmInt = @(INT64_MAX);
    NSNumber *rlmUint = @(UINT64_MAX);
    NSNumber *rlmBool = @YES;
    NSNumber *rlmDouble = @(DBL_MAX);
    NSNumber *rlmFloat = @(FLT_MAX);
    
    [realm transactionWithBlock:^{
        NSDictionary *dict = [self dictionaryWithBooleanNum:@(boolean)
                                                 integerNum:@(integer)
                                                   int64Num:@(int64)
                                                  uint64Num:@(uint64)
                                                 decimalNum:@(decimal)
                                                     string:string
                                                       date:date
                                                       data:data
                                                     rlmInt:rlmInt
                                                    rlmUint:rlmUint
                                                    rlmBool:rlmBool
                                                  rlmDouble:rlmDouble
                                                   rlmFloat:rlmFloat];
        
        Model *model = [[Model alloc] initWithValue:dict];
        model.subModel = [[SubModel alloc] initWithValue:dict];
        [model.arrayModel addObjects:@[[[SubModel alloc] initWithValue:dict],
                                       [[SubModel alloc] initWithValue:dict],
                                       [[SubModel alloc] initWithValue:dict]]];
        
        [realm addObject:model];
    }];
    
    Model *model = [[Model allObjects] firstObject];
    XCTAssertNotNil(model);
    XCTAssertNotNil(model.realm);
    
    Model *copied = [[Model alloc] initWithValue:model];
    XCTAssertNotNil(copied);
    XCTAssertNil(copied.realm);
    
    XCTAssertEqual(copied.boolean, boolean);
    XCTAssertEqual(copied.integer, integer);
    XCTAssertEqual(copied.int64, int64);
    // XCTAssertEqual(copied.uint64, uint64);
    XCTAssertEqual(copied.decimal, decimal);
    XCTAssertEqualObjects(copied.string, string);
    XCTAssertEqualObjects(copied.date, date);
    XCTAssertEqualObjects(copied.data, data);
    XCTAssertEqualObjects(copied.rlmInt, rlmInt);
    // XCTAssertEqualObjects(copied.rlmUint, rlmUint);
    XCTAssertEqualObjects(copied.rlmBool, rlmBool);
    XCTAssertEqualObjects(copied.rlmDouble, rlmDouble);
    XCTAssertEqualObjects(copied.rlmFloat, rlmFloat);
    
#warning Not supported yet (Realm 1.0.1)
#if 0
    XCTAssertNil(copied.subModel.realm);
#endif
    XCTAssertEqual(copied.subModel.boolean, boolean);
    XCTAssertEqual(copied.subModel.integer, integer);
    XCTAssertEqual(copied.subModel.int64, int64);
    // XCTAssertEqual(copied.subModel.uint64, uint64);
    XCTAssertEqual(copied.subModel.decimal, decimal);
    XCTAssertEqualObjects(copied.subModel.string, string);
    XCTAssertEqualObjects(copied.subModel.date, date);
    XCTAssertEqualObjects(copied.subModel.data, data);
    XCTAssertEqualObjects(copied.subModel.rlmInt, rlmInt);
    // XCTAssertEqualObjects(copied.subModel.rlmUint, rlmUint);
    XCTAssertEqualObjects(copied.subModel.rlmBool, rlmBool);
    XCTAssertEqualObjects(copied.subModel.rlmDouble, rlmDouble);
    XCTAssertEqualObjects(copied.subModel.rlmFloat, rlmFloat);
    
    XCTAssertEqual([copied.arrayModel count], 3);
    for (SubModel *subModel in copied.arrayModel) {
#warning Not supported yet (Realm 1.0.1)
#if 0
        XCTAssertNil(subModel.realm);
#endif
        
        XCTAssertEqual(subModel.boolean, boolean);
        XCTAssertEqual(subModel.integer, integer);
        XCTAssertEqual(subModel.int64, int64);
        // XCTAssertEqual(subModel.uint64, uint64);
        XCTAssertEqual(subModel.decimal, decimal);
        XCTAssertEqualObjects(subModel.string, string);
        XCTAssertEqualObjects(subModel.date, date);
        XCTAssertEqualObjects(subModel.data, data);
        XCTAssertEqualObjects(subModel.rlmInt, rlmInt);
        // XCTAssertEqualObjects(subModel.rlmUint, rlmUint);
        XCTAssertEqualObjects(subModel.rlmBool, rlmBool);
        XCTAssertEqualObjects(subModel.rlmDouble, rlmDouble);
        XCTAssertEqualObjects(subModel.rlmFloat, rlmFloat);
    }
}
#endif

#pragma mark - Utility

- (NSDictionary*)dictionaryWithBooleanNum:(id)boolean
                               integerNum:(id)integer
                                 int64Num:(id)int64
                                uint64Num:(id)uint64
                               decimalNum:(id)decimal
                                   string:(id)string
                                     date:(id)date
                                     data:(id)data
                                   rlmInt:(id)rlmInt
                                  rlmUint:(id)rlmUint
                                  rlmBool:(id)rlmBool
                                rlmDouble:(id)rlmDouble
                                 rlmFloat:(id)rlmFloat
{
    return @{@"boolean" : boolean,
             @"integer" : integer,
             @"int64" : int64,
             @"uint64" : uint64,
             @"decimal" : decimal,
             @"string" : string,
             @"date" : date,
             @"data" : data,
             @"rlmInt" : rlmInt,
             @"rlmUint" : rlmUint,
             @"rlmBool" : rlmBool,
             @"rlmDouble" : rlmDouble,
             @"rlmFloat" : rlmFloat};
}

@end
