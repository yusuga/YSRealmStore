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

- (RLMRealmConfiguration *)configuration
{
    @synchronized(_configuration) {
        return [_configuration copy];
    }
}

- (RLMRealm *)realm
{
    return [self realmWithError:nil];
}

- (RLMRealm *)realmWithError:(NSError **)errorPtr
{
    if ([self inMemory]) {
        if (!self.realmInMemory) {
            // Hold onto a strong reference
            self.realmInMemory = [RLMRealm realmWithConfiguration:self.configuration error:errorPtr];
        }
        return self.realmInMemory;
    } else {
        return [RLMRealm realmWithConfiguration:self.configuration error:errorPtr];
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
    [YSRealmWriteTransaction writeTransactionWithConfiguration:self.configuration
                                                    writeBlock:writeBlock];
}

- (YSRealmWriteTransaction *)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                                 completion:(YSRealmStoreWriteTransactionCompletion)completion
{
    return [YSRealmWriteTransaction writeTransactionWithConfiguration:self.configuration
                                                                queue:[[self class] queue]
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
    [YSRealmOperation writeOperationWithConfiguration:self.configuration
                                         objectsBlock:objectsBlock];
}

- (YSRealmOperation*)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreOperationCompletion)completion
{
    return [YSRealmOperation writeOperationWithConfiguration:self.configuration
                                                       queue:[[self class] queue]
                                                objectsBlock:objectsBlock
                                                  completion:^(YSRealmOperation *operation)
            {
                if (completion) completion(self, operation, self.realm);
            }];
}

#pragma mark Delete

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    [YSRealmOperation deleteOperationWithConfiguration:self.configuration
                                          objectsBlock:objectsBlock];
}

- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmStoreOperationCompletion)completion
{
    return [YSRealmOperation deleteOperationWithConfiguration:self.configuration
                                                        queue:[[self class] queue]
                                                 objectsBlock:objectsBlock
                                                   completion:^(YSRealmOperation *operation)
            {
                if (completion) completion(self, operation, self.realm);
            }];
}

- (void)deleteAllObjects
{
    [YSRealmWriteTransaction writeTransactionWithConfiguration:self.configuration
                                                    writeBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm)
     {
         [realm deleteAllObjects];
     }];
}

- (void)deleteAllObjectsWithCompletion:(YSRealmStoreWriteTransactionCompletion)completion
{
    [YSRealmWriteTransaction writeTransactionWithConfiguration:self.configuration
                                                         queue:[[self class] queue]
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
    return [YSRealmOperation fetchOperationWithConfiguration:self.configuration
                                                objectsBlock:objectsBlock];
}

- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion
{
    return [YSRealmOperation fetchOperationWithConfiguration:self.configuration
                                                       queue:[[self class] queue]
                                                objectsBlock:objectsBlock
                                                  completion:^(YSRealmOperation *operation, RLMResults *results)
            {
                if (completion) completion(self, operation, self.realm, results);
            }];
}

#pragma mark - File

+ (BOOL)compactRealmFileWithConfiguration:(RLMRealmConfiguration *)configuration
                                    error:(NSError **)errorPtr
{
    @autoreleasepool {
        NSError *error = nil;
        
        RLMRealm *realm = [RLMRealm realmWithConfiguration:configuration error:&error];
        if (error) {
            if (errorPtr) {
                *errorPtr = error;
            }
            return NO;
        }
        
        NSString *compactedRealmPath = [configuration.path stringByAppendingPathExtension:@"compacted"];
        
        // is compacted realm file exist?
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:compactedRealmPath]) {
            if (![self deleteRealmFilesWithRealmFilePath:compactedRealmPath error:errorPtr]) {
                return NO;
            }
        }
        
        // Create compacted realm file.
        
        if (configuration.encryptionKey) {
            if (![realm writeCopyToPath:compactedRealmPath encryptionKey:configuration.encryptionKey error:errorPtr]) {
                return NO;
            }
        } else {
            if (![realm writeCopyToPath:compactedRealmPath error:errorPtr]) {
                return NO;
            }
        }
        
        // Delete original realm files.
        
        if (![self deleteRealmFilesWithRealmFilePath:configuration.path error:errorPtr]) {
            return NO;
        }
        
        // Move compacted realm file to original realm file path.
        
        if (configuration.encryptionKey) {
            if (![realm writeCopyToPath:configuration.path encryptionKey:configuration.encryptionKey error:errorPtr]) {
                return NO;
            }
        } else {
            if (![realm writeCopyToPath:configuration.path error:errorPtr]) {
                return NO;
            }
        }
        
        // Delete compacted realm file.
        
        if (![self deleteRealmFilesWithRealmFilePath:compactedRealmPath error:&error]) {
            return NO;
        }
    }
    
    return YES;
}

