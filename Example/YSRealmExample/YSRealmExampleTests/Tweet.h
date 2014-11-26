//
//  Tweet.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Realm/Realm.h>
#import "User.h"
#import "Entities.h"

@interface Tweet : RLMObject

@property int64_t id;
@property NSString *text;
@property User *user;
@property Entities *entities;
@property RLMArray<User> *watchers;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Tweet>
RLM_ARRAY_TYPE(Tweet)
