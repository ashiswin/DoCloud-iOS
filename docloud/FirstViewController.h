//
//  FirstViewController.h
//  docloud
//
//  Created by Isaac Ravindran on 5/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainApplication.h"
#import "GroupTableConnector.h"

@interface FirstViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    MainApplication *m;
}
@property (weak, nonatomic) IBOutlet UITableView *lstGroups;
@property (strong, nonatomic) NSMutableArray *groups;

@end
