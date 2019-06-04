//
//  REST_ENGINE.m
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//

#import "REST_ENGINE.h"
#import <STHTTPRequest/STHTTPRequest.h>
#import <AFNetworking.h>

#define REST_ENGINE_LOG(format, ...) NSLog((@"REST_ENGINE: %s [Line %d]\n" format @"\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
@interface REST_ENGINE()
{
    NSString *oauth_signature;
    NSString *oauth_nonce;
    NSString *time_stamp;
    NSString *requestURL;
    NSMutableData *_responseData;
}
@end

@implementation REST_ENGINE

#pragma mark Private Methods
- (BOOL)containsString:(NSString *)string substring:(NSString*)substring {
    return [string rangeOfString:substring].location != NSNotFound;
}
- (NSString *)getRFC3986:(NSString *)str {
    NSString *strR = [NSString stringWithString:[str st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"STR RFC3986 = %@", strR);
    return strR;
}
- (NSString *)hmacsha1:(NSString *)plaintext key:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [HMAC base64EncodedString];
    NSLog(@"STR Hash = %@", hash);
    return hash;
}
- (NSString *)randomStringWithLength:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    NSLog(@"STR Random = %@", randomString);
    return randomString;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    //[received_data setLength:0];//Set your data to 0 to clear your buffer
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    //[received_data appendData:data];//Append the download data..
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connection");
    //Use your downloaded data here
}

#pragma mark Fetch Data from Woocommerce
- (void)getRequestOperation:(NSString *)requestedUrl isPostMethod:(BOOL)_isPostMethod maxDataLimit:(int)maxDataLimit offset:(int)offset{
    NSLog(@"%@",requestedUrl);
    requestURL = [NSString stringWithString:requestedUrl];
    NSString* params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", maxDataLimit, self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]]];
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"GET&%@&%@", urlStr, paramString];
    NSString* algoKey;
    if([self.version_string isEqualToString:@"v2"]) {
        algoKey = self.oauth_consumer_secret;
    }else if([self.version_string isEqualToString:@"v3"]) {
        algoKey = [NSString stringWithFormat:@"%@&", self.oauth_consumer_secret];
    }
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    
    if ([self containsString:requestURL substring:@"https"]) {
        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&consumer_key=%@&consumer_secret=%@", maxDataLimit, self.oauth_consumer_key, self.oauth_consumer_secret];
    }
    NSString *finalUrlStr =[NSString stringWithFormat:@"%@?%@",requestURL, params];
    NSURL *url = [NSURL URLWithString:finalUrlStr];
    NSLog(@"url=%@",url);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    if (_isPostMethod) {
        [request setHTTPMethod:@"POST"];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    
    NSLog(@"request = %@", request);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"\noperation = completed");
        NSLog(@"\nresponseObject = %@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"\noperation = failed");
        NSLog(@"\nerror = %@", error);
        NSLog(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
        //        NSDictionary* nsDict = [operation userInfo];
        NSInteger statusCode = operation.response.statusCode;
        if(statusCode == 404 || statusCode == 200) {
        } else if (statusCode == -1016){
        } else {
        }
    }];
    NSLog(@"OPERATION=%@", operation);
    [operation start];
}

#pragma mark Post Data to Woocommerce
- (AFHTTPRequestOperationManager *)initializeRequestManagerForPostMethod {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    UIWebView* webV= [[UIWebView alloc] init];
    NSString* userAgent = [NSString stringWithFormat:@"%@", [webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    manager.securityPolicy.allowInvalidCertificates = YES;
//    [manager.requestSerializer setTimeoutInterval:30];
    return manager;
}
- (NSString *)initializeRequestStringForPostMethod:(NSString*)requestedUrl {
    NSLog(@"%@",requestedUrl);
    requestURL = [NSString stringWithString:requestedUrl];
    NSString* params = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]]];
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"POST&%@&%@", urlStr, paramString];
    
    NSString* algoKey;
    if([self.version_string isEqualToString:@"v2"]) {
        algoKey = self.oauth_consumer_secret;
    }else if([self.version_string isEqualToString:@"v3"]) {
        algoKey = [NSString stringWithFormat:@"%@&", self.oauth_consumer_secret];
    }
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    //    if ([Utility containsString:requestURL substring:@"https"]) {
    //        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&consumer_key=%@&consumer_secret=%@", maxDataLimit, self.oauth_consumer_key, self.oauth_consumer_secret];
    //    }
    if ([self containsString:requestURL substring:@"https"]) {
        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&consumer_key=%@&consumer_secret=%@", 100, self.oauth_consumer_key, self.oauth_consumer_secret];
    }
    NSString *finalUrlStr = [NSString stringWithFormat:@"%@?%@",requestURL, params];
    NSLog(@"finalUrlStr = %@", finalUrlStr);
    return finalUrlStr;
}
- (void)createBlankOrder {
    NSDictionary* postParams = nil;//[[NSDictionary alloc] initWithDictionary:[self prepareBlankOrder:shippingMethod]];
    NSString* requestUrl = @"HERE USE REQUEST URL";
    NSString* URLString = [self initializeRequestStringForPostMethod:requestUrl];
    AFHTTPRequestOperationManager* manager = [self initializeRequestManagerForPostMethod];
    [manager POST:URLString parameters:postParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"\n==ResponseObject = %@\n\n", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = operation.response.statusCode;
        if(statusCode == 404 || statusCode == 200) {
            
        } else {
            
        }
    }];
}
@end