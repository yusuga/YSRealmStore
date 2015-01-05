//
//  TwitterRequest.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/05.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "TwitterRequest.h"
#import "JsonGenerator.h"

#define kVirtualTweetId @"kVirtualTweetID"
static NSUInteger __virtualTweetID; // Twitterの仮想なリクエストのためのId

@implementation TwitterRequest

+ (void)initialize
{
    if (self == [TwitterRequest class]) {
        // ツイートの仮想なリクエストのためのID設定
        __virtualTweetID = [[NSUserDefaults standardUserDefaults] integerForKey:kVirtualTweetId];
        
        // Check sample values
        NSAssert([[self userNames] count] == [[self screenNames] count], nil);
        NSAssert([[self userNames] count] == [[self greetings] count], nil);
    }
}

+ (NSArray *)requestTweetsWithMaxCount:(NSUInteger)maxCount
{
    return [self requestTweetsWithCount:arc4random_uniform((u_int32_t)maxCount) + 1]; // limit個のツイートを取得;
}

+ (NSArray *)requestTweetsWithCount:(NSUInteger)count
{
    // ツイートを取得する仮想なリクエスト
    NSMutableArray *newTweets = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        NSUInteger idx = arc4random_uniform((u_int32_t)[[self userNames] count]); // ランダムなidx
        NSString *name = [[self class] userNames][idx];
        NSString *screenName = [[self class] screenNames][idx];
        NSString *text = [[self class] greetings][idx];
        
        [newTweets addObject:[JsonGenerator tweetWithTweetID:__virtualTweetID + i
                                                        text:text
                                                      userID:idx
                                                        name:name
                                                  screenName:screenName
                                                    urlCount:0]];
    }
    
    // TweetIDを更新
    __virtualTweetID += count;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:__virtualTweetID forKey:kVirtualTweetId];
    [ud synchronize];
    
    //    NSLog(@"get new tweets = \n%@", newTweets);
    
    return newTweets;
}

+ (void)resetState
{
    __virtualTweetID = 0;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:0 forKey:kVirtualTweetId];
    [ud synchronize];
}

#pragma mark - Utility

+ (NSArray*)userNames
{
    return @[@"田中太郎", @"John Smith", @"Иван Иванович Иванов", @"Hans Schmidt", @"張三李四"];
}

+ (NSArray*)screenNames
{
    return @[@"taro", @"john", @"ivan", @"hans", @"cho"];
}

+ (NSArray*)greetings
{
    return @[@"おはようございます。", @"Good morning.", @"Доброе утро.", @"Guten Morgen.", @"你早。"];
}

@end
