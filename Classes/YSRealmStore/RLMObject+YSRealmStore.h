//
//  RLMObject+YSRealm.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "RLMObject.h"

@interface RLMObject (YSRealmStore)

+ (id)ys_objectOrNilWithDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;
- (id)ys_objectOrNilWithDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;

+ (NSString *)ys_stringWithDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;
- (NSString *)ys_stringWithDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;

@end
