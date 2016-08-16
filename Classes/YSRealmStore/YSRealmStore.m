//
//  YSRealmStore.m
//  YSRealmStoreExample
//
//  Created by Yu Sugawara on 2014/10/26.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSRealmStore.h"
#import <Crashlytics/Crashlytics.h>

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
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    [YSRealmWriteTransaction writeTransactionWithConfiguration:self.configuration
                                                    writeBlock:writeBlock];
    CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
}

- (YSRealmWriteTransaction *)writeTransactionWithWriteBlock:(YSRealmWriteTransactionWriteBlock)writeBlock
                                                 completion:(YSRealmStoreWriteTransactionCompletion)completion
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    return [YSRealmWriteTransaction writeTransactionWithConfiguration:self.configuration
                                                                queue:[[self class] queue]
                                                           writeBlock:writeBlock
                                                           completion:^(YSRealmWriteTransaction *transaction)
            {
                CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
                if (completion) completion(self, transaction, self.realm);
            }];
}

#pragma mark - Operation
#pragma mark Write

- (void)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    [YSRealmOperation writeOperationWithConfiguration:self.configuration
                                         objectsBlock:objectsBlock];
    CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
}

- (YSRealmOperation*)writeObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreOperationCompletion)completion
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    return [YSRealmOperation writeOperationWithConfiguration:self.configuration
                                                       queue:[[self class] queue]
                                                objectsBlock:objectsBlock
                                                  completion:^(YSRealmOperation *operation)
            {
                CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
                if (completion) completion(self, operation, self.realm);
            }];
}

#pragma mark Delete

- (void)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    [YSRealmOperation deleteOperationWithConfiguration:self.configuration
                                          objectsBlock:objectsBlock];
    CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
}

- (YSRealmOperation*)deleteObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                        completion:(YSRealmStoreOperationCompletion)completion
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    return [YSRealmOperation deleteOperationWithConfiguration:self.configuration
                                                        queue:[[self class] queue]
                                                 objectsBlock:objectsBlock
                                                   completion:^(YSRealmOperation *operation)
            {
                CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
                if (completion) completion(self, operation, self.realm);
            }];
}

- (void)deleteAllObjects
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    [YSRealmWriteTransaction writeTransactionWithConfiguration:self.configuration
                                                    writeBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm)
     {
         [realm deleteAllObjects];
     }];
    CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
}

- (void)deleteAllObjectsWithCompletion:(YSRealmStoreWriteTransactionCompletion)completion
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    [YSRealmWriteTransaction writeTransactionWithConfiguration:self.configuration
                                                         queue:[[self class] queue]
                                                    writeBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm)
     {
         [realm deleteAllObjects];
     } completion:^(YSRealmWriteTransaction *transaction) {
         CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
         if (completion) completion(self, transaction, self.realm);
     }];
}

#pragma mark Fetch

- (id)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    id results = [YSRealmOperation fetchOperationWithConfiguration:self.configuration
                                                objectsBlock:objectsBlock];
    CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
    return results;
}

- (YSRealmOperation*)fetchObjectsWithObjectsBlock:(YSRealmOperationObjectsBlock)objectsBlock
                                       completion:(YSRealmStoreFetchOperationCompletion)completion
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    return [YSRealmOperation fetchOperationWithConfiguration:self.configuration
                                                       queue:[[self class] queue]
                                                objectsBlock:objectsBlock
                                                  completion:^(YSRealmOperation *operation, RLMResults *results)
            {
                CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
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
        
        NSURL *compactedURL = [configuration.fileURL URLByAppendingPathComponent:@"compacted"];
        
        // is compacted realm file exist?
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:compactedURL.path]) {
            if (![self deleteRealmFilesWithRealmFilePath:compactedURL.path error:errorPtr]) {
                return NO;
            }
        }
        
        // Create compacted realm file.
        
        if (![realm writeCopyToURL:compactedURL encryptionKey:configuration.encryptionKey error:errorPtr]) {
            return NO;
        }
        
        // Delete original realm files.
        
        if (![self deleteRealmFilesWithRealmFilePath:configuration.fileURL.path error:errorPtr]) {
            return NO;
        }
        
        // Move compacted realm file to original realm file path.
        
        if (![realm writeCopyToURL:configuration.fileURL encryptionKey:configuration.encryptionKey error:errorPtr]) {
            return NO;
        }
        
        // Delete compacted realm file.
        
        if (![self deleteRealmFilesWithRealmFilePath:compactedURL.path error:&error]) {
            return NO;
        }
    }
    
    return YES;
}

