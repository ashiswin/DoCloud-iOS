//
//  Group.h
//  docloud
//
//  Created by Isaac Ravindran on 9/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject {
    NSString *groupid;
    NSString *groupname;
}

@property (nonatomic, strong)NSString *groupid;
@property (nonatomic, strong)NSString *groupname;

@end
