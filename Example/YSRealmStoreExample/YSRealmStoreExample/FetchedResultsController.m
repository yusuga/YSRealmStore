//
//  FetchedResultsController.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2016/03/03.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import "FetchedResultsController.h"
#import "TwitterRealmStore.h"

/*
 *  Fine-grained notificationsがサポートされる待ち。
 *  https://github.com/realm/realm-cocoa/issues/601
 */

@interface FetchedResultsController ()

@property (nonatomic) RLMNotificationToken *notificationToken;

@end

@implementation FetchedResultsController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(self) wself = self;
    self.notificationToken = [self.tweets addNotificationBlock:^(RLMResults * _Nullable results, NSError * _Nullable error) {
        [wself.tableView reloadData];
    }];
}

- (void)insertTweets
{
    NSArray *tweetValues = [self createTweetValues];
    
    RLMRealm *realm = [TwitterRealmStore sharedStoreRealm];
    [realm transactionWithBlock:^{
        for (NSDictionary *value in tweetValues) {
            [realm addOrUpdateObject:[[Tweet alloc] initWithValue:value]];
        }
    }];
}

#pragma mark - Button action

- (IBAction)insertButtonDidPush:(id)sender
{
    [self insertTweets];
}

- (IBAction)asyncInsertButtonDidPush:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self insertTweets];
    });
}

- (IBAction)deleteTweetsButtonDidPush:(id)sender
{
    [self resetState];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RLMRealm *realm = [TwitterRealmStore sharedStoreRealm];
        
        [realm transactionWithBlock:^{
            [realm deleteAllObjects];
        }];
    });
}

@end
