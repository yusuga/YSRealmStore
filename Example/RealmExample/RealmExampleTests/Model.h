//
//  Model.h
//  RealmExample
//
//  Created by Yu Sugawara on 2015/01/17.
//  Copyright (c) 2015年 Yu Sugawara. All rights reserved.
//

#import <Realm/Realm.h>
#import <UIKit/UIKit.h>
#import "SubModel.h"

@interface Model : RLMObject

@property BOOL boolean;
@property NSInteger integer;
@property int64_t int64;
// @property uint64_t uint64; // Unsupported (realm-cocoa 0.97.1)
@property CGFloat decimal;
@property NSString *string;
@property NSDate *date;
@property NSData *data;
@property SubModel *subModel;
@property RLMArray<SubModel> *arrayModel;

@property NSNumber<RLMInt> *rlmInt;
// @property NSNumber<RLMInt> *rlmUint;
@property NSNumber<RLMBool> *rlmBool;
@property NSNumber<RLMDouble> *rlmDouble;
@property NSNumber<RLMFloat> *rlmFloat;

+ (NSString*)defaultString;
+ (NSDate*)defaultDate;
+ (NSData*)defaultData;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Model>
RLM_ARRAY_TYPE(Model)
