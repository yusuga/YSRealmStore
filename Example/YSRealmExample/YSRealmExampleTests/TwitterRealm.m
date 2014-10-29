//
//  TwitterRealm.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "TwitterRealm.h"
#import <Realm/Realm.h>

@implementation TwitterRealm

+ (void)initialize
{
    if (self == [TwitterRealm class]) {
        [RLMRealm setSchemaVersion:1 withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
            DDLogDebug(@"oldSchemaVersion: %zd", oldSchemaVersion);
        }];
        DDLogDebug(@"path: %@", [RLMRealm defaultRealmPath]);
    }
}

+ (void)addOrUpdateTweet:(Tweet *)tweet
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:tweet];
    [realm commitWriteTransaction];
}

+ (void)updateTweet:(void(^)(void))updating
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    if (updating) updating();
    [realm commitWriteTransaction];
}

+ (void)deleteAllObjects
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

@end
