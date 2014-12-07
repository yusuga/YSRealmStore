//
//  YSRealmOperation.m
//  YSRealmExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSRealmOperation.h"

@interface YSRealmOperation ()

@property (copy, nonatomic) NSString *realmPath;

@end

@implementation YSRealmOperation
@synthesize cancelled = _cancelled;
@synthesize executing = _executing;
@synthesize finished = _finished;

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

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    [self setExecuting:YES];
    
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    
    id object = objectsBlock(self);
    
    if (object != nil) {
        if (![object conformsToProtocol:@protocol(NSFastEnumeration)]) {
            object = @[object];
        }
        [realm addOrUpdateObjectsFromArray:object];
        
        if (self.isCancelled) {
            [realm cancelWriteTransaction];
        } else {
            [realm commitWriteTransaction];
        }
    } else if (self.isCancelled) {
        [realm cancelWriteTransaction];
    } else {
        [realm commitWriteTransaction];
    }
    
    [self setExecuting:NO];
    [self setFinished:YES];
}

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                          completion:(YSRealmOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    dispatch_async([[self class] operationDispatchQueue], ^{
        [wself writeObjectsWithObjectsBlock:objectsBlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(wself);
        });
    });
}

#pragma mark Delete

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    [self setExecuting:YES];
    
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    
    id object = objectsBlock(self);
    
    if (!self.isCancelled && object != nil) {
        if (![object conformsToProtocol:@protocol(NSFastEnumeration)]) {
            object = @[object];
        }
        [realm deleteObjects:object];
        
        if (self.isCancelled) {
            [realm cancelWriteTransaction];
        } else {
            [realm commitWriteTransaction];
        }
    } else {
        [realm commitWriteTransaction];
    }
    
    [self setExecuting:NO];
    [self setFinished:YES];
}

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                           completion:(YSRealmOperationCompletion)completion
{
    __weak typeof(self) wself = self;
    dispatch_async([[self class] operationDispatchQueue], ^{
        [wself deleteObjectsWithObjectsBlock:objectsBlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(wself);
        });
    });
}

#pragma mark Fetch

- (void)fetchOperationWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                            completion:(YSRealmOperationFetchCompletion)completion
{
    __weak typeof(self) wself = self;
    dispatch_async([[self class] operationDispatchQueue], ^{
        [wself setExecuting:YES];
        
        NSMutableArray *values;
        Class resultClass;
        id results = objectsBlock(wself);
        
        if (!wself.isCancelled && results != nil) {
            if (![results conformsToProtocol:@protocol(NSFastEnumeration)]) {
                results = @[results];
            }
            NSParameterAssert([results isKindOfClass:[NSArray class]]
                              || [results isKindOfClass:[RLMArray class]]
                              || [results isKindOfClass:[RLMResults class]]);
            
            values = [NSMutableArray arrayWithCapacity:[results count]];
            RLMObject *result = [results firstObject];
            resultClass = [result class];
            
            if (result && resultClass) {
                NSString *primaryKey = [resultClass primaryKey];
                
                for (RLMObject *obj in results) {
                    NSParameterAssert([obj isKindOfClass:[RLMObject class]]);
                    [values addObject:[obj valueForKey:primaryKey]];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *results = [NSMutableArray arrayWithCapacity:[values count]];
            
            if (!self.isCancelled && resultClass != NULL) {
                for (id value in values) {
                    [results addObject:[resultClass objectForPrimaryKey:value]];
                }
            }
            
            [wself setExecuting:NO];
            [wself setFinished:YES];
            
            if (completion) completion(wself, [NSArray arrayWithArray:results]);
        });
    });
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

- (void)setExecuting:(BOOL)executing
{
    @synchronized(self) {
        _executing = executing;
    }
}

- (BOOL)isExecuting
{
    @synchronized(self) {
        return _executing;
    }
}

- (void)setFinished:(BOOL)finished
{
    @synchronized(self) {
        _finished = finished;
    }
}

- (BOOL)isFinished
{
    @synchronized(self) {
        return _finished;
    }
}

#pragma mark - Queue

+ (dispatch_queue_t)operationDispatchQueue
{
    static dispatch_queue_t __queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __queue = dispatch_queue_create("jp.co.picos.realm.operation.queue", NULL);
    });
    return __queue;
}

@end
