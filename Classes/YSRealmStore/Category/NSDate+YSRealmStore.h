//
//  NSDate+YSRealmStore.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/07.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (YSRealmStore)

+ (NSDate*)ys_realmDefaultDate;
- (BOOL)ys_isRealmDefaultDate;

@end
