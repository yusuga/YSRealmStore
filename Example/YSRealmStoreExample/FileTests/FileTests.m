//
//  FileTests.m
//  FileTests
//
//  Created by Yu Sugawara on 2016/03/08.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YSRealmStore.h"
#import "TwitterRequest.h"
#import "Models.h"

@interface FileTests : XCTestCase

@property (nonatomic) RLMRealmConfiguration *configuration;

@end

@implementation FileTests

- (void)setUp
{
    [super setUp];
    
    RLMRealmConfiguration *configuration = [[RLMRealmConfiguration alloc] init];
    configuration.fileURL = [YSRealmStore realmFileURLWithRealmName:NSStringFromClass([self class])];
    
    configuration.objectClasses = @[[Tweet class],
                                    [User class],
                                    [Entities class],
                                    [Url class],
                                    [Mention class]];
    
    configuration.schemaVersion = 1;
    
    configuration.encryptionKey = [YSRealmStore defaultEncryptionKey];
    NSLog(@"%s, encryptionKey: %@", __func__, [configuration.encryptionKey.description stringByReplacingOccurrencesOfString:@" " withString:@""]);
    self.configuration = configuration;
    
    [self deleteTestRealm];
}

- (void)tearDown
{
    [self deleteTestRealm];
    
    [super tearDown];
}

/*
- (void)testCompactRealmFile
{
    unsigned long long initializedRealmSize = 0;
    unsigned long long clearedRealmSize = 0;

    NSUInteger tweetsCount = 1000;
    NSUInteger restCount = 10;
    
    @autoreleasepool {
        NSError *error = nil;
        RLMRealm *realm = [RLMRealm realmWithConfiguration:self.configuration error:&error];
        XCTAssertNil(error);
        NSString *realmPath = self.configuration.fileURL.path;
        
        initializedRealmSize = [self realmSizeForPath:realmPath];
        XCTAssertGreaterThan(initializedRealmSize, 0);
        NSLog(@" {\n\tinitializedRealmSize: %lld bytes\n\ttweets.count: %zd\n}", initializedRealmSize, [[Tweet allObjectsInRealm:realm] count]);
        
        [realm transactionWithBlock:^{
            for (NSDictionary *tweetValue in [TwitterRequest requestTweetsWithCount:tweetsCount]) {
                [realm addOrUpdateObject:[[Tweet alloc] initWithValue:tweetValue]];
            }
        }];
        XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], tweetsCount);
        NSLog(@"\n\tAdd %zd tweets.", tweetsCount);
        
        unsigned long long updatedRealmSize = [self realmSizeForPath:realmPath];
        XCTAssertGreaterThan(updatedRealmSize, initializedRealmSize);
        NSLog(@" {\n\tupdatedRealmSize: %lld bytes\n\ttweets.count: %zd\n}", updatedRealmSize, [[Tweet allObjectsInRealm:realm] count]);
        
        [realm transactionWithBlock:^{
            Tweet *tweet = [[[Tweet allObjectsInRealm:realm] sortedResultsUsingProperty:@"id" ascending:NO] objectAtIndex:restCount];
            [realm deleteObjects:[Tweet objectsInRealm:realm where:@"id <= %@", tweet.id]];
        }];
        XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], restCount); // Deleted Tweet
        NSLog(@"\n\tDelete %zd tweets.", tweetsCount - restCount);
        
        clearedRealmSize = [self realmSizeForPath:realmPath];
        XCTAssertEqual(clearedRealmSize, updatedRealmSize); // but not changed!
        NSLog(@" {\n\tclearedRealmSize: %lld bytes (Not changed!!)\n\ttweets.count: %zd\n}", clearedRealmSize, [[Tweet allObjectsInRealm:realm] count]);
    }
    
    NSError *error = nil;
    [YSRealmStore compactRealmFileWithConfiguration:self.configuration error:&error];
    if (error) NSLog(@"Fatal error: %@", error);
    
    error = nil;
    RLMRealm *realm = [RLMRealm realmWithConfiguration:self.configuration error:&error];
    XCTAssertNil(error);
    XCTAssertEqual([[Tweet allObjectsInRealm:realm] count], restCount);
    
    unsigned long long compactedRealmSize = [self realmSizeForPath:self.configuration.fileURL.path];
    XCTAssertEqual(compactedRealmSize, initializedRealmSize);
    NSLog(@" {\n\tcompactedRealmSize: %lld bytes (Size has changed🎉)\n\ttweets.count: %zd", compactedRealmSize, [[Tweet allObjectsInRealm:realm] count]);
}
 */

#pragma mark - Util

- (void)deleteTestRealm
{
    NSError *error = nil;
    [YSRealmStore deleteRealmFilesWithRealmFilePath:self.configuration.fileURL.path error:&error];
    XCTAssertNil(error, @"error: %@", error);
}

- (unsigned long long)realmSizeForPath:(NSString *)path
{
    NSError *error = nil;
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error] fileSize];;
    XCTAssertNil(error);
    return size;
}

@end
