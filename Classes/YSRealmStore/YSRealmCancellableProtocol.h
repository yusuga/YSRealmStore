//
//  YSRealmCancellableProtocol.h
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2016/02/29.
//  Copyright © 2016年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YSRealmCancellableProtocol <NSObject>

- (void)cancel;
- (BOOL)isCancelled;

@end
