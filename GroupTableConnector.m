//
//  GroupTableConnector.m
//  docloud
//
//  Created by Isaac Ravindran on 8/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "GroupTableConnector.h"

@implementation GroupTableConnector
- (id)init:(NSString*)uid {
    if(self = [super init]) {
        tableName = [NSString stringWithFormat:@"%@Groups", uid];
        db = [DatabaseHelper getDatabase];
    }
    
    return self;
}

- (void)close {
    sqlite3_close(db);
}

- (long)addGroup:(NSString *)groupid groupName:(NSString *)groupname {
    sqlite3_stmt *insertStatement = nil;
    const char* insertQuery = [[NSString stringWithFormat:@"insert into '%@'(groupid, groupname) values(?,?)", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, NULL);
    sqlite3_bind_text(insertStatement, 1, [groupid UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [groupname UTF8String], -1, SQLITE_TRANSIENT);
    
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

- (BOOL)updateGroupData:(NSString *)groupid groupName:(NSString *)groupname {
    sqlite3_stmt *updateStatement = nil;
    const char* updateQuery = [[NSString stringWithFormat:@"update '%@' set groupname=? where groupid=?", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, updateQuery, -1, &updateStatement, NULL);
    sqlite3_bind_text(updateStatement, 1, [groupname UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [groupid UTF8String], -1, SQLITE_TRANSIENT);
    
    if(sqlite3_step(updateStatement) == SQLITE_DONE) {
        sqlite3_finalize(updateStatement);
        return YES;
    }
    else {
        sqlite3_finalize(updateStatement);
        return NO;
    }
}

- (BOOL)deleteGroup:(NSString *)groupid {
    sqlite3_stmt *deleteStatement = nil;
    const char* deleteQuery = [[NSString stringWithFormat:@"delete from '%@' where groupid=?", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, deleteQuery, -1, &deleteStatement, NULL);
    sqlite3_bind_text(deleteStatement, 1, [groupid UTF8String], -1, SQLITE_TRANSIENT);
    
    if(sqlite3_step(deleteStatement) == SQLITE_DONE) {
        sqlite3_finalize(deleteStatement);
        return YES;
    }
    else {
        sqlite3_finalize(deleteStatement);
        return NO;
    }
}

- (NSMutableArray*)fetchAllGroups {
    NSMutableArray *groupArray = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *fetchStatement = nil;
    const char* fetchQuery = [[NSString stringWithFormat:@"select groupid, groupname from '%@'", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, fetchQuery, -1, &fetchStatement, NULL);
    
    while(sqlite3_step(fetchStatement) == SQLITE_ROW) {
        Group *group = [[Group alloc] init];
        group.groupid = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 0)];
        group.groupname = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 1)];
        
        [groupArray addObject:group];
    }
    
    return groupArray;
}

- (Group*)fetchGroup:(NSString*)groupid {
    Group *group = [[Group alloc] init];
    
    sqlite3_stmt *fetchStatement = nil;
    const char* fetchQuery = [[NSString stringWithFormat:@"select groupid, groupname from '%@' where groupid=?", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, fetchQuery, -1, &fetchStatement, NULL);
    sqlite3_bind_text(fetchStatement, 1, [groupid UTF8String], -1, SQLITE_TRANSIENT);
    
    while(sqlite3_step(fetchStatement) == SQLITE_ROW) {
        group.groupid = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 0)];
        group.groupname = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 1)];
    }
    
    return group;
}
@end
