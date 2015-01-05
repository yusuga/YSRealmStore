//
//  TwitterRequest.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/05.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterRequest : NSObject

+ (NSArray*)requestTweetsWithMaxCount:(NSUInteger)maxCount;
+ (NSArray*)requestTweetsWithCount:(NSUInteger)count;
+ (void)resetState;

@end
