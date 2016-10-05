//
//  MainApplication.h
//  docloud
//
//  Created by Isaac Ravindran on 6/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerConnection.h"

@interface MainApplication : NSObject {
    NSString *serverURL;
    NSString *uid;
    NSString *email;
    NSString *token;
    ServerConnection *connection;
}
@property(nonatomic, retain) NSString *serverURL;
@property(nonatomic, retain) NSString *uid;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *token;
@property(nonatomic, retain) ServerConnection *connection;

+(MainApplication*) getInstance;

@end
