//
//  RLMObject+YSRealmStore.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/13.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "RLMObject.h"

@interface RLMObject (YSRealmStore)

- (NSDictionary*)ys_allPropertiesAndValues;

@end
