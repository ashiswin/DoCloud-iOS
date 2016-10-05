//
//  RegisterViewController.h
//  docloud
//
//  Created by Isaac Ravindran on 6/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "MBProgressHUD.h"
#import "MainApplication.h"

@interface RegisterViewController : UIViewController <UITextFieldDelegate> {
    MainApplication *m;
}

@property (weak, nonatomic) IBOutlet UITextField *edtName;
@property (weak, nonatomic) IBOutlet UITextField *edtEmail;
@property (weak, nonatomic) IBOutlet UITextField *edtPassword;
@property (weak, nonatomic) IBOutlet UITextField *edtConfirm;
@property (weak, nonatomic) NSString *passedEmail;
@property (weak, nonatomic) NSString *passedPassword;

- (IBAction)registerClick:(id)sender;

@end
