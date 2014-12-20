//
//  Url.h
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/27.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Realm/Realm.h>

@interface Url : RLMObject

@property NSString *url;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Url>
RLM_ARRAY_TYPE(Url)
