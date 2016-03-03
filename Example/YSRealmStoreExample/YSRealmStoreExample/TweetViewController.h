//
//  TweetViewController.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/05.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterRealmStore.h"

@interface TweetViewController : UITableViewController

@property (nonatomic) RLMResults *tweets;

- (NSArray *)createTweetValues;
- (void)resetState;

@end
