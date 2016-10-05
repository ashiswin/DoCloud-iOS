//
//  RegisterViewController.m
//  docloud
//
//  Created by Isaac Ravindran on 6/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

@synthesize passedEmail;
@synthesize passedPassword;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [_edtEmail setText:passedEmail];
    [_edtPassword setText:passedPassword];
    
    m = [MainApplication getInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setEdtName:nil];
    [self setEdtEmail:nil];
    [self setEdtPassword:nil];
    [self setEdtConfirm:nil];
    [super viewDidUnload];
}

- (IBAction)registerClick:(id)sender {
    NSString *name = [_edtName text];
    NSString *email = [_edtEmail text];
    NSString *password = [_edtPassword text];
    NSString *confirm = [_edtConfirm text];
    
    if([name isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No name" message:@"Please enter your name" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    if([email isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No email" message:@"Please enter your email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    if([password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No password" message:@"Please enter a password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    if([confirm isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No password confirmation" message:@"Please confirm your password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    if(![confirm isEqualToString:password]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password mismatch" message:@"The passwords entered do no match" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    
    NSDictionary *registerDict = [NSDictionary dictionaryWithObject:@"register" forKey:@"command"];
    NSMutableDictionary *registerData = [registerDict mutableCopy];
    
    uint8_t hash[CC_SHA512_DIGEST_LENGTH];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    CC_SHA512([passwordData bytes], [passwordData length], hash);
    
    NSMutableString *hashedPassword = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [hashedPassword appendFormat:@"%02x", hash[i]];
    }
    
    NSData *confirmData = [confirm dataUsingEncoding:NSUTF8StringEncoding];
    
    CC_SHA512([confirmData bytes], [confirmData length], hash);
    
    NSMutableString *hashedConfirm = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [hashedConfirm appendFormat:@"%02x", hash[i]];
    }
    
    [registerData setObject:name forKey:@"name"];
    [registerData setObject:email forKey:@"email"];
    [registerData setObject:hashedPassword forKey:@"hashedPassword"];
    [registerData setObject:hashedConfirm forKey:@"hashedPasswordConfirm"];
    [registerData setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] forKey:@"appleDeviceToken"];
    
    NSArray *jsonArray = [NSArray arrayWithObject:registerData];
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:&error];
    
    NSString *postVariable = [NSString stringWithFormat:@"json=%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:m.serverURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", [postVariable length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[postVariable dataUsingEncoding:NSUTF8StringEncoding]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Registering";
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("login queue", NULL);
    dispatch_async(downloadQueue, ^{
        NSHTTPURLResponse *response = nil;
        NSError *connectionError = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(connectionError != nil) {
                [hud hide:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration failed" message:[NSString stringWithFormat:@"%@ %d", [connectionError domain], [connectionError code]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
                
                return;
            }
            
            NSError *decodeError = nil;
            NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&decodeError];
            
            if(decodeError != nil) {
                [hud hide:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration failed" message:[NSString stringWithFormat:@"%@ %d", [decodeError domain], [decodeError code]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
                
                return;
            }
            
            NSDictionary *responseObject = [jsonResponse objectAtIndex:0];
            NSNumber *success = (NSNumber *) [responseObject objectForKey:@"success"];
            
            if(![success boolValue]) {
                [hud hide:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration failed" message:[responseObject objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
            }
            else {
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                hud.mode = MBProgressHUDModeCustomView;
                [hud hide:YES afterDelay:2];
                
                [m setEmail:email];
                [m setUid:[responseObject objectForKey:@"uid"]];
                [m setToken:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"token"]]];
                
                [self performSegueWithIdentifier:@"segRegistered" sender:self];
            }
        });
    });
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == _edtConfirm) {
        [textField resignFirstResponder];
        [self registerClick:nil];
    }
    return YES;
}

@end
