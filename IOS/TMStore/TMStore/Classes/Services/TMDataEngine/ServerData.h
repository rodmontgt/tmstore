//
//  ServerData.h
//  eMobileApp
//
//  Created by Rishabh Jain on 08/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <AFNetworking/AFNetworking.h>


enum SERVER_REQUEST_STATE {
    kServerRequestNone,
    kServerRequestStart,
    kServerRequestPaused,
    kServerRequestFailed,
    kServerRequestSucceed,
    kServerRequestCancelled,
    kServerRequestUnauthorized
};

@interface ServerData : NSObject
@property NSString *_serverUrl;
//@property NSString *_serverRequestName;
@property AFHTTPSessionManager *_serverRequest;
@property int _serverRequestStatus;
@property int _serverDataId;
@property NSDictionary *_serverResultDictionary;
@property NSString* errorStr;
@end

