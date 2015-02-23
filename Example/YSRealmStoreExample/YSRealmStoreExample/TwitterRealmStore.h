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

@interface TwitterRealmStore : YSRealmStore

+ (instancetype)sharedStore;
+ (instancetype)createStoreInMemory;

- (void)addTweetWithTweetJsonObject:(NSDictionary*)tweetJsonObject;
- (void)addTweetsWithCount:(NSUInteger)count;

- (void)addTweetsWithTweetJsonObjects:(NSArray *)tweetJsonObjects;
- (YSRealmWriteTransaction*)addTweetsWithTweetJsonObjects:(NSArray *)tweetJsonObjects
                                               completion:(YSRealmStoreWriteTransactionCompletion)completion;

- (RLMResults*)fetchAllTweets;

@end
