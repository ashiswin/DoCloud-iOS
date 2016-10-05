//
//  LoginViewController.h
//  docloud
//
//  Created by Isaac Ravindran on 6/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "MainApplication.h"
#import "RegisterViewController.h"
#import "MBProgressHUD.h"
#import "DatabaseHelper.h"
#import "GroupTableConnector.h"
#import "FriendTableConnector.h"
#import "TodoTableConnector.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    MainApplication *m;
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UITextField *edtEmail;
@property (weak, nonatomic) IBOutlet UITextField *edtPassword;
- (IBAction)loginClick:(id)sender;
- (void)synchronize;
- (void)synchronizeGroups;
- (void)synchronizeFriends;
@end
