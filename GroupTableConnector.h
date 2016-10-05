//
//  GroupTableConnector.h
//  docloud
//
//  Created by Isaac Ravindran on 8/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DatabaseHelper.h"
#import "Group.h"

@interface GroupTableConnector : NSObject {
    NSString *tableName;
    sqlite3 *db;
}

- (id) init:(NSString*)uid;
- (long)addGroup:(NSString*)groupid groupName:(NSString*)groupname;
- (BOOL)updateGroupData:(NSString*)groupid groupName:(NSString*)groupname;
- (BOOL)deleteGroup:(NSString*)groupid;
- (NSMutableArray*)fetchAllGroups;
- (Group*)fetchGroup:(NSString*)groupid;
- (void)close;
@end