- (unsigned long long)realmFileSize
{
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:self.configuration.path error:nil] fileSize];;
}

/*
 *  Technical Q&A QA1719
 *  How do I prevent files from being backed up to iCloud and iTunes?
 *  Q:  My app has a number of files that need to be stored on the device permanently for my app to function properly offline. However, those files do not contain user data and don't need to be backed up. How can I prevent them from being backed up?
 *  https://developer.apple.com/library/ios/qa/qa1719/_index.html
 */
- (BOOL)addSkipBackupAttributeToRealmFilesWithError:(NSError **)errorPtr
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    for (NSString *path in [self realmFilePaths]) {
        if ([manager fileExistsAtPath:path]) {
            NSURL *URL = [NSURL fileURLWithPath:path];
            
            if (![URL setResourceValue:@YES
                                forKey:NSURLIsExcludedFromBackupKey
                                 error:errorPtr])
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)deleteRealmFilesWithError:(NSError **)errorPtr
{
    return [[self class] deleteRealmFilesWithRealmFilePath:self.configuration.path
                                                     error:errorPtr];
}

+ (BOOL)deleteRealmFilesWithRealmFilePath:(NSString *)realmFilePath
                                    error:(NSError **)errorPtr
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    for (NSString *path in [self realmFilePathsWithRealmFilePath:realmFilePath]) {
        if ([manager fileExistsAtPath:path]) {
            if (![manager removeItemAtPath:path error:errorPtr]) {
                return NO;
            }
        }
    }
    return YES;
}

- (NSArray<NSString *> *)realmFilePaths
{
    return [[self class] realmFilePathsWithRealmFilePath:self.configuration.path];
}

+ (NSArray<NSString *> *)realmFilePathsWithRealmFilePath:(NSString *)path
{
    return [@[path] arrayByAddingObjectsFromArray:[self auxiliaryRealmFilePathsWithRealmFilePath:path]];
}

/**
 *  https://realm.io/docs/objc/latest/#auxiliary-realm-files
 */
+ (NSArray<NSString *> *)auxiliaryRealmFilePathsWithRealmFilePath:(NSString *)path
{
    return @[[path stringByAppendingPathExtension:@"lock"],
             [path stringByAppendingPathExtension:@"log"],
             [path stringByAppendingPathExtension:@"log_a"],
             [path stringByAppendingPathExtension:@"log_b"],
             [path stringByAppendingPathExtension:@"note"]];
}

#pragma mark - Encryption

+ (NSString *)defaultKeychainIdentifier
{
    return [NSBundle mainBundle].bundleIdentifier;
}

+ (NSData *)defaultEncryptionKey
{
    return [self encryptionKeyForKeychainIdentifier:[self defaultKeychainIdentifier]];
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

+ (BOOL)deleteDefaultEncryptionKey
{
    return [self deleteEncryptionKeyWithKeychainIdentifier:[self defaultKeychainIdentifier]];
}

+ (BOOL)deleteEncryptionKeyWithKeychainIdentifier:(NSString *)identifier
{
    NSParameterAssert(identifier.length);
    if (!identifier.length) return NO;
    
    // Identifier for our keychain entry - should be unique for your application
    NSData *tag = [[NSData alloc] initWithBytesNoCopy:(void *)identifier.UTF8String
                                               length:strlen(identifier.UTF8String) + 1
                                         freeWhenDone:NO];
    
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @512,
                            (__bridge id)kSecReturnData: @YES};
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        return NO;
    }
    
    return YES;
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

@end
