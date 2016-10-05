//
//  LoginViewController.m
//  docloud
//
//  Created by Isaac Ravindran on 6/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    m = [MainApplication getInstance];
    //m.serverURL = @"http://docloud.devostrum.com/scripts/Main.php";
    m.serverURL = @"http://192.168.1.5/docloud/scripts/Main.php";
    m.connection = [[ServerConnection alloc] init];
    
    if([(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"persistentLogin"] boolValue]) {
        [m setEmail:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
        [m setUid:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]];
        [m setToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];
        
        [self performSegueWithIdentifier:@"segLoggedIn" sender:self];
    }
    
    _edtEmail.delegate = self;
    _edtPassword.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setEdtEmail:nil];
    [self setEdtPassword:nil];
    [super viewDidUnload];
}

- (IBAction)loginClick:(id)sender {
    NSString *email = [_edtEmail text];
    NSString *password = [_edtPassword text];
    
    if([email isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No email" message:@"Please enter an email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
    }
    else if([password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No password" message:@"Please enter a password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
    }
    else {
        NSDictionary *loginDict = [NSDictionary dictionaryWithObject:@"authenticate" forKey:@"command"];
        NSMutableDictionary *loginData = [loginDict mutableCopy];
        
        uint8_t hash[CC_SHA512_DIGEST_LENGTH];
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
        
        CC_SHA512([passwordData bytes], [passwordData length], hash);
        
        NSMutableString *hashedPassword = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
        
        for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
            [hashedPassword appendFormat:@"%02x", hash[i]];
        }
        
        [loginData setObject:email forKey:@"email"];
        [loginData setObject:hashedPassword forKey:@"hashedPassword"];
        [loginData setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] forKey:@"appleDeviceToken"];
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Logging in";
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("login queue", NULL);
        dispatch_async(downloadQueue, ^{
            NSArray *jsonResponse = [[m connection] sendJSONCommand:loginData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *responseObject = [jsonResponse objectAtIndex:0];
                NSNumber *success = (NSNumber *) [responseObject objectForKey:@"success"];
                
                if(![success boolValue]) {
                    [hud hide:YES];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed" message:[responseObject objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    
                    [alert show];
                }
                else {                    
                    [m setEmail:email];
                    [m setUid:[responseObject objectForKey:@"uid"]];
                    [m setToken:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"token"]]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
                    [[NSUserDefaults standardUserDefaults] setObject:[m uid] forKey:@"uid"];
                    [[NSUserDefaults standardUserDefaults] setObject:[m token] forKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"persistentLogin"];
                    
                    DatabaseHelper *helper = [[DatabaseHelper alloc] init];
                    [helper createDatabases:[m uid]];
                    
                    [hud setLabelText:@"Synchronizing"];
                    [self synchronize];
                }
            });
        });
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segRegister"]) {
        RegisterViewController *destViewController = segue.destinationViewController;
        destViewController.passedEmail = [_edtEmail text];
        destViewController.passedPassword = [_edtPassword text];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == _edtEmail) {
        [textField resignFirstResponder];
        [_edtPassword becomeFirstResponder];
        
        return YES;
    }
    else if(textField == _edtPassword) {
        [textField resignFirstResponder];
        [self loginClick:nil];
        return YES;
    }
    
    return NO;
}

- (void)synchronize {
    dispatch_queue_t downloadQueue = dispatch_queue_create("sync queue", NULL);
    dispatch_async(downloadQueue, ^{
        [self synchronizeGroups];
        [self synchronizeFriends];
        [self synchronizeTodos];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.labelText = @"Done";
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            hud.mode = MBProgressHUDModeCustomView;
            [hud hide:YES afterDelay:2];
            
            [self performSegueWithIdentifier:@"segLoggedIn" sender:self];
        });
    });
}

