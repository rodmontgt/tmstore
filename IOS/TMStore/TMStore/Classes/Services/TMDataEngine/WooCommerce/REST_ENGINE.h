//
//  REST_ENGINE.h
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <AFNetworking.h>
@interface REST_ENGINE : NSObject<NSURLConnectionDelegate>
@property NSString* oauth_consumer_key;
@property NSString* oauth_consumer_secret;
@property NSString* version_string;
@end