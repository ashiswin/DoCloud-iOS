//
//  Friend.h
//  docloud
//
//  Created by Isaac Ravindran on 9/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject {
    NSString *frienduid;
    NSString *friendname;
    NSString *friendemail;
    BOOL requestSent;
}

@property (nonatomic, strong)NSString *frienduid;
@property (nonatomic, strong)NSString *friendname;
@property (nonatomic, strong)NSString *friendemail;
@property (assign)BOOL requestSent;

@end
