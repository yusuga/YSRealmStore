//
//  JsonGenerator.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "JsonGenerator.h"
#import "NSData+YSRealmStore.h"

@implementation JsonGenerator

+ (NSDictionary*)tweet
{
    return [self tweetWithID:INT64_MAX];
}

+ (NSDictionary*)tweetWithID:(int64_t)objID
{
    return [self tweetWithTweetID:objID userID:objID];
}

+ (NSDictionary*)tweetWithTweetID:(int64_t)tweetID
                           userID:(int64_t)userID
{
    return [self tweetWithTweetID:tweetID
                             text:@"sample text. サンプルテキストです。"
                             user:[self userWithID:userID]
                         entities:[self entities]];
}

+ (NSDictionary*)tweetWithTweetID:(int64_t)tweetID
                           userID:(int64_t)userID
                         urlCount:(NSUInteger)urlCount
{
    return [self tweetWithTweetID:tweetID
                             text:@"sample text. サンプルテキストです。"
                           userID:userID
                             name:nil
                       screenName:nil
                         urlCount:urlCount];
}

+ (NSDictionary*)tweetWithTweetID:(int64_t)tweetID
                             text:(NSString*)text
                           userID:(int64_t)userID
                             name:(NSString*)name
                       screenName:(NSString*)screenName
                         urlCount:(NSUInteger)urlCount
{
    // 超簡易なTwitterのJSON (本来のJSON https://dev.twitter.com/docs/api/1.1/get/statuses/show/%3Aid )
    return [self tweetWithTweetID:tweetID
                             text:text
                             user:[self userWithID:userID name:name screenName:screenName]
                         entities:[self entitiesWithURLCount:urlCount]];
}

+ (NSDictionary*)tweetWithTweetID:(int64_t)tweetID
                             text:(NSString*)text
                             user:(NSDictionary*)user
                         entities:(NSDictionary*)entities
{
    // 超簡易なTwitterのJSON (本来のJSON https://dev.twitter.com/docs/api/1.1/get/statuses/show/%3Aid )
    return @{@"id" : @(tweetID),
             @"text" : text,
             @"retweeted" : @NO,
             @"user" : user,
             @"entities" : entities};
}

+ (NSDictionary*)user
{
    return [self userWithID:INT64_MAX];
}

+ (NSDictionary*)userWithID:(int64_t)userID
{
    return [self userWithID:userID
                       name:nil
                 screenName:nil];
}

+ (NSDictionary*)userWithID:(int64_t)userID
                       name:(NSString*)name
                 screenName:(NSString*)screenName
{
    return @{@"id" : @(userID),
             @"name" : name ? name : [NSString stringWithFormat:@"name%lld", userID],
             @"screen_name" : screenName ? screenName : [NSString stringWithFormat:@"screen_name%lld", userID],
             @"color" : [NSData ys_realmDefaultData]};
}

+ (NSDictionary*)entities
{
    return [self entitiesWithURLCount:1];
}

+ (NSDictionary*)entitiesWithURLCount:(NSUInteger)urlCount
{
    NSMutableArray *urls = @[].mutableCopy;
    for (NSUInteger i = 0; i < urlCount; i++) {
        switch (i) {
            case 0:
                [urls addObject:@{@"url" : @"http://realm.io"}];
                break;
            case 1:
                [urls addObject:@{@"url" : @"http://apple.com"}];
                break;
            default:
                [urls addObject:@{@"url" : @"http://picospec.co.jp"}];
                break;
        }
    }
    
    return @{@"urls" : urls};
}

#pragma mark -

+ (NSDictionary*)entitiesOfEmptyArray
{
    return @{@"urls" : @[]};
}

+ (NSDictionary*)entitiesOfConstainNSNull
{
    return @{@"urls" : [NSNull null]};
}

#pragma mark -

+ (NSDictionary*)tweetOfContainEmptyArray
{
    return @{@"id" : @(INT64_MAX),
             @"text" : @"sample text. サンプルテキストです。",
             @"user" : [self user],
             @"entities" : [self entitiesOfEmptyArray]};
}

+ (NSDictionary*)tweetOfContainNSNull
{
    return @{@"id" : [NSNull null],
             @"text" : [NSNull null],
             @"user" : [NSNull null],
             @"entities" : [self entitiesOfConstainNSNull]};
}

#pragma mark -

+ (NSDictionary*)tweetOfKeyIsNotEnough
{
    return @{};
}

@end
