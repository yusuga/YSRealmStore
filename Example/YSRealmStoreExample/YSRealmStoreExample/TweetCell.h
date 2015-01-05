//
//  TweetCell.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/05.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Tweet;

@interface TweetCell : UITableViewCell

+ (UINib*)nib;
+ (CGFloat)cellHeight;

- (void)configureContentWithTweet:(Tweet*)tweet;

@end
