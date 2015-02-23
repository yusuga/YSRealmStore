//
//  Utility.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/02/23.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (void)enumerateAllCase:(void(^)(TwitterRealmStore *store, BOOL sync))block
{
    for (NSInteger persisted = 1; persisted >= 0; persisted--) {
        for (NSInteger sync = 1; sync >= 0; sync--) {
            [[TwitterRealmStore sharedStore] deleteAllObjects];
            @autoreleasepool {
                block(persisted ? [TwitterRealmStore sharedStore] : [TwitterRealmStore createStoreInMemory],
                      sync);
            }
        }
    }
}

@end
