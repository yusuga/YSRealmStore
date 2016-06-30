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

@property (nonatomic) RLMNotificationToken *collectionNotificationToken;

@end

@implementation FetchedResultsController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(self) wself = self;
    self.collectionNotificationToken = [self.tweets addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }
        
        // addNotificationの初期化時の呼び出しはchangeはnilになっている
        if (!change) {
            [wself.tableView reloadData];
            return;
        }
        
        [wself.tableView beginUpdates];
        [wself.tableView deleteRowsAtIndexPaths:[change deletionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [wself.tableView insertRowsAtIndexPaths:[change insertionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [wself.tableView reloadRowsAtIndexPaths:[change modificationsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [wself.tableView endUpdates];
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
        @autoreleasepool {
            RLMRealm *realm = [TwitterRealmStore sharedStoreRealm];
            
            [realm transactionWithBlock:^{
                [realm deleteAllObjects];
            }];
        }
    });
}

@end
