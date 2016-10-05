//
//  SearchFriendsViewController.m
//  docloud
//
//  Created by Isaac Ravindran on 9/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "SearchFriendsViewController.h"

@interface SearchFriendsViewController ()

@end

@implementation SearchFriendsViewController
@synthesize searchResults;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSrchFriends:nil];
    [self setLstSearchResults:nil];
    [super viewDidUnload];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText isEqualToString:@""]) {
        searchResults = [[NSMutableArray alloc] init];
        _sentRequests = [[NSMutableArray alloc] init];
    }
    else {
        [self getSearchResults:searchText];
    }
    [_lstSearchResults reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResults count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"SearchCell";
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnAdd setTitle:@"Add" forState:UIControlStateNormal];
    btnAdd.frame = CGRectMake(self.view.frame.size.width - 160.0, 2, 160.0, 40.0);
    [btnAdd setTag:indexPath.row];
    if([(NSNumber*)[_sentRequests objectAtIndex:indexPath.row] boolValue] == false) {
        [btnAdd addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchDown];
    }    
    [btnAdd setEnabled:![(NSNumber*)[_sentRequests objectAtIndex:indexPath.row] boolValue]];
    [cell addSubview:btnAdd];
    cell.textLabel.text = [(Friend*)[searchResults objectAtIndex:indexPath.row] friendname];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"Selected %d", indexPath.row);
}

- (void)addButtonPressed:(id)sender {
    UIButton *addButton = (UIButton*)sender;
    Friend *friend = [searchResults objectAtIndex:addButton.tag];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sending request";
    
    NSDictionary *requestDict = [NSDictionary dictionaryWithObject:@"sendFriendRequest" forKey:@"command"];
    NSMutableDictionary *requestData = [requestDict mutableCopy];
    
    [requestData setObject:[m uid] forKey:@"uid"];
    [requestData setObject:[friend frienduid] forKey:@"frienduid"];
    [requestData setObject:[NSString stringWithFormat:@"%llu%c", nanotime_now().ns, 'r'] forKey:@"requesthash"];
    [requestData setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] forKey:@"currentDeviceToken"];
    
    NSArray *jsonArray = [NSArray arrayWithObject:requestData];
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:&error];
    
    NSString *postVariable = [NSString stringWithFormat:@"json=%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    NSLog(postVariable);
    NSURL *url = [NSURL URLWithString:m.serverURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", [postVariable length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[postVariable dataUsingEncoding:NSUTF8StringEncoding]];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("request queue", NULL);
    dispatch_async(downloadQueue, ^{
        NSHTTPURLResponse *response = nil;
        NSError *connectionError = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(connectionError != nil) {
                [hud hide:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending failed" message:[NSString stringWithFormat:@"%@ %d", [connectionError domain], [connectionError code]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
                
                return;
            }
            
            NSError *decodeError = nil;
            NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&decodeError];
            
            if(decodeError != nil) {
                [hud hide:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending failed" message:[NSString stringWithFormat:@"%@ %d", [decodeError domain], [decodeError code]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
                
                return;
            }
            
            NSDictionary *responseObject = [jsonResponse objectAtIndex:0];
            NSNumber *success = (NSNumber *) [responseObject objectForKey:@"success"];
            
            if(![success boolValue]) {
                [hud hide:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending failed" message:[responseObject objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
            }
            else {
                [addButton setEnabled:NO];
                hud.labelText = @"Sent";
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                hud.mode = MBProgressHUDModeCustomView;
                [hud hide:YES afterDelay:2];
            }
        });
    });

    NSLog(@"%d", addButton.tag);
}

- (void)getSearchResults:(NSString*)searchText {
    NSDictionary *searchDict = [NSDictionary dictionaryWithObject:@"searchForFriends" forKey:@"command"];
    NSMutableDictionary *searchData = [searchDict mutableCopy];
    
    [searchData setObject:[m uid] forKey:@"uid"];
    [searchData setObject:searchText forKey:@"searchTerms"];
    
    NSArray *jsonArray = [NSArray arrayWithObject:searchData];
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:&error];
    
    NSString *postVariable = [NSString stringWithFormat:@"json=%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:m.serverURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", [postVariable length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[postVariable dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *response = nil;
    NSError *connectionError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if(connectionError != nil) {
        NSLog(@"Connection error for search: %@ %d", [connectionError domain], [connectionError code]);
        return;
    }
    
    NSError *decodeError = nil;
    NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&decodeError];
    
    if(decodeError != nil) {
        NSLog(@"Decode error for search: %@ %d", [decodeError domain], [decodeError code]);
        return;
    }
    
    NSDictionary *responseObject = [jsonResponse objectAtIndex:0];
    NSNumber *success = (NSNumber *) [responseObject objectForKey:@"success"];
    
    searchResults = [[NSMutableArray alloc] init];
    _sentRequests = [[NSMutableArray alloc] init];
    
    if([success boolValue] && [(NSNumber*)[responseObject objectForKey:@"numberofresults"] intValue] != 0) {
        NSArray *results = [responseObject objectForKey:@"searchresults"];
        Friend *friend = [[Friend alloc] init];
        
        for(int i = 0; i < [results count]; i++) {
            NSDictionary *friendData = [results objectAtIndex:i];
            
            [friend setFrienduid:[friendData objectForKey:@"uid"]];
            [friend setFriendname:[friendData objectForKey:@"name"]];
            [_sentRequests addObject:(NSNumber*)[friendData objectForKey:@"requestSent"]];
            
            [searchResults addObject:friend];
        }
    }
    else if(![success boolValue]) {
        NSLog(@"%@", [responseObject objectForKey:@"message"]);
    }
    else {
    }
}

@end
