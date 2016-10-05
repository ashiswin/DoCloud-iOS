//
//  SecondViewController.m
//  docloud
//
//  Created by Isaac Ravindran on 5/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    m = [MainApplication getInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFriends:) name:@"reloadFriends" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFriendRequests:) name:@"reloadFriendRequests" object:nil];
    
    FriendTableConnector *connector = [[FriendTableConnector alloc] init:[m uid]];
    
    _friends = [connector fetchAllFriends];
    _requests = [[NSMutableArray alloc] init];
    
    [self getFriendRequests];
    [connector close];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLstFriendRequests:nil];
    [self setLstFriends:nil];
    [self setBtnAddFriends:nil];
    [super viewDidUnload];
}

- (void)getFriendRequests {
    NSDictionary *requestsDict = [NSDictionary dictionaryWithObject:@"getFriendRequests" forKey:@"command"];
    NSMutableDictionary *requestsData = [requestsDict mutableCopy];
    
    [requestsData setObject:[m uid] forKey:@"uid"];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("friendrequestsqueue", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *jsonResponse = [[m connection] sendJSONCommand:requestsData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *responseObject = [jsonResponse objectAtIndex:0];
            NSNumber *success = (NSNumber *) [responseObject objectForKey:@"success"];
            
            if(![success boolValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading friend requests" message:[responseObject objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
            }
            else if([(NSNumber*)[responseObject objectForKey:@"numberofrequests"] intValue] != 0) {
                NSArray *requestArray = [responseObject objectForKey:@"requests"];
                Friend *friend = [[Friend alloc] init];
                
                for(int i = 0; i < [requestArray count]; i++) {
                    [friend setFrienduid:[(NSDictionary*)[requestArray objectAtIndex:i] objectForKey:@"frienduid"]];
                    [friend setFriendname:[(NSDictionary*)[requestArray objectAtIndex:i] objectForKey:@"name"]];
                    [friend setFriendemail:[(NSDictionary*)[requestArray objectAtIndex:i] objectForKey:@"friendemail"]];
                    [_requests addObject:friend];
                }
                
                [_lstFriendRequests reloadData];
            }
        });
    });
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _lstFriends) {
        if([_friends count] == 0) {
            return 1;
        }
        return [_friends count];
    }
    else {
        if([_requests count] == 0) {
            return 1;
        }
        return [_requests count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _lstFriends) {
        static NSString* cellIdentifier = @"FriendCell";
        UITableViewCell *cell;
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if([_friends count] == 0) {
            cell.textLabel.text = @"You have no friends";
        }
        else {
            cell.textLabel.text = [(Friend*)[_friends objectAtIndex:indexPath.row] friendname];
            cell.imageView.image = [UIImage imageNamed:@"sampleprofile.png"];
            
            uint8_t hash[CC_MD5_DIGEST_LENGTH];
            NSData *useridData = [[(Friend*)[_friends objectAtIndex:indexPath.row] friendemail] dataUsingEncoding:NSUTF8StringEncoding];
            
            CC_MD5([useridData bytes], [useridData length], hash);
            
            NSMutableString *hashedUserId = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
            
            for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
                [hashedUserId appendFormat:@"%02x", hash[i]];
            }
            
            NSString *gravatarURLString = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?d=retro", hashedUserId];
            NSURL *gravatarURL = [NSURL URLWithString:gravatarURLString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:gravatarURL];
            
            dispatch_queue_t downloadQueue = dispatch_queue_create("gravatar queue", NULL);
            dispatch_async(downloadQueue, ^{
                NSHTTPURLResponse *response = nil;
                NSError *connectionError = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(connectionError != nil) {
                        NSLog(@"%@ %d", [connectionError domain], [connectionError code]);
                        return;
                    }
                    
                    cell.imageView.image = [UIImage imageWithData:data];
                });
            });
        }
        return cell;
    }
    else {
        static NSString* cellIdentifier = @"RequestCell";
        UITableViewCell *cell;
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        if([_requests count] == 0) {
            cell.textLabel.text = @"You have no friend requests";
        }
        else {
            UIButton *btnAccept = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btnAccept setTitle:@"Accept" forState:UIControlStateNormal];
            btnAccept.frame = CGRectMake(self.view.frame.size.width - 320.0, 2, 160.0, 40.0);
            [btnAccept setTag:indexPath.row];
            [btnAccept addTarget:self action:@selector(acceptButtonPressed:) forControlEvents:UIControlEventTouchDown];
            [cell addSubview:btnAccept];
            
            UIButton *btnDecline = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btnDecline setTitle:@"Decline" forState:UIControlStateNormal];
            btnDecline.frame = CGRectMake(self.view.frame.size.width - 160.0, 2, 160.0, 40.0);
            [btnDecline setTag:indexPath.row];
            [btnDecline addTarget:self action:@selector(declineButtonPressed:) forControlEvents:UIControlEventTouchDown];
            [cell addSubview:btnDecline];
            
            cell.textLabel.text = [(Friend*)[_requests objectAtIndex:indexPath.row] friendname];
            cell.imageView.image = [UIImage imageNamed:@"sampleprofile.png"];
            
            uint8_t hash[CC_MD5_DIGEST_LENGTH];
            NSData *useridData = [[(Friend*)[_requests objectAtIndex:indexPath.row] friendemail] dataUsingEncoding:NSUTF8StringEncoding];
            
            CC_MD5([useridData bytes], [useridData length], hash);
            
            NSMutableString *hashedUserId = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
            
            for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
                [hashedUserId appendFormat:@"%02x", hash[i]];
            }
            
            NSString *gravatarURLString = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?d=retro", hashedUserId];
            NSURL *gravatarURL = [NSURL URLWithString:gravatarURLString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:gravatarURL];
            
            dispatch_queue_t downloadQueue = dispatch_queue_create("gravatar queue", NULL);
            dispatch_async(downloadQueue, ^{
                NSHTTPURLResponse *response = nil;
                NSError *connectionError = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(connectionError != nil) {
                        NSLog(@"%@ %d", [connectionError domain], [connectionError code]);
                        return;
                    }
                    
                    cell.imageView.image = [UIImage imageWithData:data];
                });
            });
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected %d", indexPath.row);
}

