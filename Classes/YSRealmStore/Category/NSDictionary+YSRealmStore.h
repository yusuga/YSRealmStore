//
//  NSDictionary+YSRealmStore.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/07.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (YSRealmStore)

- (id)ys_objectOrNilForKey:(NSString *)key;
- (NSString*)ys_stringOrDefaultStringForKey:(NSString *)key;

@end
