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
#pragma mark Add

+ (void)addOperationWithRealmPath:(NSString*)realmPath
                     objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope addObjectsWithObjectsBlock:objectsBlock];
}

+ (instancetype)addOperationWithRealmPath:(NSString*)realmPath
                             objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                               completion:(YSRealmCompletion)completion
{
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope addObjectsWithObjectsBlock:objectsBlock completion:completion];
    return ope;
}

#pragma mark Update

+ (void)updateOperationWithRealmPath:(NSString*)realmPath
                         updateBlock:(YSRealmOperationUpdateBlock)updateBlock
{
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope updateObjectsWithUpdateBlock:updateBlock];
}

+ (instancetype)updateOperationWithRealmPath:(NSString*)realmPath
                                 updateBlock:(YSRealmOperationUpdateBlock)updateBlock
                                  completion:(YSRealmCompletion)completion
{
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope updateObjectsWithUpdateBlock:updateBlock completion:completion];
    return ope;
}

#pragma mark Delete

+ (void)deleteOperationWithRealmPath:(NSString*)realmPath
                        objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope deleteObjectsWithObjectsBlock:objectsBlock];
}

+ (instancetype)deleteOperationWithRealmPath:(NSString*)realmPath
                                objectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                  completion:(YSRealmCompletion)completion
{
    YSRealmOperation *ope = [[self alloc] initWithRealmPath:realmPath];
    [ope deleteObjectsWithObjectsBlock:objectsBlock completion:completion];
    return ope;
}

- (instancetype)initWithRealmPath:(NSString*)realmPath
{
    if (self = [super init]) {
        self.realmPath = realmPath;
    }
    return self;
}

- (RLMRealm*)realm
{
    return [RLMRealm realmWithPath:self.realmPath];
}

#pragma mark - Operation
#pragma mark Add

- (void)addObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    DDLogVerbose(@"will addObjects");
    
    [self setExecuting:YES];
    
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    
    id object = objectsBlock(self);
    
    BOOL enabledCollection = [self enabledCollectionObject:object];
    
    if (!self.isCancelled && object != nil) {
        if (enabledCollection) {
            [realm addOrUpdateObjectsFromArray:object];
            DDLogVerbose(@"--addOrUpdateObjectsFromArray");
        } else {
            [realm addOrUpdateObject:object];
            DDLogVerbose(@"--addOrUpdateObject");
        }
        
        if (self.isCancelled) {
            DDLogWarn(@"--will cancelWriteTransaction");
            [realm cancelWriteTransaction];
            DDLogWarn(@"--did cancelWriteTransaction");
        } else {
            [realm commitWriteTransaction];
            DDLogVerbose(@"--commitWriteTransaction");
        }
    } else {
        [realm commitWriteTransaction];
        DDLogVerbose(@"--commitWriteTransaction");
    }
    
    [self setExecuting:NO];
    [self setFinished:YES];
    
    DDLogVerbose(@"did addObjects");
}

- (void)addObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                        completion:(YSRealmCompletion)completion
{
    __weak typeof(self) wself = self;
    dispatch_async([[self class] operationDispatchQueue], ^{
        [wself addObjectsWithObjectsBlock:objectsBlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(wself);
        });
    });
}

#pragma mark Update

- (void)updateObjectsWithUpdateBlock:(YSRealmOperationUpdateBlock)updateBlock
{
    DDLogVerbose(@"will updateObjects");
    
    [self setExecuting:YES];
    
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    
    BOOL updated = updateBlock(self);
    
    if (self.isCancelled && updated) {
        DDLogWarn(@"--will cancelWriteTransaction");
        [realm cancelWriteTransaction];
        DDLogWarn(@"--did cancelWriteTransaction");
    } else {
        [realm commitWriteTransaction];
        DDLogVerbose(@"--commitWriteTransaction");
    }
    
    [self setExecuting:NO];
    [self setFinished:YES];
    
    DDLogVerbose(@"did updateObjects");
}

- (void)updateObjectsWithUpdateBlock:(YSRealmOperationUpdateBlock)updateBlock
                          completion:(YSRealmCompletion)completion
{
    __weak typeof(self) wself = self;
    dispatch_async([[self class] operationDispatchQueue], ^{
        [wself updateObjectsWithUpdateBlock:updateBlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(wself);
        });
    });
}

#pragma mark Delete

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    DDLogVerbose(@"will deleteObjects");
    
    [self setExecuting:YES];
    
    RLMRealm *realm = [self realm];
    [realm beginWriteTransaction];
    
    id object = objectsBlock(self);
    
    BOOL enabledCollection = [self enabledCollectionObject:object];
    
    if (!self.isCancelled && object != nil) {
        if (enabledCollection) {
            [realm deleteObjects:object];
            DDLogVerbose(@"--deleteObjects");
        } else {
            [realm deleteObject:object];
            DDLogVerbose(@"--deleteObject");
        }
        
        if (self.isCancelled) {
            DDLogWarn(@"--will cancelWriteTransaction");
            [realm cancelWriteTransaction];
            DDLogWarn(@"--did cancelWriteTransaction");
        } else {
            [realm commitWriteTransaction];
            DDLogVerbose(@"--commitWriteTransaction");
        }
    } else {
        [realm commitWriteTransaction];
        DDLogVerbose(@"--commitWriteTransaction");
    }
    
    [self setExecuting:NO];
    [self setFinished:YES];
    
    DDLogVerbose(@"did deleteObjects");
}

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                           completion:(YSRealmCompletion)completion
{
    __weak typeof(self) wself = self;
    dispatch_async([[self class] operationDispatchQueue], ^{
        [wself deleteObjectsWithObjectsBlock:objectsBlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(wself);
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

#pragma mark - Utility

- (BOOL)enabledCollectionObject:(id)object
{
    return [object respondsToSelector:@selector(count)] && [object count] > 0;
}

@end
