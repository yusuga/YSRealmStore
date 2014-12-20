//
//  Entities.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Realm/Realm.h>
#import "Url.h"

@interface Entities : RLMObject

@property RLMArray<Url> *urls;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Entities>
RLM_ARRAY_TYPE(Entities)
