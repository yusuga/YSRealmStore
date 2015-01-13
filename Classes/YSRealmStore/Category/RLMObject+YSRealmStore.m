//
//  RLMObject+YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/13.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "RLMObject+YSRealmStore.h"
#import <Realm/RLMSchema.h>
#import <Realm/RLMProperty.h>
#import <Realm/RLMArray.h>

@implementation RLMObject (YSRealmStore)

- (NSDictionary*)ys_allPropertiesAndValues
{
    NSArray *properties = self.objectSchema.properties;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[properties count]];

    for (RLMProperty *property in properties) {
        NSString *key = property.name;
        id obj = [self valueForKey:key];
        if ([obj isKindOfClass:[RLMObject class]]) {
            obj = [obj ys_allPropertiesAndValues];
        } else if ([obj isKindOfClass:[RLMArray class]]) {
            if ([obj count]) {
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[obj count]];
                for (RLMObject *subObj in obj) {
                    id value = [subObj ys_allPropertiesAndValues];
                    if (value) {
                        [arr addObject:value];
                    }
                }
                if ([arr count]) {
                    obj = [NSArray arrayWithArray:arr];
                } else {
                    obj = nil;
                }
            } else {
                obj = nil;
            }
        }
        
        if (obj) {
            [dict setObject:obj forKey:key];
        }
    }    
    
    return [dict count] > 0 ? [NSDictionary dictionaryWithDictionary:dict] : nil;
}

@end
