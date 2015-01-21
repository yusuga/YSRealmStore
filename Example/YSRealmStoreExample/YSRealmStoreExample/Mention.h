//
//  Mention.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/21.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <Realm/Realm.h>

@interface Mention : RLMObject

@property int64_t id;
@property NSString *name;

/* Unavailable Methods */

+ (RLMResults *)allObjects __attribute__((unavailable("Use +allObjectsInRealm: instead.")));
+ (RLMResults *)objectsWhere:(NSString *)predicateFormat, ... __attribute__((unavailable("Use +objectsInRealm:where: instead.")));
+ (RLMResults *)objectsWithPredicate:(NSPredicate *)predicate __attribute__((unavailable("Use +objectsInRealm:withPredicate: instead.")));
+ (instancetype)objectForPrimaryKey:(id)primaryKey __attribute__((unavailable("Use +objectInRealm:forPrimaryKey: instead.")));

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Mention>
RLM_ARRAY_TYPE(Mention)
