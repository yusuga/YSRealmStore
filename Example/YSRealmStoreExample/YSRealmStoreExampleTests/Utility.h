//
//  Utility.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/02/23.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterRealmStore.h"

@interface Utility : NSObject

+ (void)enumerateAllCase:(void(^)(TwitterRealmStore *store, BOOL sync))block;

@end
