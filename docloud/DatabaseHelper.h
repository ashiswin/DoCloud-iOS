//
//  DatabaseHelper.h
//  docloud
//
//  Created by Isaac Ravindran on 7/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseHelper : NSObject
-(BOOL) createDatabases:(NSString*)uid;
-(BOOL) removeDatabases:(NSString*)uid;
+(sqlite3*) getDatabase;
@end
