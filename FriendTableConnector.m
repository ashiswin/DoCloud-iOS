//
//  FriendTableConnector.m
//  docloud
//
//  Created by Isaac Ravindran on 9/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "FriendTableConnector.h"

@implementation FriendTableConnector
- (id)init:(NSString*)uid {
    if(self = [super init]) {
        tableName = [NSString stringWithFormat:@"%@Friends", uid];
        db = [DatabaseHelper getDatabase];
    }
    
    return self;
}

- (void)close {
    sqlite3_close(db);
}

- (long)addFriend:(Friend *)friendData {
    sqlite3_stmt *insertStatement = nil;
    const char* insertQuery = [[NSString stringWithFormat:@"insert into '%@'(frienduid, friendname, friendemail) values(?,?,?)", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, NULL);
    sqlite3_bind_text(insertStatement, 1, [[friendData frienduid] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [[friendData friendname] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [[friendData friendemail] UTF8String], -1, SQLITE_TRANSIENT);
    
    if(sqlite3_step(insertStatement) == SQLITE_DONE) {
        sqlite3_finalize(insertStatement);
        return sqlite3_last_insert_rowid(db);
    }
    else {
        NSLog(@"%s", sqlite3_errmsg(db));
        sqlite3_finalize(insertStatement);
        return -1;
    }
}

- (BOOL)updateFriend:(Friend *)friendData {
    sqlite3_stmt *updateStatement = nil;
    const char* updateQuery = [[NSString stringWithFormat:@"update '%@' set friendname=?, friendemail=? where groupid=?", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, updateQuery, -1, &updateStatement, NULL);
    sqlite3_bind_text(updateStatement, 1, [[friendData friendname] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [[friendData friendemail] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [[friendData frienduid] UTF8String], -1, SQLITE_TRANSIENT);
    
    if(sqlite3_step(updateStatement) == SQLITE_DONE) {
        sqlite3_finalize(updateStatement);
        return YES;
    }
    else {
        NSLog(@"%s", sqlite3_errmsg(db));
        sqlite3_finalize(updateStatement);
        return NO;
    }
}

- (BOOL)deleteFriend:(NSString *)frienduid {
    sqlite3_stmt *deleteStatement = nil;
    const char* deleteQuery = [[NSString stringWithFormat:@"delete from '%@' where frienduid=?", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, deleteQuery, -1, &deleteStatement, NULL);
    sqlite3_bind_text(deleteStatement, 1, [frienduid UTF8String], -1, SQLITE_TRANSIENT);
    
    if(sqlite3_step(deleteStatement) == SQLITE_DONE) {
        sqlite3_finalize(deleteStatement);
        return YES;
    }
    else {
        sqlite3_finalize(deleteStatement);
        return NO;
    }
}

- (NSMutableArray*)fetchAllFriends {
    NSMutableArray *friendArray = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *fetchStatement = nil;
    const char* fetchQuery = [[NSString stringWithFormat:@"select frienduid, friendname, friendemail from '%@'", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, fetchQuery, -1, &fetchStatement, NULL);
    
    while(sqlite3_step(fetchStatement) == SQLITE_ROW) {
        Friend *friend = [[Friend alloc] init];
        friend.frienduid = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 0)];
        friend.friendname = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 1)];
        friend.friendemail = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 2)];
        
        [friendArray addObject:friend];
    }
    
    return friendArray;
}

- (Friend *)fetchFriend:(NSString *)frienduid{
    Friend *friend = [[Friend alloc] init];
    
    sqlite3_stmt *fetchStatement = nil;
    const char* fetchQuery = [[NSString stringWithFormat:@"select friendname, friendemail from '%@' where frienduid=?", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, fetchQuery, -1, &fetchStatement, NULL);
    sqlite3_bind_text(fetchStatement, 1, [frienduid UTF8String], -1, SQLITE_TRANSIENT);
    
    while(sqlite3_step(fetchStatement) == SQLITE_ROW) {
        friend.frienduid = frienduid;
        friend.friendname = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 0)];
        friend.friendemail = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 1)];
    }
    
    return friend;
}
@end
