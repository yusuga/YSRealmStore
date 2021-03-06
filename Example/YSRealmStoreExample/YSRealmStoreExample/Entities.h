//
//  Entities.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Realm/Realm.h>
#import "Url.h"
#import "Mention.h"

@interface Entities : RLMObject

@property RLMArray<Url> *urls;
@property RLMArray<Mention> *mentions;

/* Unavailable Methods */

+ (RLMResults *)allObjects __attribute__((unavailable("Use +allObjectsInRealm: instead.")));
+ (RLMResults *)objectsWhere:(NSString *)predicateFormat, ... __attribute__((unavailable("Use +objectsInRealm:where: instead.")));
+ (RLMResults *)objectsWithPredicate:(NSPredicate *)predicate __attribute__((unavailable("Use +objectsInRealm:withPredicate: instead.")));
+ (instancetype)objectForPrimaryKey:(id)primaryKey __attribute__((unavailable("Use +objectInRealm:forPrimaryKey: instead.")));

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Entities>
RLM_ARRAY_TYPE(Entities)
