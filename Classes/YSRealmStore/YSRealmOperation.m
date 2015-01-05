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
@property (nonatomic) RLMNotificationToken *notificationToken;

@end

@implementation YSRealmOperation
@synthesize cancelled = _cancelled;

#pragma mark - Public
#pragma mark Write

+ (void)writeOperationWithRealmPath:(NSString*)realmPath
                       objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope writeObjectsWithObjectsBlock:objectsBlock];
}

+ (instancetype)writeOperationWithRealmPath:(NSString*)realmPath
                               objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                 completion:(YSRealmOperationCompletion)completion
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope writeObjectsWithObjectsBlock:objectsBlock completion:completion];
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
                                objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                  completion:(YSRealmOperationCompletion)completion
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope deleteObjectsWithObjectsBlock:objectsBlock completion:completion];
    return ope;
}

#pragma mark Fetch

+ (instancetype)fetchOperationWithRealmPath:(NSString*)realmPath
                               objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                 completion:(YSRealmOperationFetchCompletion)completion
{
    NSParameterAssert(objectsBlock != NULL);
    
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope fetchOperationWithObjectsBlock:objectsBlock completion:completion];
    return ope;
}

#pragma mark - Init

- (instancetype)initWithRealmPath:(NSString*)realmPath
{
    if (self = [super init]) {
        NSParameterAssert(realmPath != nil);
        self.realmPath = realmPath;
    }
    return self;
}

- (RLMRealm*)realm
{
    return [RLMRealm realmWithPath:self.realmPath];
}

#pragma mark - Operation
#pragma mark Write

- (BOOL)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    return [self writeObjectsWithObjectsBlock:objectsBlock
                                         type:YSRealmOperationTypeAddOrUpdate];
}

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                          completion:(YSRealmOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    
    self.notificationToken = [[self realm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [realm removeNotification:wself.notificationToken];
        if (completion) completion(wself);
    }];
    
    dispatch_async([[self class] operationQueue], ^{
        if (![wself writeObjectsWithObjectsBlock:objectsBlock]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(wself);
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

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                           completion:(YSRealmOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    
    self.notificationToken = [[self realm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [realm removeNotification:wself.notificationToken];
        if (completion) completion(wself);
    }];
    
    dispatch_async([[self class] operationQueue], ^{
        if (![wself deleteObjectsWithObjectsBlock:objectsBlock]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(wself);
            });
        };
    });
}

#pragma mark Fetch

- (void)fetchOperationWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                            completion:(YSRealmOperationFetchCompletion)completion
{
    __weak typeof(self) wself = self;
    dispatch_async([[self class] operationQueue], ^{
        NSMutableArray *values;
        Class resultClass;
        NSString *primaryKey;
        
        id results = objectsBlock ? objectsBlock(wself) : nil;
        
        if (!wself.isCancelled && results) {
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
            if (!wself.isCancelled && [values count] > 0 && resultClass && primaryKey) {
                results = [resultClass objectsWhere:@"%K IN %@", primaryKey, values];
            }            
            
            if (completion) completion(wself, results);
        });
    });
}

#pragma mark Private

- (BOOL)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                type:(YSRealmOperationType)type
{
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    
    id object = objectsBlock ? objectsBlock(self) : nil;
    
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
    [self setCancelled:YES];
}

- (void)setCancelled:(BOOL)cancelled
{
    @synchronized(self) {
        _cancelled = cancelled;
    }
}

- (BOOL)isCancelled
{
    @synchronized(self) {
        return _cancelled;
    }
}

#pragma mark - Queue

+ (dispatch_queue_t)operationQueue
{
    static dispatch_queue_t __queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __queue = dispatch_queue_create("jp.co.picos.realm.operation.queue", NULL);
    });
    return __queue;
}

@end
