//
//  WebServices.m
//  eCommerceApp
//
//  Created by V S Khutal on 05/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "WebServices.h"


#import "Base64.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#include <AFNetworking.h>

@interface WebServices ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation WebServices

// note, use `instancetype` rather than actually referring to WebServices
// in the `sharedManager` method

+ (instancetype)sharedManager
{
    static id sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

// I'd also suggest that you init the `AFHTTPSessionManager` only once when this
// object is first instantiated, rather than doing it when `firstPostService` is
// called

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *url = [NSURL URLWithString:@""];
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

// Notice:
//
//   1. This now has a return type of `void`, because when it instantly returns,
//      there is no data to return.
//
//   2. In order to pass the data back, we use the "completion handler" pattern.

- (void)firstPostServiceWithCompletionHandler:(void (^)(NSArray *list, NSError *error))completionHandler {
    
    NSDictionary *param = @{@"request" : @"get_pull_down_menu" , @"data" : @"0,0,3,1"};
    
    [self.manager POST:@"person.php" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error retrieving data" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];
}

- (NSArray *)methodUsingJsonFromSuccessBlock:(NSData *)data {
    // note, do not use `stringWithUTF8String` with the `bytes` of the `NSData`
    // this is the right way to convert `NSData` to `NSString`:
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"This is string representation of the data : %@", string);
    
    // Note, retire the `list` instance variable, and instead use a local variable
    
    NSArray *list = [string componentsSeparatedByString:@"\n"];
    
    NSLog(@"After sepration first object: %@", [list objectAtIndex:1]);
    
    return list;
}

@end