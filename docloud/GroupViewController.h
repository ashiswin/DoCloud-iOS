//
//  GroupViewController.h
//  docloud
//
//  Created by Isaac Ravindran on 13/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainApplication.h"

@interface GroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    MainApplication *m;
}

@property (weak, nonatomic) IBOutlet UITableView *lstTodos;

@end
