//
//  TweetViewController.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/05.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "TweetViewController.h"
#import "TweetCell.h"
#import "TwitterRequest.h"

static NSString * const kCellIdentifier = @"Cell";

@interface TweetViewController ()

@property (nonatomic) NSUInteger limitOfRequestTweet;
@property (nonatomic) RLMNotificationToken *notificationToken;
@property (nonatomic) UILabel *fileSizeLabel;

@end

@implementation TweetViewController

- (void)awakeFromNib
{
    self.limitOfRequestTweet = 5;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[TweetCell nib] forCellReuseIdentifier:kCellIdentifier];
    self.fileSizeLabel = [[UILabel alloc] init];
    self.fileSizeLabel.textAlignment = NSTextAlignmentCenter;
    [self updateRealmFileSizeLabel];
    
    __weak typeof(self) wself = self;
    self.notificationToken = [[TwitterRealmStore sharedStore].realm addNotificationBlock:^(NSString * _Nonnull notification, RLMRealm * _Nonnull realm) {
        [wself updateRealmFileSizeLabel];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (NSClassFromString(@"XCTest")) return;
    
    if (!self.tweets) {
        // Initial
        TwitterRealmStore *store = [TwitterRealmStore sharedStore];
        
        NSError *error = nil;
        [store realmWithError:&error];
        if (error) {
            /*
             *  なんらかの原因でrealmファイルが開けなくなっている。
             *  - EncryptionKeyが変更された
             *  - 暗号化していないrealmから暗号化に変更した
             *
             *  この場合はrealmファイル自体を削除して再度作成させるしかなさそう。
             */
            NSLog(@"Realm initialization error: %@", error);
#if 0
            NSError *error = nil;
            [store removeRealmFilesWithError:&error];
            NSAssert(!error, @"Fatal error: %@", error);
            if (!error) NSLog(@"Remove realm file. path: %@", store.configuration.path);
#endif
        }
#if 0
        /*
         *  do not backupを追加する
         */
        error = nil;
        [store addSkipBackupAttributeToRealmFilesWithError:&error];
        NSLog(@"add skip backup attribute, error: %@, path: %@", error, store.configuration.path);
#endif
        
        self.tweets = [store fetchAllTweets];
    }
    
    [self.tableView reloadData];
}

- (NSArray *)createTweetValues
{
    return [TwitterRequest requestTweetsWithMaxCount:self.limitOfRequestTweet];
}

- (void)resetState
{
    [TwitterRequest resetState];
}

- (void)updateRealmFileSizeLabel
{
    unsigned long long size = [[TwitterRealmStore sharedStore] realmFileSize];
    NSLog(@"realm size: %lld byte", size);
    self.fileSizeLabel.text = [NSString stringWithFormat:@"Size: %.f KB", (CGFloat)size/1000.];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    Tweet *tw = [self.tweets objectAtIndex:indexPath.row];
    [cell configureContentWithTweet:tw];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TweetCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%@", self.tweets[indexPath.row]);
}

#pragma mark Section header

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.fileSizeLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.;
}

#pragma mark - Button action

- (IBAction)insertTweetsButtonDidPush:(id)sender
{
    __weak typeof(self) wself = self;
    
    NSArray *tweetValues = [self createTweetValues];
    
    [[TwitterRealmStore sharedStore] addTweetsWithTweetJsonObjects:tweetValues completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction, RLMRealm *realm) {
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[tweetValues count]];
        for (NSUInteger i = 0; i < [tweetValues count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [wself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (IBAction)deleteTweetsButtonDidPush:(id)sender
{
    [self resetState];
    
    __weak typeof(self) wself = self;
    [[TwitterRealmStore sharedStore] deleteAllObjectsWithCompletion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction, RLMRealm *realm) {
        [wself.tableView reloadData];
    }];
}

@end
