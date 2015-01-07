//
//  RLMRealm+YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2015/01/07.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import "RLMRealm+YSRealmStore.h"

@implementation RLMRealm (YSRealmStore)

+ (instancetype)ys_realmWithFileName:(NSString*)fileName
{
    NSString *path = [self ys_documentDirectoryPathForFileName:fileName];
    if ([path pathExtension].length == 0) {
        path = [path stringByAppendingPathExtension:@"realm"];
    }
    return [self realmWithPath:path];
}

#pragma mark - Private

+ (NSString*)ys_documentDirectoryPathForFileName:(NSString*)fileName
{
    NSParameterAssert(fileName);
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES)[0];
    return [path stringByAppendingPathComponent:fileName];
}

@end
