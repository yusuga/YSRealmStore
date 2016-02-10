//
//  StoreUtilityTests.m
//  StoreUtilityTests
//
//  Created by Yu Sugawara on 2016/02/10.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TwitterRealmStore.h"

@interface StoreUtilityTests : XCTestCase

@end

@implementation StoreUtilityTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRemoveRealmFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    NSString *realmPath = store.configuration.path;
    NSError *error = nil;
    
    @autoreleasepool {
        XCTAssertNotNil([store realmWithError:&error]); // create realm file
        
        XCTAssertNil(error);
        
        XCTAssertTrue([fileManager fileExistsAtPath:realmPath]);
        
        error = nil;
        
        [store removeRealmFileWithError:&error];
        
        XCTAssertNil(error);
        
        XCTAssertFalse([fileManager fileExistsAtPath:realmPath]);
        
        error = nil;
        [store removeRealmFileWithError:&error];
        XCTAssertNil(error);
    }
    
    XCTAssertNotNil([store realmWithError:&error]); // recreate realm file
    XCTAssertNil(error);
    
    XCTAssertTrue([fileManager fileExistsAtPath:store.configuration.path]);
}

- (void)testCreateAndRemoveEncriptionKey
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSData *key = [TwitterRealmStore defaultEncryptionKey];
    XCTAssertNotNil(key);
    XCTAssertEqual(key.length, 64);
    
    RLMRealmConfiguration *configuration = [[RLMRealmConfiguration alloc] init];
    configuration.path = [YSRealmStore realmPathWithFileName:@"encripted"];
    configuration.encryptionKey = key;
    YSRealmStore *store = [[YSRealmStore alloc] initWithConfiguration:configuration];
    
    {
        NSError *error = nil;
        [store removeRealmFileWithError:&error];
        XCTAssertNil(error);
    }
    
    XCTAssertFalse([fileManager fileExistsAtPath:store.configuration.path]);
    
    {
        NSError *error = nil;
        @autoreleasepool {
            [store realmWithError:&error];
        }
        XCTAssertNil(error);
        
        XCTAssertTrue([fileManager fileExistsAtPath:store.configuration.path]);
    }
    
    XCTAssertTrue([[TwitterRealmStore sharedStore] removeEncryptionKeyWithKeychainIdentifier:[TwitterRealmStore defaultKeychainIdentifier]]);
    
    NSData *newKey = [TwitterRealmStore defaultEncryptionKey];
    XCTAssertNotEqualObjects(configuration.encryptionKey, newKey);
    NSLog(@"%s {\n\tkey:    %@\n\tnewKey: %@\n}", __func__, configuration.encryptionKey, newKey);
    
    RLMRealmConfiguration *newConfiguration = [[RLMRealmConfiguration alloc] init];
    newConfiguration.path = configuration.path;
    newConfiguration.encryptionKey = newKey;
    YSRealmStore *newStore = [[YSRealmStore alloc] initWithConfiguration:newConfiguration];
    
    {
        NSError *error = nil;
        @autoreleasepool {
            [store realmWithError:&error];
        }
        XCTAssertNil(error);
    }
    
    {
        NSError *error = nil;
        @autoreleasepool {
            [newStore realmWithError:&error];
        }
        XCTAssertNotNil(error);
    }
    
    {
        NSError *error = nil;
        [newStore removeRealmFileWithError:&error];
        XCTAssertNil(error);
    }
    
    {
        NSError *error = nil;
        [newStore realmWithError:&error];
        XCTAssertNil(error);
    }
}

@end
