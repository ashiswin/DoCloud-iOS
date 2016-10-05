//
//  SecondViewController.h
//  docloud
//
//  Created by Isaac Ravindran on 5/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "MainApplication.h"
#import "FriendTableConnector.h"
#import "MBProgressHUD.h"
#import "nanotime.h"

@interface SecondViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    MainApplication *m;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAddFriends;
@property (strong, nonatomic) IBOutlet UITableView *lstFriendRequests;
@property (strong, nonatomic) IBOutlet UITableView *lstFriends;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *requests;
- (IBAction)addFriendsClick:(id)sender;
- (void)acceptButtonPressed:(id)sender;
- (void)declineButtonPressed:(id)sender;
@end