- (void)synchronizeGroups {
    NSDictionary *syncDict = [NSDictionary dictionaryWithObject:@"getAllGroups" forKey:@"command"];
    NSMutableDictionary *syncData = [syncDict mutableCopy];
    
    [syncData setObject:[m uid] forKey:@"uid"];
    
    NSArray *jsonResponse = [[m connection] sendJSONCommand:syncData];
    
    NSDictionary *responseObject = [jsonResponse objectAtIndex:0];
    NSNumber *success = (NSNumber *) [responseObject objectForKey:@"success"];
    
    if([success boolValue] && [(NSNumber*)[responseObject objectForKey:@"numberofgroups"] intValue] != 0) {
        GroupTableConnector *groupConnector = [[GroupTableConnector alloc] init:[m uid]];
        
        NSArray *groups = [responseObject objectForKey:@"groups"];
        
        for(int i = 0; i < [groups count]; i++) {
            NSDictionary *group = [groups objectAtIndex:i];
            
            [groupConnector addGroup:[group objectForKey:@"groupid"] groupName:[group objectForKey:@"groupname"]];
        }
        
        [groupConnector close];
    }
    else if(![success boolValue]) {
        NSLog(@"%@", [responseObject objectForKey:@"message"]);
    }
}

- (void)synchronizeFriends {
    NSDictionary *syncDict = [NSDictionary dictionaryWithObject:@"getAllFriends" forKey:@"command"];
    NSMutableDictionary *syncData = [syncDict mutableCopy];
    
    [syncData setObject:[m uid] forKey:@"uid"];
    
    NSArray *jsonResponse = [[m connection] sendJSONCommand:syncData];
    
    NSDictionary *responseObject = [jsonResponse objectAtIndex:0];
    NSNumber *success = (NSNumber *) [responseObject objectForKey:@"success"];
    
    if([success boolValue] && [(NSNumber*)[responseObject objectForKey:@"numberoffriends"] intValue] != 0) {
        FriendTableConnector *friendConnector = [[FriendTableConnector alloc] init:[m uid]];
        
        NSArray *friends = [responseObject objectForKey:@"friends"];
        Friend *friendObject = [[Friend alloc] init];
        
        for(int i = 0; i < [friends count]; i++) {
            NSDictionary *friend = [friends objectAtIndex:i];
            
            [friendObject setFrienduid:[friend objectForKey:@"frienduid"]];
            [friendObject setFriendname:[friend objectForKey:@"friendname"]];
            [friendObject setFriendemail:[friend objectForKey:@"friendemail"]];
            
            [friendConnector addFriend:friendObject];
        }
        
        [friendConnector close];
    }
    else if(![success boolValue]) {
        NSLog(@"%@", [responseObject objectForKey:@"message"]);
    }
}

- (void)synchronizeTodos {
    NSDictionary *syncDict = [NSDictionary dictionaryWithObject:@"getAllTodos" forKey:@"command"];
    NSMutableDictionary *syncData = [syncDict mutableCopy];
    
    [syncData setObject:[m uid] forKey:@"uid"];
    
    NSArray *jsonResponse = [[m connection] sendJSONCommand:syncData];
    NSDictionary *responseObject = [jsonResponse objectAtIndex:0];
    
    NSNumber *success = (NSNumber *) [responseObject objectForKey:@"success"];
    
    if([success boolValue] && [(NSNumber*)[responseObject objectForKey:@"numberoftodos"] intValue] != 0) {
        TodoTableConnector *todoConnector = [[TodoTableConnector alloc] init:[m uid]];
        
        NSArray *todos = [responseObject objectForKey:@"todos"];
        Todo *todoObject = [[Todo alloc] init];
        
        for(int i = 0; i < [todos count]; i++) {
            NSDictionary *todo = [todos objectAtIndex:i];
            
            [todoObject setGroupid:[todo objectForKey:@"groupid"]];
            [todoObject setTodoid:[todo objectForKey:@"todoid"]];
            [todoObject setName:[todo objectForKey:@"name"]];
            [todoObject setDescription:[todo objectForKey:@"description"]];
            [todoObject setDuedate:[todo objectForKey:@"duedate"]];
            [todoObject setCompletion:[todo objectForKey:@"completion"]];
            [todoObject setAssignees:[todo objectForKey:@"assignees"]];
            [todoObject setCompleted:[todo objectForKey:@"completed"]];
            
            [todoConnector addTodo:todoObject];
        }
        
        [todoConnector close];
    }
    else if(![success boolValue]) {
        NSLog(@"%@", [responseObject objectForKey:@"message"]);
    }
}
@end
