//
//  FileTests.m
//  FileTests
//
//  Created by Yu Sugawara on 2016/03/08.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YSRealmStore.h"
#import "TwitterRealmStore.h"
#import "TwitterRequest.h"
#import "Models.h"
#import "JsonGenerator.h"

@interface FileTests : XCTestCase

@property (nonatomic) RLMRealmConfiguration *configuration1;
@property (nonatomic) RLMRealmConfiguration *configuration2;

@end

@implementation FileTests

- (void)setUp
{
    [super setUp];
    
    NSArray *objectClasses = @[[Tweet class],
                               [User class],
                               [Entities class],
                               [Url class],
                               [Mention class]];
    
    {
        RLMRealmConfiguration *config = [[RLMRealmConfiguration alloc] init];
        config.fileURL = [YSRealmStore realmFileURLWithRealmName:[NSString stringWithFormat:@"%@_1", NSStringFromClass([self class])]];
        config.objectClasses = objectClasses;
        config.schemaVersion = 1;
        config.encryptionKey = [@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"config1.encryptionKey: %@", [config.encryptionKey.description stringByReplacingOccurrencesOfString:@" " withString:@""]);
        self.configuration1 = config;
    }
    {
        RLMRealmConfiguration *config = [[RLMRealmConfiguration alloc] init];
        config.fileURL = [YSRealmStore realmFileURLWithRealmName:[NSString stringWithFormat:@"%@_2", NSStringFromClass([self class])]];
        config.objectClasses = objectClasses;
        config.schemaVersion = 1;
        config.encryptionKey = [@"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"config1.encryptionKey: %@", [config.encryptionKey.description stringByReplacingOccurrencesOfString:@" " withString:@""]);
        self.configuration2 = config;
    }
    
    [self deleteTestRealm];
}

- (void)tearDown
{
    [self deleteTestRealm];
    
    [super tearDown];
}

- (void)testCopyRealm
{
    TwitterRealmStore *store1 = [[TwitterRealmStore alloc] initWithConfiguration:self.configuration1];
    
    Tweet *tweet1 = [[Tweet alloc] initWithValue:[JsonGenerator tweet]];
    [store1.realm transactionWithBlock:^{
        [store1.realm addObject:tweet1];
    }];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertTrue([fileManager fileExistsAtPath:self.configuration1.fileURL.path]);
    XCTAssertFalse([fileManager fileExistsAtPath:self.configuration2.fileURL.path]);
    
    NSError *error = nil;
    [store1.realm writeCopyToURL:self.configuration2.fileURL encryptionKey:self.configuration2.encryptionKey error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([fileManager fileExistsAtPath:self.configuration2.fileURL.path]);
    
    TwitterRealmStore *store2 = [[TwitterRealmStore alloc] initWithConfiguration:self.configuration2];
    Tweet *tweet2 = [Tweet objectInRealm:store2.realm forPrimaryKey:tweet1.id];
    XCTAssertNotNil(tweet2);
    XCTAssertEqualObjects(tweet1.id, tweet2.id);
    XCTAssertEqual(tweet1.user.id, tweet2.user.id);
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
    [YSRealmStore deleteRealmFilesWithRealmFilePath:self.configuration1.fileURL.path error:&error];
    XCTAssertNil(error, @"error: %@", error);
    
    error = nil;
    [YSRealmStore deleteRealmFilesWithRealmFilePath:self.configuration2.fileURL.path error:&error];
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
