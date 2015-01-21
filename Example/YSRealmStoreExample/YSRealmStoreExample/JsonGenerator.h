//
//  JsonGenerator.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonGenerator : NSObject

+ (NSDictionary*)tweet;
+ (NSDictionary*)tweetWithID:(int64_t)objID;
+ (NSDictionary*)tweetWithTweetID:(int64_t)tweetID
                           userID:(int64_t)userID;
+ (NSDictionary*)tweetWithTweetID:(int64_t)tweetID
                           userID:(int64_t)userID
                         urlCount:(NSUInteger)urlCount;
+ (NSDictionary*)tweetWithTweetID:(int64_t)tweetID
                           userID:(int64_t)userID
                             name:(NSString*)name
                       screenName:(NSString*)screenName
                  mentionsUserIDs:(NSArray*)mentionsUserIDs
                    mentionsNames:(NSArray*)mentionsNames;
+ (NSDictionary*)tweetWithTweetID:(int64_t)tweetID
                             text:(NSString*)text
                           userID:(int64_t)userID
                             name:(NSString*)name
                       screenName:(NSString*)screenName
                         urlCount:(NSUInteger)urlCount;
+ (NSDictionary*)tweetOfContainNSNull;
+ (NSDictionary*)tweetOfContainEmptyArray;
+ (NSDictionary*)tweetOfKeyIsNotEnough;

+ (NSDictionary*)user;
+ (NSDictionary*)userWithID:(int64_t)userID;

@end
