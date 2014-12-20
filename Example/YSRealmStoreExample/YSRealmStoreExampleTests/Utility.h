//
//  Utility.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/11/18.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSRealmStore.h"
#import "JsonGenerator.h"
#import "Tweet.h"

@interface Utility : NSObject

+ (void)deleteAllObjects;

+ (void)addTweetWithTweetJsonObject:(NSDictionary*)tweetJsonObject;
+ (void)addTweetsWithCount:(NSUInteger)count;

@end