- (IBAction)addFriendsClick:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Friends" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Search", @"Facebook", nil];
    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:0] setImage:[UIImage imageNamed:@"icon_57.png"] forState:UIControlStateNormal];
    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:1] setImage:[UIImage imageNamed:@"f_logo.png"] forState:UIControlStateNormal];
    [actionSheet showFromBarButtonItem:_btnAddFriends animated:YES];
}

- (void)acceptButtonPressed:(id)sender {
    int index = [(UIButton*)sender tag];
    
    NSDictionary *acceptDict = [NSDictionary dictionaryWithObject:@"acceptFriendRequest" forKey:@"command"];
    NSMutableDictionary *acceptData = [acceptDict mutableCopy];
    
    [acceptData setObject:[m uid] forKey:@"uid"];
    [acceptData setObject:[(Friend*)[_requests objectAtIndex:index] frienduid] forKey:@"frienduid"];
    [acceptData setObject:[(Friend*)[_requests objectAtIndex:index] friendname] forKey:@"friendname"];
    [acceptData setObject:[NSString stringWithFormat:@"%lldc", nanotime_now().ns] forKey:@"changeHash"];
    [acceptData setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] forKey:@"currentDeviceToken"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Accepting request";
    
    dispatch_queue_t acceptQueue = dispatch_queue_create("accept queue", NULL);
    dispatch_async(acceptQueue, ^{
        NSArray *jsonResponse = [[m connection] sendJSONCommand:acceptData];
        NSDictionary *responseDict = [jsonResponse objectAtIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(![(NSNumber*)[responseDict objectForKey:@"success"] boolValue]) {
                [hud hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Accept failed" message:[responseDict objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
            }
            else {
                Friend *friend = [_requests objectAtIndex:index];
                FriendTableConnector *connector = [[FriendTableConnector alloc] init:[m uid]];
                [connector addFriend:friend];
                _friends = [connector fetchAllFriends];
                [connector close];
                
                [_requests removeObjectAtIndex:index];
                [_lstFriendRequests reloadData];
                [_lstFriends reloadData];
                
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                hud.labelText = @"Request accept";
                
                [hud hide:YES afterDelay:2];
            }
        });
    });
    NSLog(@"Accept: %d", [(UIButton*)sender tag]);
}

- (void)declineButtonPressed:(id)sender {
    NSDictionary *rejectDict = [NSDictionary dictionaryWithObject:@"rejectFriendRequest" forKey:@"command"];
    NSMutableDictionary *rejectData = [rejectDict mutableCopy];
    
    [rejectData setObject:[m uid] forKey:@"uid"];
    [rejectData setObject:[(Friend*)[_requests objectAtIndex:[(UIButton*)sender tag]] frienduid] forKey:@"frienduid"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Declining Request";
    
    dispatch_queue_t rejectQueue = dispatch_queue_create("rejectqueue", NULL);
    dispatch_async(rejectQueue, ^{
        NSArray *jsonResponse = [[m connection] sendJSONCommand:rejectData];
        NSDictionary *responseDict = [jsonResponse objectAtIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(![(NSNumber*)[responseDict objectForKey:@"success"] boolValue]) {
                [hud hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Decline failed" message:[responseDict objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
            }
            else {
                [_requests removeObjectAtIndex:[(UIButton*)sender tag]];
                [_lstFriendRequests reloadData];
                
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                hud.labelText = @"Request declined";
                
                [hud hide:YES afterDelay:2];
            }
        });
    });
    NSLog(@"Decline: %d", [(UIButton*)sender tag]);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"segSearchFriends" sender:nil];
            break;
            
        default:
            break;
    }
}

- (void)reloadFriends:(NSNotification*)notification {
    FriendTableConnector *connector = [[FriendTableConnector alloc] init:[m uid]];
    _friends = [connector fetchAllFriends];
    [connector close];
    [_lstFriends reloadData];
    NSLog(@"Reloaded friends");
}

- (void)reloadFriendRequests:(NSNotification*)notification {
    [self getFriendRequests];
    [_lstFriendRequests reloadData];
    NSLog(@"Reloaded friend requests");
}
@end
