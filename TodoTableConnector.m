//
//  TodoTableConnector.m
//  docloud
//
//  Created by Isaac Ravindran on 13/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "TodoTableConnector.h"

@implementation TodoTableConnector
- (id)init:(NSString*)uid {
    if(self = [super init]) {
        tableName = [NSString stringWithFormat:@"%@Todos", uid];
        db = [DatabaseHelper getDatabase];
    }
    
    return self;
}

- (void)close {
    sqlite3_close(db);
}

- (long)addTodo:(Todo *)todoData {
    sqlite3_stmt *insertStatement = nil;
    const char* insertQuery = [[NSString stringWithFormat:@"insert into '%@'(groupid, todoid, name, description, duedate, completion, assignees, completed) values(?,?,?,?,?,?,?,?)", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, NULL);
    sqlite3_bind_text(insertStatement, 1, [[todoData groupid] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [[todoData todoid] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [[todoData name] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [[todoData description] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [[todoData duedate] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, 6, [[todoData completion] intValue]);
    sqlite3_bind_text(insertStatement, 7, [[todoData assignees] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 8, [[todoData completed] UTF8String], -1, SQLITE_TRANSIENT);
    
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

- (BOOL)updateTodo:(Todo *)todoData {
    sqlite3_stmt *updateStatement = nil;
    const char* updateQuery = [[NSString stringWithFormat:@"update '%@' set name=?, description=?, duedate=?, completion=?, assignees=?, completed=? where groupid=? and todoid=?", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, updateQuery, -1, &updateStatement, NULL);
    sqlite3_bind_text(updateStatement, 1, [[todoData name] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [[todoData description] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [[todoData duedate] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStatement, 6, [[todoData completion] intValue]);
    sqlite3_bind_text(updateStatement, 5, [[todoData assignees] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 6, [[todoData completed] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 7, [[todoData groupid] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 8, [[todoData todoid] UTF8String], -1, SQLITE_TRANSIENT);
    
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

- (BOOL)deleteTodo:(NSString *)todoid groupid:(NSString *)groupid {
    sqlite3_stmt *deleteStatement = nil;
    const char* deleteQuery = [[NSString stringWithFormat:@"delete from '%@' where groupid=? and todoid=?", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, deleteQuery, -1, &deleteStatement, NULL);
    sqlite3_bind_text(deleteStatement, 1, [groupid UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(deleteStatement, 2, [todoid UTF8String], -1, SQLITE_TRANSIENT);
    
    if(sqlite3_step(deleteStatement) == SQLITE_DONE) {
        sqlite3_finalize(deleteStatement);
        return YES;
    }
    else {
        sqlite3_finalize(deleteStatement);
        return NO;
    }
}

- (NSMutableArray*)fetchAllTodos:(NSString *)groupid {
    NSMutableArray *todoArray = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *fetchStatement = nil;
    if(groupid == nil) {
        const char* fetchQuery = [[NSString stringWithFormat:@"select name, description, duedate, completion, assignees, completed from '%@'", tableName] UTF8String];
        sqlite3_prepare_v2(db, fetchQuery, -1, &fetchStatement, NULL);
    }
    else {
        const char* fetchQuery = [[NSString stringWithFormat:@"select todoid, name, description, duedate, completion, assignees, completed from '%@' where groupid=?", tableName] UTF8String];
        sqlite3_prepare_v2(db, fetchQuery, -1, &fetchStatement, NULL);
        sqlite3_bind_text(fetchStatement, 1, [groupid UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    
    while(sqlite3_step(fetchStatement) == SQLITE_ROW) {
        Todo *todo = [[Todo alloc] init];
        todo.groupid = groupid;
        todo.todoid = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 0)];
        todo.name = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 1)];
        todo.description = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 2)];
        todo.duedate = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 3)];
        todo.completion = [NSNumber numberWithInt:sqlite3_column_int(fetchStatement, 4)];
        todo.assignees = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 5)];
        todo.completed = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 6)];
        
        [todoArray addObject:todo];
    }
    
    return todoArray;
}

- (Todo*)fetchTodo:(NSString *)todoid groupid:(NSString *)groupid{
    Todo *todo = [[Todo alloc] init];
    
    sqlite3_stmt *fetchStatement = nil;
    const char* fetchQuery = [[NSString stringWithFormat:@"select todoid, name, description, duedate, completion, assignees, completed from '%@' where groupid=? and todoid=?", tableName] UTF8String];
    
    sqlite3_prepare_v2(db, fetchQuery, -1, &fetchStatement, NULL);
    sqlite3_bind_text(fetchStatement, 1, [groupid UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(fetchStatement, 2, [todoid UTF8String], -1, SQLITE_TRANSIENT);
    
    while(sqlite3_step(fetchStatement) == SQLITE_ROW) {
        todo.groupid = groupid;
        todo.todoid = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 0)];
        todo.name = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 1)];
        todo.description = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 2)];
        todo.duedate = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 3)];
        todo.completion = [NSNumber numberWithInt:sqlite3_column_int(fetchStatement, 4)];
        todo.assignees = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 5)];
        todo.completed = [NSString stringWithUTF8String:(char*) sqlite3_column_text(fetchStatement, 6)];
    }
    
    return todo;
}

@end
