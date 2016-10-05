//
//  TodoTableConnector.h
//  docloud
//
//  Created by Isaac Ravindran on 13/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DatabaseHelper.h"
#import "Todo.h"

@interface TodoTableConnector : NSObject{
    NSString *tableName;
    sqlite3 *db;
}

- (id) init:(NSString*)uid;
- (long)addTodo:(Todo*)todoData;
- (BOOL)updateTodo:(Todo*)todoData;
- (BOOL)deleteTodo:(NSString*)todoid groupid:(NSString*)groupid;
- (NSMutableArray*)fetchAllTodos:(NSString*)groupid;
- (Todo*)fetchTodo:(NSString*)todoid groupid:(NSString*)groupid;
- (void)close;

@end
