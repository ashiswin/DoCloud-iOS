//
//  ServerConnection.h
//  docloud
//
//  Created by Isaac Ravindran on 12/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainApplication;
@interface ServerConnection : NSObject {
    NSString *serverURL;
}

- (id)init;
- (NSArray*)sendJSONCommand:(NSMutableDictionary*)json;

@end
