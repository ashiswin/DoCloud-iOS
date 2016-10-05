//
//  Todo.h
//  docloud
//
//  Created by Isaac Ravindran on 13/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Todo : NSObject {
    NSString *todoid;
    NSString *groupid;
    NSString *name;
    NSString *description;
    NSString *duedate;
    NSNumber *completion;
    NSString *assignees;
    NSString *completed;
}

@property (nonatomic, strong)NSString* todoid;
@property (nonatomic, strong)NSString* groupid;
@property (nonatomic, strong)NSString* name;
@property (nonatomic, strong)NSString* description;
@property (nonatomic, strong)NSString* duedate;
@property (nonatomic, strong)NSNumber* completion;
@property (nonatomic, strong)NSString* assignees;
@property (nonatomic, strong)NSString* completed;

@end
