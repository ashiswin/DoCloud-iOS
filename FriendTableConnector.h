//
//  FriendTableConnector.h
//  docloud
//
//  Created by Isaac Ravindran on 9/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DatabaseHelper.h"
#import "Friend.h"

@interface FriendTableConnector : NSObject {
    NSString *tableName;
    sqlite3 *db;
}

- (id) init:(NSString*)uid;
- (long)addFriend:(Friend*)friendData;
- (BOOL)updateFriend:(Friend*)friendData;
- (BOOL)deleteFriend:(NSString*)frienduid;
- (NSMutableArray*)fetchAllFriends;
- (Friend*)fetchFriend:(NSString*)frienduid;
- (void)close;

@end