- (unsigned long long)realmFileSize
{
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:self.configuration.fileURL.path error:nil] fileSize];;
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

/*
 *  Using Realm with Background App Refresh
 *  https://realm.io/docs/objc/latest/#using-realm-with-background-app-refresh
 */
- (BOOL)addFileProtectionNoneAttributeToRealmFilesWithError:(NSError **)errorPtr
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    for (NSString *path in [self realmFilePaths]) {
        if ([manager fileExistsAtPath:path]) {

            if (![manager setAttributes:@{NSFileProtectionKey : NSFileProtectionNone}
                           ofItemAtPath:path
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
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    BOOL ret = [[self class] deleteRealmFilesWithRealmFilePath:self.configuration.fileURL.path
                                                         error:errorPtr];
    CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
    return ret;
}

+ (BOOL)deleteRealmFilesWithRealmFilePath:(NSString *)realmFilePath
                                    error:(NSError **)errorPtr
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    NSFileManager *manager = [NSFileManager defaultManager];
    
    for (NSString *path in [self realmFilePathsWithRealmFilePath:realmFilePath]) {
        if ([manager fileExistsAtPath:path]) {
            if (![manager removeItemAtPath:path error:errorPtr]) {
                CLS_LOG(@"Failure: (%@)", NSStringFromClass([self class]));
                return NO;
            }
        }
    }
    CLS_LOG(@"Success: (%@)", NSStringFromClass([self class]));
    return YES;
}

- (NSArray<NSString *> *)realmFilePaths
{
    return [[self class] realmFilePathsWithRealmFilePath:self.configuration.fileURL.path];
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
             [path stringByAppendingPathExtension:@"note"],
             [path stringByAppendingPathExtension:@"management"]];
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
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    
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
        CLS_LOG(@"Success: retrieve encryptionKey (%@)", NSStringFromClass([self class]));
        return (__bridge NSData *)dataRef;
    }
    
    CLS_LOG(@"will new create encryptionKey (%@)", NSStringFromClass([self class]));
    
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
    
    CLS_LOG(@"Success: new create encryptionKey (%@)", NSStringFromClass([self class]));
    return keyData;
}

+ (BOOL)deleteDefaultEncryptionKey
{
    return [self deleteEncryptionKeyWithKeychainIdentifier:[self defaultKeychainIdentifier]];
}

+ (BOOL)deleteEncryptionKeyWithKeychainIdentifier:(NSString *)identifier
{
    CLS_LOG(@"will (%@)", NSStringFromClass([self class]));
    
    NSParameterAssert(identifier.length);
    if (!identifier.length) return NO;
    
    CLS_LOG(@"will delete encryption key (%@)", NSStringFromClass([self class]));
    
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
        CLS_LOG(@"Failure: delete encryption key (%@)", NSStringFromClass([self class]));
        return NO;
    }
    CLS_LOG(@"Success: delete encryption key (%@)", NSStringFromClass([self class]));
    return YES;
}

#pragma mark - Utility

+ (NSURL *)realmFileURLWithRealmName:(NSString*)realmName
{
    NSParameterAssert(realmName);
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES)[0];
    path = [path stringByAppendingPathComponent:realmName];
    
    if ([path pathExtension].length == 0) {
        path = [path stringByAppendingPathExtension:@"realm"];
    }
    return [NSURL fileURLWithPath:path];
}

@end
