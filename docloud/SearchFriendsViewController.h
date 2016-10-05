//
//  SearchFriendsViewController.h
//  docloud
//
//  Created by Isaac Ravindran on 9/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainApplication.h"
#import "Friend.h"
#import "nanotime.h"
#import "MBProgressHUD.h"

@interface SearchFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    MainApplication *m;
}
@property (weak, nonatomic) IBOutlet UISearchBar *srchFriends;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *sentRequests;
@property (weak, nonatomic) IBOutlet UITableView *lstSearchResults;

- (void)addButtonPressed:(id)sender;
@end
