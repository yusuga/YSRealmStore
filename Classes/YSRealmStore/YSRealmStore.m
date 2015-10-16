//
//  YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSRealmStore.h"

@interface YSRealmStore ()

@property (nonatomic, readwrite) RLMRealmConfiguration *configuration;
@property (nonatomic) RLMRealm *realmInMemory;

@end

@implementation YSRealmStore

#pragma mark - Life cycle

- (instancetype)initWithConfiguration:(RLMRealmConfiguration *)configuration
{
    if (self = [super init]) {
        self.configuration = configuration;
        
        if ([self inMemory]) {
            [self realm]; // Init realm in memory
        }
    }
    return self;
}

#pragma mark -

- (RLMRealm *)realm
{
    if ([self inMemory]) {
        if (!self.realmInMemory) {
            // Hold onto a strong reference
            self.realmInMemory = [RLMRealm realmWithConfiguration:self.configuration error:nil];
        }
        return self.realmInMemory;
    } else {
        return [RLMRealm realmWithConfiguration:self.configuration error:nil];
    }
}


- (BOOL)inMemory
{
    NSParameterAssert(self.configuration);
    return self.configuration.inMemoryIdentifier != nil;
}

- (BOOL)encrypted
{
    NSParameterAssert(self.configuration);
    return self.configuration.encryptionKey != nil;
}

+ (dispatch_queue_t)queue
{
    static dispatch_queue_t __queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __queue = dispatch_queue_create("com.yusuga.YSRealmStore.queue", NULL);
    });
    return __queue;
}

#pragma mark - Transaction

- (void)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
{
    [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realm.path
                                                  inMemory:[self inMemory]
                                                writeBlock:writeBlock];
}

- (YSRealmWriteTransaction *)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                                 completion:(YSRealmStoreWriteTransactionCompletion)completion
{
    return [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realm.path
                                                            queue:[YSRealmStore queue]
                                                         inMemory:[self inMemory]
                                                       writeBlock:writeBlock
                                                       completion:^(YSRealmWriteTransaction *transaction)
            {
                if (completion) completion(self, transaction, self.realm);
            }];
}

#pragma mark - Operation
#pragma mark Write

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    [YSRealmOperation writeOperationWithRealmPath:self.realm.path
                                         inMemory:[self inMemory]
                                     objectsBlock:objectsBlock];
}

- (YSRealmOperation*)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreOperationCompletion)completion
{
    return [YSRealmOperation writeOperationWithRealmPath:self.realm.path
                                                   queue:[YSRealmStore queue]
                                                inMemory:[self inMemory]
                                            objectsBlock:objectsBlock
                                              completion:^(YSRealmOperation *operation)
            {
                if (completion) completion(self, operation, self.realm);
            }];
}

#pragma mark Delete

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    [YSRealmOperation deleteOperationWithRealmPath:self.realm.path
                                          inMemory:[self inMemory]
                                      objectsBlock:objectsBlock];
}

- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmStoreOperationCompletion)completion
{
    return [YSRealmOperation deleteOperationWithRealmPath:self.realm.path
                                                    queue:[YSRealmStore queue]
                                                 inMemory:[self inMemory]
                                             objectsBlock:objectsBlock
                                               completion:^(YSRealmOperation *operation)
            {
                if (completion) completion(self, operation, self.realm);
            }];
}

- (void)deleteAllObjects
{
    [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realm.path
                                                  inMemory:[self inMemory]
                                                writeBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm)
     {
         [realm deleteAllObjects];
     }];
}

- (void)deleteAllObjectsWithCompletion:(YSRealmStoreWriteTransactionCompletion)completion
{
    [YSRealmWriteTransaction writeTransactionWithRealmPath:self.realm.path
                                                     queue:[YSRealmStore queue]
                                                  inMemory:[self inMemory]
                                                writeBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm)
     {
         [realm deleteAllObjects];
     } completion:^(YSRealmWriteTransaction *transaction) {
         if (completion) completion(self, transaction, self.realm);
     }];
}

#pragma mark Fetch

- (id)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    return [YSRealmOperation fetchOperationWithRealmPath:self.realm.path
                                                inMemory:[self inMemory]
                                            objectsBlock:objectsBlock];
}

- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion
{
    return [YSRealmOperation fetchOperationWithRealmPath:self.realm.path
                                                   queue:[YSRealmStore queue]
                                                inMemory:[self inMemory]
                                            objectsBlock:objectsBlock
                                              completion:^(YSRealmOperation *operation, RLMResults *results)
            {
                if (completion) completion(self, operation, self.realm, results);
            }];
}

#pragma mark - Utility

+ (NSString*)realmPathWithFileName:(NSString*)fileName
{
    NSParameterAssert(fileName);
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES)[0];
    path = [path stringByAppendingPathComponent:fileName];
    
    if ([path pathExtension].length == 0) {
        path = [path stringByAppendingPathExtension:@"realm"];
    }
    return path;
}

+ (NSData *)defaultEncryptionKey
{
    return [self encryptionKeyForKeychainIdentifier:[NSBundle mainBundle].bundleIdentifier];
}

/**
 *  realm-cocoa - examples - Encryption - getKey
 *  https://github.com/realm/realm-cocoa/blob/master/examples/ios/objc/Encryption/LabelViewController.m
 */
+ (NSData *)encryptionKeyForKeychainIdentifier:(NSString *)identifier
{
    // Identifier for our keychain entry - should be unique for your application
    NSData *tag = [[NSData alloc] initWithBytesNoCopy:(void *)identifier.UTF8String
                                               length:strlen(identifier.UTF8String) + 1
                                         freeWhenDone:NO];
    
    // First check in the keychain for an existing key
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @512,
                            (__bridge id)kSecReturnData: @YES};
    
    CFTypeRef dataRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataRef);
    if (status == errSecSuccess) {
        return (__bridge NSData *)dataRef;
    }
    
    // No pre-existing key from this application, so generate a new one
    uint8_t buffer[64];
    SecRandomCopyBytes(kSecRandomDefault, 64, buffer);
    NSData *keyData = [[NSData alloc] initWithBytes:buffer length:sizeof(buffer)];
    
    // Store the key in the keychain
    query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
              (__bridge id)kSecAttrApplicationTag: tag,
              (__bridge id)kSecAttrKeySizeInBits: @512,
              (__bridge id)kSecValueData: keyData};
    
    status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    NSAssert(status == errSecSuccess, @"Failed to insert new key in the keychain");
    
    return keyData;
}

@end
