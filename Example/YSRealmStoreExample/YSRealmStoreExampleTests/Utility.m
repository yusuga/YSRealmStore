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
    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger sync = 1; sync >= 0; sync--) {
            @autoreleasepool {
                TwitterRealmStore *store;
                switch (i) {
                    case 0:
                        store = [TwitterRealmStore sharedStore];
                        break;
                    case 1:
                        store = [TwitterRealmStore createStoreInMemory];
                        break;
                    case 2:
                        store = [TwitterRealmStore createEncryptionStore];
                        break;
                    default:
                        break;
                }
                [store deleteAllObjects];
                
                block(store, sync);
            }
        }
    }
}

@end
