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

- (void)testDeleteRealmFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    TwitterRealmStore *store = [TwitterRealmStore sharedStore];
    NSString *realmPath = store.configuration.fileURL.path;
    NSError *error = nil;
    
    @autoreleasepool {
        XCTAssertNotNil([store realmWithError:&error]); // create realm file
        
        XCTAssertNil(error);
        
        XCTAssertTrue([fileManager fileExistsAtPath:realmPath]);
        
        error = nil;
        
        [store deleteRealmFilesWithError:&error];
        
        XCTAssertNil(error);
        
        XCTAssertFalse([fileManager fileExistsAtPath:realmPath]);
        
        error = nil;
        [store deleteRealmFilesWithError:&error];
        XCTAssertNil(error);
    }
    
    XCTAssertNotNil([store realmWithError:&error]); // recreate realm file
    XCTAssertNil(error);
    
    XCTAssertTrue([fileManager fileExistsAtPath:store.configuration.fileURL.path]);
}

- (void)testCreateAndDeleteEncriptionKey
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *keychainID = NSStringFromSelector(_cmd);
    
    NSData *key = [TwitterRealmStore encryptionKeyForKeychainIdentifier:keychainID];
    XCTAssertNotNil(key);
    XCTAssertEqual(key.length, 64);
    
    RLMRealmConfiguration *configuration = [[RLMRealmConfiguration alloc] init];
    configuration.fileURL = [YSRealmStore realmFileURLWithRealmName:@"encripted"];
    configuration.encryptionKey = key;
    YSRealmStore *store = [[YSRealmStore alloc] initWithConfiguration:configuration];
    
    {
        NSError *error = nil;
        [store deleteRealmFilesWithError:&error];
        XCTAssertNil(error);
    }
    
    XCTAssertFalse([fileManager fileExistsAtPath:store.configuration.fileURL.path]);
    
    {
        NSError *error = nil;
        @autoreleasepool {
            [store realmWithError:&error];
        }
        XCTAssertNil(error);
        
        XCTAssertTrue([fileManager fileExistsAtPath:store.configuration.fileURL.path]);
    }
    
    XCTAssertTrue([TwitterRealmStore deleteEncryptionKeyWithKeychainIdentifier:keychainID]);
    
    NSData *newKey = [TwitterRealmStore defaultEncryptionKey];
    XCTAssertNotEqualObjects(configuration.encryptionKey, newKey);
    NSLog(@"%s {\n\tkey:    %@\n\tnewKey: %@\n}", __func__, configuration.encryptionKey, newKey);
    
    RLMRealmConfiguration *newConfiguration = [[RLMRealmConfiguration alloc] init];
    newConfiguration.fileURL = configuration.fileURL;
    newConfiguration.encryptionKey = newKey;
    YSRealmStore *newStore = [[YSRealmStore alloc] initWithConfiguration:newConfiguration];
    
    // 旧storeではencryptionKeyが古いのでrealmファイルにアクセスできない
    {
        NSError *error = nil;
        @autoreleasepool {
            [store realmWithError:&error];
        }
        XCTAssertNil(error);
    }
    
    // 新storeでアクセスできることを確認
    {
        NSError *error = nil;
        @autoreleasepool {
            [newStore realmWithError:&error];
        }
        XCTAssertNotNil(error);
    }
    
    {
        NSError *error = nil;
        [newStore deleteRealmFilesWithError:&error]; // clean up
        XCTAssertNil(error);
    }
}

@end
