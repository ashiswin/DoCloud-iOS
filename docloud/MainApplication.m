//
//  MainApplication.m
//  docloud
//
//  Created by Isaac Ravindran on 6/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "MainApplication.h"

@implementation MainApplication
@synthesize serverURL;
@synthesize uid;
@synthesize email;
@synthesize token;
@synthesize connection;

static MainApplication *instance = nil;

+(MainApplication*) getInstance {
    @synchronized(self) {
        if(instance == nil) {
            instance = [MainApplication new];
        }
    }
    return instance;
}

@end
