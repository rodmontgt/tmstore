//
//  MV2X_Engine.m
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//

#import "MV2X_Engine.h"
#import "CommonInfo.h"
#import "Variables.h"
#import "AppUser.h"
#import "Order.h"
#import "Variation.h"
#import "ServerData.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "Attribute.h"
#import "CategoryInfo.h"
#import <STHTTPRequest/STHTTPRequest.h>


#define MV2XLOG(format, ...) RLOG((@"MV2X: %s [Line %d]\n" format @"\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface MV2X_Engine()
{
    NSString *oauth_signature;
    NSString *oauth_nonce;
    NSString *time_stamp;
    NSString *requestURL;
    NSMutableData *_responseData;
}
@end
@implementation MV2X_Engine
- (id)initEngineWithBaseUrl:(NSString*)baseUrl storeVersion:(NSString*)storeVersion  consumerKey:(NSString*)consumerKey consumerSecretKey:(NSString*)consumerSecretKey pagelinkContactus:(NSString*)pagelinkContactus pagelinkAboutus:(NSString*)pagelinkAboutus{
    self = [super init];
    if (self) {
        self.tmJsonHelper = [[MV2X_JsonHelper alloc] initWithEngine:self];
        self.tmMulticastDelegate = [TMMulticastDelegate new];
        //        self.mrActivityIndicatorView = [[MRActivityIndicatorView alloc] init];
        //        [self.mrActivityIndicatorView setFrame:CGRectMake(0, 0, 50, 50)];
        self.serverDatas = [[NSMutableArray alloc] init];
        //        [self.mrActivityIndicatorView setTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
        self.baseUrl = baseUrl;
        self.version_string = storeVersion;
        self.oauth_consumer_key = consumerKey;
        self.oauth_consumer_secret = consumerSecretKey;
        
        
        self.oauth_token = @"";
        self.request_url_products = [NSString stringWithFormat:@"%@/wc-api/%@/products", self.baseUrl, self.version_string];
        self.request_url_customer = [NSString stringWithFormat:@"%@/wc-api/%@/customers", self.baseUrl, self.version_string];
        self.request_url_orders = [NSString stringWithFormat:@"%@/wc-api/%@/orders", self.baseUrl, self.version_string];
        self.request_url_categories = [NSString stringWithFormat:@"%@/wc-api/%@/products/categories", self.baseUrl, self.version_string];
        self.request_url_common = [NSString stringWithFormat:@"%@/wc-api/%@", self.baseUrl, self.version_string];
        
        self.createUserPageLink = [NSString stringWithFormat:@"%@", self.baseUrl];
        self.externalLoginPageLink = [NSString stringWithFormat:@"%@", self.baseUrl];
        //        self.loginPageLink = [NSString stringWithFormat:@"%@/wp-login.php", self.baseUrl];
        self.loginPageLink = [NSString stringWithFormat:@"%@/wp-login.php?user_platform=Android", self.baseUrl];
        self.productPageBaseUrl = [NSString stringWithFormat:@"%@?p=", self.baseUrl];
        self.external_login_url = [NSString stringWithFormat:@"%@/?user_platform=IOS", self.baseUrl];
        self.external_signup_url = [NSString stringWithFormat:@"%@/?user_platform=IOS", self.baseUrl];
        self.cart_url = [NSString stringWithFormat:@"%@/cart/", self.baseUrl];
        self.checkout_url = [NSString stringWithFormat:@"%@/checkout?device_type=IOS", self.baseUrl];
        
        //        For Login the end point is http://house4web.com/csi-jobs/wp-tm-store-notify/api/login/
        //        For Social login the endpoint is http://house4web.com/csi-jobs/wp-tm-store-notify/api/social-login/
        //        For register the endpoint is http://house4web.com/csi-jobs/wp-tm-store-notify/api/register/
        //        For forget password the endpoint is http://house4web.com/csi-jobs/wp-tm-store-notify/api/forget-password/
        //        user_name
        //        user_emailID
        //        user_pass
        //        user_platform
        self.pagelinkAboutUs = pagelinkAboutus;
        self.pagelinkContactUs = pagelinkContactus;
    }
    return self;
}
#pragma mark Private Methods
- (NSString *)getRFC3986:(NSString *)str {
    NSString *strR = [NSString stringWithString:[str st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    RLOG(@"STR RFC3986 = %@", strR);
    return strR;
}
- (NSString *)hmacsha1:(NSString *)plaintext key:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [HMAC base64EncodedString];
    RLOG(@"STR Hash = %@", hash);
    return hash;
}
- (NSString *)randomStringWithLength:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    RLOG(@"STR Random = %@", randomString);
    return randomString;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    RLOG(@"didReceiveResponse");
    //[received_data setLength:0];//Set your data to 0 to clear your buffer
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    RLOG(@"didReceiveData");
    //[received_data appendData:data];//Append the download data..
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    RLOG(@"connection");
    //Use your downloaded data here
}
#pragma mark Data Fetching
//- (AFHTTPRequestOperation *)getRequestOperation:(NSString *)requestedUrl isPostMethod:(BOOL)_isPostMethod {
//    RLOG(@"%@",requestedUrl);
//    requestURL = [NSString stringWithString:requestedUrl];
//    NSString* params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=100&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_version=%@",self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]],@"1.0"];
//    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
//    urlStr = [self getRFC3986:urlStr];
//    NSString* paramString = [NSString stringWithFormat:@"%@", params];
//    paramString = [self getRFC3986:paramString];
//    NSString* algoString = [NSString stringWithFormat:@"GET&%@&%@", urlStr, paramString];
//    NSString* algoKey = self.oauth_consumer_secret;
//    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
//    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
//    NSString *finalUrlStr =[NSString stringWithFormat:@"%@?%@",requestURL, params];
//    NSURL *url = [NSURL URLWithString:finalUrlStr];
//    RLOG(@"url=%@",url);
//    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
//    if (_isPostMethod) {
//        [request setHTTPMethod:@"POST"];
//    } else {
//        [request setHTTPMethod:@"GET"];
//    }
//    RLOG(@"request = %@", request);
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    return operation;
//}
//#pragma mark Fetch Data From Server
//- (ServerData *)fetchDataFromServer:(NSString *)_urlString dataId:(int)_dataId view:(UIView *)_view {
//    AFHTTPRequestOperation *operation = [self getRequestOperation:_urlString isPostMethod:false];
//    
//    ServerData *sData = [[ServerData alloc] init];
//    sData._serverUrl = [NSString stringWithString:_urlString];
//    sData._serverRequest = operation;
//    //    sData._serverRequestName = [NSString stringWithString:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getUnixTimeString]]];
//    sData._serverRequestStatus = kServerRequestStart;
//    sData._serverDataId = _dataId;
//    [self.serverDatas addObject:sData];
//    
//    NSDictionary* nsDict = [[NSDictionary alloc] initWithObjectsAndKeys:sData, @"SERVERDATA", nil];
//    [operation setUserInfo:nsDict];
//    
//    //    self.mrActivityIndicatorView.center=_view.center;
//    //    [_view addSubview:self.mrActivityIndicatorView];
//    //    [self.mrActivityIndicatorView setAnimatingWithStateOfOperation:operation];
//    
//    BOOL isDataNotFound = true;
//    if (CHECK_PRELOADED_DATA) {
//        NSString *jsonString = [[NSUserDefaults standardUserDefaults] objectForKey:sData._serverUrl];
//        if (jsonString) {
//            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//            if (data) {
//                id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                if (jsonDict) {
//                    sData._serverResultDictionary = (NSDictionary*) jsonDict;
//                    if (sData._serverResultDictionary) {
//                        sData._serverRequestStatus = kServerRequestSucceed;
//                        isDataNotFound = false;
//                        [self.tmMulticastDelegate respondToDelegates:sData];
//                    }
//                }
//            }
//        }
//    }
//    
//    if (isDataNotFound) {
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary* nsDict = [operation userInfo];
//            ServerData *sData = (ServerData *)[nsDict objectForKey:@"SERVERDATA"];
//            sData._serverResultDictionary = (NSDictionary *)responseObject;
//            sData._serverRequestStatus = kServerRequestSucceed;
//            [self.tmMulticastDelegate respondToDelegates:sData];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            //        [alertView show];
//            RLOG(@"\nerror = %@", error);
//            RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
//            NSDictionary* nsDict = [operation userInfo];
//            ServerData *sData = (ServerData *)[nsDict objectForKey:@"SERVERDATA"];
//            sData._serverRequestStatus = kServerRequestFailed;
//            [self.tmMulticastDelegate respondToDelegates:sData];
//        }];
//        [operation start];
//    }
//    
//    return sData;
//}
//- (ServerData*)fetchCommonData:(UIView*)view {
//    return [self fetchDataFromServer:self.request_url_common dataId:kFetchCommonData view:view];
//}
//- (ServerData*)fetchCategoriesData:(UIView*)view {
//    return [self fetchDataFromServer:self.request_url_categories dataId:kFetchCategories view:view];
//}
//- (ServerData*)fetchProductData:(UIView*)view {
//    return [self fetchDataFromServer:self.request_url_products dataId:kFetchProducts view:view];
//}
//- (ServerData*)fetchCustomerData:(UIView*)view userEmail:(NSString*)userEmail {
//    return [self fetchDataFromServer:
//            [NSString stringWithFormat:@"%@/email/%@", self.request_url_customer, userEmail] dataId:kFetchCustomer view:view];
//}
//- (ServerData*)fetchOrdersData:(UIView*)view {
//    return [self fetchDataFromServer:[NSString stringWithFormat:@"%@", self.request_url_orders] dataId:kFetchOrders view:view];
//}
//- (ServerData*)fetchCouponsData:(UIView*)view {
//    return [self fetchDataFromServer:[NSString stringWithFormat:@"%@", self.request_url_coupons] dataId:kFetchCoupons view:view];
//}
//- (void)checkPostMethod{}

@end