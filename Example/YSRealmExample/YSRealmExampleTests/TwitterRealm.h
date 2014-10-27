//
//  TwitterRealm.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"

@interface TwitterRealm : NSObject

+ (void)addOrUpdateTweet:(Tweet*)tweet;
+ (void)updateTweet:(void(^)(void))updating;

+ (void)deleteAllObjects;

@end
