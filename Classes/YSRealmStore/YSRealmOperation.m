//
//  YSRealmOperation.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSRealmOperation.h"

typedef NS_ENUM(NSUInteger, YSRealmOperationType) {
    YSRealmOperationTypeAddOrUpdate,
    YSRealmOperationTypeDelete,
};

@interface YSRealmOperation ()

@property (copy, nonatomic) NSString *realmPath;

@property (readwrite, getter=isCancelled) BOOL cancelled;

@end

@implementation YSRealmOperation

#pragma mark - Life cycle

- (instancetype)initWithRealmPath:(NSString*)realmPath
{
    if (self = [super init]) {
        NSParameterAssert(realmPath != nil);
        self.realmPath = realmPath;
    }
    return self;
}

- (void)dealloc
{
    DDLogInfo(@"%s", __func__);
}

#pragma mark - Utility

- (RLMRealm*)realm
{
    return [RLMRealm realmWithPath:self.realmPath];
}

#pragma mark - Operation
#pragma mark Write

+ (void)writeOperationWithRealmPath:(NSString*)realmPath
                       objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope writeObjectsWithObjectsBlock:objectsBlock];
}

+ (instancetype)writeOperationWithRealmPath:(NSString*)realmPath
                                      queue:(dispatch_queue_t)queue
                               objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                 completion:(YSRealmOperationCompletion)completion
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope writeObjectsWithQueue:queue objectsBlock:objectsBlock completion:completion];
    return ope;
}

#pragma mark Delete

+ (void)deleteOperationWithRealmPath:(NSString*)realmPath
                        objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope deleteObjectsWithObjectsBlock:objectsBlock];
}

+ (instancetype)deleteOperationWithRealmPath:(NSString*)realmPath
                                       queue:(dispatch_queue_t)queue
                                objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                  completion:(YSRealmOperationCompletion)completion
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope deleteObjectsWithQueue:queue objectsBlock:objectsBlock completion:completion];
    return ope;
}

#pragma mark Fetch

+ (RLMResults*)fetchOperationWithRealmPath:(NSString*)realmPath
                              objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    return [ope fetchOperationWithObjectsBlock:objectsBlock];
}

+ (instancetype)fetchOperationWithRealmPath:(NSString*)realmPath
                                      queue:(dispatch_queue_t)queue
                               objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                 completion:(YSRealmOperationFetchCompletion)completion
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope fetchOperationWithQueue:queue objectsBlock:objectsBlock completion:completion];
    return ope;
}

#pragma mark - Operation Private
#pragma mark Write

- (BOOL)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    return [self writeObjectsWithObjectsBlock:objectsBlock
                                         type:YSRealmOperationTypeAddOrUpdate];
}

- (void)writeObjectsWithQueue:(dispatch_queue_t)queue
                 objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                          completion:(YSRealmOperationCompletion)completion
{
    __block RLMNotificationToken *token = [[self realm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [realm removeNotification:token];
        if (completion) completion(self);
    }];
    
    dispatch_async(queue, ^{
        if (![self writeObjectsWithObjectsBlock:objectsBlock]) {
            [[self realm] removeNotification:token];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(self);
            });
        }
    });
}

#pragma mark Delete

- (BOOL)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    return [self writeObjectsWithObjectsBlock:objectsBlock
                                         type:YSRealmOperationTypeDelete];
}

- (void)deleteObjectsWithQueue:(dispatch_queue_t)queue
                  objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                    completion:(YSRealmOperationCompletion)completion
{
    __block RLMNotificationToken *token = [[self realm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [realm removeNotification:token];
        if (completion) completion(self);
    }];
    
    dispatch_async(queue, ^{
        if (![self deleteObjectsWithObjectsBlock:objectsBlock]) {
            [[self realm] removeNotification:token];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(self);
            });
        };
    });
}

#pragma mark Fetch

- (RLMResults*)fetchOperationWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    return objectsBlock ? objectsBlock(self, [self realm]) : nil;
}

- (void)fetchOperationWithQueue:(dispatch_queue_t)queue
                   objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                     completion:(YSRealmOperationFetchCompletion)completion
{
    dispatch_async(queue, ^{
        NSMutableArray *values;
        Class resultClass;
        NSString *primaryKey;
        
        id results = objectsBlock ? objectsBlock(self, [self realm]) : nil;
        
        if (!self.isCancelled && results) {
            if (![results conformsToProtocol:@protocol(NSFastEnumeration)]) {
                results = @[results];
            }
            NSParameterAssert([results isKindOfClass:[NSArray class]]
                              || [results isKindOfClass:[RLMArray class]]
                              || [results isKindOfClass:[RLMResults class]]);
            
            values = [NSMutableArray arrayWithCapacity:[results count]];
            RLMObject *result = [results firstObject];
            resultClass = [result class];
            primaryKey = [resultClass primaryKey];
            
            if (result) {
                if (resultClass && primaryKey) {
                    for (RLMObject *obj in results) {
                        NSParameterAssert([obj isKindOfClass:[RLMObject class]]);
                        [values addObject:[obj valueForKey:primaryKey]];
                    }
                } else {
                    DDLogWarn(@"%s; Primary key is required; class = %@, primaryKey = %@", __func__, NSStringFromClass(resultClass), primaryKey);
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            RLMResults *results;
            if (!self.isCancelled && [values count] > 0 && resultClass && primaryKey) {
                results = [resultClass objectsInRealm:[self realm]
                                                where:@"%K IN %@", primaryKey, values];
            }            
            
            if (completion) completion(self, results);
        });
    });
}

#pragma mark Private

- (BOOL)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                type:(YSRealmOperationType)type
{
    RLMRealm *realm = [self realm];
    
    [realm beginWriteTransaction];
    
    id object = objectsBlock ? objectsBlock(self, realm) : nil;
    
    if (object) {
        if (![object conformsToProtocol:@protocol(NSFastEnumeration)]) {
            object = @[object];
        }
        switch (type) {
            case YSRealmOperationTypeAddOrUpdate:
                [realm addOrUpdateObjectsFromArray:object];
                break;
            case YSRealmOperationTypeDelete:
                [realm deleteObjects:object];
                break;
            default:
                NSAssert1(false, @"Unsupported operation type = %zd;", type);
                break;
        }
    }
    
    if (self.isCancelled) {
        [realm cancelWriteTransaction];
        return NO;
    } else {
        [realm commitWriteTransaction];
        return YES;
    }
}

#pragma mark - State

- (void)cancel
{
    self.cancelled = YES;
}

@end
