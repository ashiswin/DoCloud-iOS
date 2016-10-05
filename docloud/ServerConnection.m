//
//  ServerConnection.m
//  docloud
//
//  Created by Isaac Ravindran on 12/6/13.
//  Copyright (c) 2013 Devostrum. All rights reserved.
//

#import "ServerConnection.h"
#import "MainApplication.h"

@implementation ServerConnection

- (id)init {
    if(self = [super init]) {
        serverURL = [[MainApplication getInstance] serverURL];
    }
    
    return self;
}

- (NSArray*)sendJSONCommand:(NSMutableDictionary*)json {
    
    NSArray *jsonArray = [NSArray arrayWithObject:json];
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:&error];
    
    NSString *postVariable = [NSString stringWithFormat:@"json=%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    NSLog(postVariable);
    NSURL *url = [NSURL URLWithString:serverURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", [postVariable length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[postVariable dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *response = nil;
    NSError *connectionError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if(connectionError != nil) {
        NSString *errorString = [NSString stringWithFormat:@"Connection: %@ %d", [connectionError domain], [connectionError code]];
        
        NSLog(@"%@", errorString);
        
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@NO, errorString, nil] forKeys:[NSArray arrayWithObjects:@"success", @"message", nil]];
        return [NSArray arrayWithObject:errorDict];
    }
    
    NSError *decodeError = nil;
    NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&decodeError];
    
    if(decodeError != nil) {
        NSString *errorString = [NSString stringWithFormat:@"Decode: %@ %d", [decodeError domain], [decodeError code]];
        
        NSLog(@"%@", errorString);
        
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@NO, errorString, nil] forKeys:[NSArray arrayWithObjects:@"success", @"message", nil]];
        return [NSArray arrayWithObject:errorDict];
    }
    
    return jsonResponse;
}
@end
