//
//  DatabaseHelper.m
//  docloud
//
//  Created by Isaac Ravindran on 7/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "DatabaseHelper.h"

@implementation DatabaseHelper
- (BOOL)createDatabases:(NSString *)uid {
    NSString *databasePath;
    NSString *docsDir;
    NSArray *dirPaths;
    sqlite3 *db;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"applicationdata"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
            char *errMsg;
            const char *groupTableString = [[NSString stringWithFormat:@"create table if not exists '%@Groups'(_id integer primary key autoincrement, groupid text not null, groupname text not null)", uid] UTF8String];
            
            const char *tasksTableString = [[NSString stringWithFormat:@"create table if not exists '%@Todos'(_id integer primary key autoincrement, todoid text not null, groupid text not null, name text not null, description text, duedate text, completion integer not null, assignees text, completed text)", uid] UTF8String];
            
            const char *friendTableString = [[NSString stringWithFormat:@"create table if not exists '%@Friends'(_id integer primary key autoincrement, frienduid text not null, friendname text not null, friendemail text not null)", uid] UTF8String];
            
            const char *remindersTableString = [[NSString stringWithFormat:@"create table if not exists '%@Reminders'(_id integer primary key autoincrement, reminderid text not null, groupid text not null, todoid text not null, duedate text not null)", uid] UTF8String];
            
            if (sqlite3_exec(db, groupTableString, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to create group table: %s", errMsg);
                return NO;
            }
            if(sqlite3_exec(db, tasksTableString, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to create tasks table: %s", errMsg);
                return NO;
            }
            if(sqlite3_exec(db, friendTableString, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to create friend table: %s", errMsg);
                return NO;
            }
            if(sqlite3_exec(db, remindersTableString, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to create reminders table: %s", errMsg);
                return NO;
            }
            
            sqlite3_close(db);
        }
        else {
            NSLog(@"Failed to open/create database");
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)removeDatabases:(NSString *)uid {
    
}

+(sqlite3*) getDatabase {
    sqlite3 *db;
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"applicationdata"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == YES) {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
            return db;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}
@end
