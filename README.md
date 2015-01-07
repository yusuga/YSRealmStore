#YSRealmStore

##Usage 

##Initialize

###Use the default Realm
```
YSRealmStore *store = [[YSRealmStore alloc] init];
```

###Use the other Realm
```
NSString *custumDatabaseName = @"database";
YSRealmStore *store = [[YSRealmStore alloc] initWithRealmName:custumDatabaseName];
```

##Write transaction
```
/* Sync */
[store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
    // Can be operated for the realm. (Main thread)
    [realm addOrUpdateObject:[[Tweet alloc] initWithObject:obj]];
}];

/* Async */
[store writeTransactionWithWriteBlock:^(YSRealmWriteTransaction *transaction, RLMRealm *realm) {
    // Can be operated for the realm. (Background thread)
    [realm addOrUpdateObject:[[Tweet alloc] initWithObject:obj]];
} completion:^(YSRealmStore *store, YSRealmWriteTransaction *transaction) {
        
}];
```

##Operation
###Add
```
/* Sync */
[store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
    // Can be operated for the realm. (Main thread)
    return [[Tweet alloc] initWithObject:tweetJsonObj];
}];

/* Async */
[store writeObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
    // Can be operated for the realm. (Background thread)
    return [[Tweet alloc] initWithObject:tweetJsonObj];
} completion:^(YSRealmStore *store, YSRealmOperation *operation) {

}];
```

###Delete
```
/* Sync */
[store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
    // Can be operated for the realm. (Main thread)
    return [Tweet allObjects];
}];

/* Async */
[store deleteObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
    // Can be operated for the realm. (Background thread)
    return [Tweet allObjects];
} completion:^(YSRealmStore *store, YSRealmOperation *operation) {

}];
```

###Fetch
*Fetched object is require primary key.

```
/* Async */
[store fetchObjectsWithObjectsBlock:^id(YSRealmOperation *operation, RLMRealm *realm) {
    // Can be operated for the realm. (Background thread)
    RLMResults *tweets = [Tweet allObjects];
    return [tweets sortedResultsUsingProperty:@"id" ascending:YES];
} completion:^(YSRealmStore *store, YSRealmOperation *operation, RLMRealm *realm, RLMResults *results) {

}];
```

###Cancel operation
```
YSRealmOperation *operation = [store writeObjectsWithObjectsBlock:objectsBlock
                                                       completion:completion];

[operation cancel];
```

## License

    Copyright (c) 2014 Yu Sugawara (https://github.com/yusuga)
    Licensed under the MIT License.

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
