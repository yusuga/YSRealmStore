//
//  TweetCell.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/05.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "TweetCell.h"
#import "Tweet.h"

@interface TweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end

@implementation TweetCell

+ (UINib*)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (CGFloat)cellHeight
{
    return 82.;
}

- (void)configureContentWithTweet:(Tweet *)tweet
{
    User *user = tweet.user;
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@ @%@", user.name, user.screen_name];
    self.bodyLabel.text = [NSString stringWithFormat:@"%@ (tweet id: %lld)", tweet.text, tweet.id];
    
    self.profileImageView.image = [[self class] profileImageWithUserId:user.id];
}

#pragma mark - helper

+ (UIImage*)profileImageWithUserId:(int64_t)userID
{
    UIColor *color;
    switch (userID) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor blueColor];
            break;
        case 2:
            color = [UIColor greenColor];
            break;
        case 3:
            color = [UIColor yellowColor];
            break;
        case 4:
            color = [UIColor purpleColor];
            break;
        default:
            color = [UIColor blackColor];
            break;
    }
    return [self imageFromColor:color];
}

+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.f, 0.f, 1.f, 1.f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
