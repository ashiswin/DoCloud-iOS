//
//  AppDelegate.m
//  docloud
//
//  Created by Isaac Ravindran on 5/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSLog(@"Registering for APNS");
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *str = [NSString stringWithFormat:@"%@",deviceToken];
    NSString *newString = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:newString forKey:@"deviceToken"];
    
    NSLog(@"%@",newString);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@ %d", [error domain], [error code]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received notification");
    NSDictionary *changeDict = [userInfo objectForKey:@"change"];
    if([[changeDict objectForKey:@"command"] isEqualToString:@"addFriend"]) {
        Friend *friend = [[Friend alloc] init];
        [friend setFriendname:[changeDict objectForKey:@"friendname"]];
        [friend setFrienduid:[changeDict objectForKey:@"frienduid"]];
        [friend setFriendemail:[changeDict objectForKey:@"friendemail"]];
        
        FriendTableConnector *connector = [[FriendTableConnector alloc] init:[[MainApplication getInstance] uid]];
        [connector addFriend:friend];
        [connector close];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFriends" object:nil];
    }
    else if([[changeDict objectForKey:@"command"] isEqualToString:@"newFriendRequest"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFriendRequests" object:nil];
    }
}
@end
