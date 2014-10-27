//
//  JsonGenerator.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "JsonGenerator.h"

@implementation JsonGenerator

+ (NSDictionary*)tweet
{
    return [self tweetWithID:INT64_MAX];
}

+ (NSDictionary*)tweetWithID:(int64_t)id
{
    return @{@"id" : @(id),
             @"text" : @"sample text. サンプルテキストです。",
             @"user" : [self user],
             @"entities" : [self entities],
             @"source" : @"via Twitter"};
}

+ (NSDictionary*)user
{
    return @{@"id" : @(INT64_MAX),
             @"name" : @"Yu Sugawara"};
}

+ (NSDictionary*)entities
{
    return @{@"urls" : @[[self url],
                         [self url],
                         [self url]]};
}

+ (NSDictionary*)url
{
    return @{@"url" : @"http://google.com"};
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
