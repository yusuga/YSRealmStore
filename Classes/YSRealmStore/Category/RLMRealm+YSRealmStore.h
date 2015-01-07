//
//  RLMRealm+YSRealmStore.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/07.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "RLMRealm.h"

@interface RLMRealm (YSRealmStore)

+ (instancetype)ys_realmWithFileName:(NSString*)fileName;

@end
