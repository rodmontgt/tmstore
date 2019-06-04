//
//  SampleTestMagento.m
//  TMStore
//
//  Created by V S Khutal on 24/07/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "SampleTestMagento.h"

@implementation SampleTestMagento
static SampleTestMagento *sharedObj = nil;
+ (id)sharedManager {
    if (sharedObj == nil)
        sharedObj = [[self alloc] init];
    return sharedObj;
}
- (id)init {
    if (self = [super init]) {
    }
    return self;
}
- (void)testMagentoPost {
    //initialize variables
    NSString* m_oauth_callback = @"http://localhost";
    NSString* m_oauth_nonce = [self randomStringWithLength:32];
    NSString* m_oauth_signature_method = @"HMAC-SHA1";
    NSString* m_oauth_timestamp = [NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]];
    NSString* m_oauth_consumer_key = @"77a25d495babcab5df31854cc6fadc97";
    NSString* m_oauth_consumer_secret = @"4972db1a08e3bc13252a5036ed7e93df";
    NSString* strRequest = @"http://192.168.21.241/magento192/oauth/initiate";
    //initialize parameters
    NSMutableDictionary* urlParameters = [[NSMutableDictionary alloc] init];
    [urlParameters setValue:m_oauth_consumer_key forKey:@"oauth_consumer_key"];
    [urlParameters setValue:m_oauth_nonce forKey:@"oauth_nonce"];
    [urlParameters setValue:m_oauth_signature_method forKey:@"oauth_signature_method"];
    [urlParameters setValue:m_oauth_timestamp forKey:@"oauth_timestamp"];
    [urlParameters setValue:m_oauth_callback forKey:@"oauth_callback"];
    //initialize param string
    NSString* strParams = [NSString stringWithFormat:@"oauth_callback=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@",m_oauth_callback, m_oauth_consumer_key, m_oauth_nonce, m_oauth_signature_method, m_oauth_timestamp];
    NSString* temp_strRequest = [NSString stringWithFormat:@"%@", strRequest];
    NSString* temp_strParams = [NSString stringWithFormat:@"%@", strParams];
    temp_strRequest = [self getRFC3986:temp_strRequest];
    temp_strParams = [self getRFC3986:temp_strParams];
    
    NSString* algoString = [NSString stringWithFormat:@"POST&%@&%@", temp_strRequest, temp_strParams];
    NSString* algoKey = m_oauth_consumer_secret;
    NSString* m_oauth_signature = [self hmacsha1:algoString key:algoKey];
    [urlParameters setValue:m_oauth_signature forKey:@"oauth_signature"];
    
    strParams = [NSString stringWithFormat:@"%@&oauth_signature=%@", strParams, m_oauth_signature];
    NSString *finalUrlStr = [NSString stringWithFormat:@"%@?%@",strRequest, strParams];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer = [CustomJSONSerializer serializer];
    //    manager.requestSerializer =  [AFHTTPRequestSerializer serializer];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    //    manager.responseSerializer = responseSerializer;
    //    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
    
    
    UIWebView* webV= [[UIWebView alloc] init];
    NSString* userAgent = [NSString stringWithFormat:@"%@", [webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    
    
    //    NSMutableDictionary *paramsToPost = [[NSMutableDictionary alloc]init];
    //    [paramsToPost setObject:@"fure@gmail.com" forKey:@"user_emailID"];
    //    [paramsToPost setObject:@"1" forKey:@"user_pass"];
    
    //    NSMutableDictionary *paramsToPost = @{ @"user_emailID": [[@"fure@gmail.com" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
    //      @"user_pass": [[@"1" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
    NSDictionary *paramsToPost = @{
                                   @"user_emailID": [[@"fure@gmail.com" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                                   @"user_pass": [[@"1" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
    
    
    
    //
    //    urlParameters.add(new BasicNameValuePair("user_emailID", new String(Base64.encodeBase64("fure@gmail.com".getBytes())))) ;
    //    urlParameters.add(new BasicNameValuePair("user_pass", new String(Base64.encodeBase64("1".getBytes()))));
    
    
    
    [manager POST:strRequest parameters:paramsToPost success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"\n==ResponseObject = %@\n\n", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"\n==Error = %@\n\n", error);
        RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\nerrorCode = %d", [error localizedDescription], [error localizedFailureReason], (int)[error code]);
        NSInteger statusCode = operation.response.statusCode;
        if(statusCode == 404 || statusCode == 200) {
            
        } else {
            
        }
    }];
    
    
    //    NSMutableDictionary *paramsToPost = [[NSMutableDictionary alloc] initWithDictionary:urlParameters];
    //    NSMutableDictionary *subParams = [[NSMutableDictionary alloc]init];
    //    [paramsToPost setObject:subParams forKey:@"customer"];
    //    [subParams setObject:@"rishabh" forKey:@"first_name"];
    
    //    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
    
    //    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    //    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Accept"];
    //    NSError *error;
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:urlParameters options:0 error:&error];
    //    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //        [manager setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    
    
}
- (void)testWooCommercePost {
    NSString* oauth_nonce = [self randomStringWithLength:32];
    NSString* oauth_signature_method = @"HMAC-SHA1";
    NSString* oauth_timestamp = [NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]];
    NSString* oauth_consumer_key = @"ck_63829de745135b919f6518776e4940ad1e7ca487";
    NSString* oauth_consumer_secret = @"cs_6c72af7acb9c912f8d384e4714d352601ce6e7b5";
    NSString* requestUrlString = @"http://playcontest.in/demo/wordpress/wc-api/v2/customers/2";
    NSMutableDictionary* urlParameters = [[NSMutableDictionary alloc] init];
    [urlParameters setValue:oauth_consumer_key forKey:@"oauth_consumer_key"];
    [urlParameters setValue:oauth_nonce forKey:@"oauth_nonce"];
    [urlParameters setValue:oauth_signature_method forKey:@"oauth_signature_method"];
    [urlParameters setValue:oauth_timestamp forKey:@"oauth_timestamp"];
    
    NSString* params = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", oauth_consumer_key, oauth_nonce, oauth_signature_method, oauth_timestamp];
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestUrlString];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    
    NSString* algoString = [NSString stringWithFormat:@"POST&%@&%@", urlStr, paramString];
    NSString* algoKey = self.oauth_consumer_secret;
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    [urlParameters setValue:_oauth_signature forKey:@"oauth_signature"];
    
    
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    NSString *finalUrlStr = [NSString stringWithFormat:@"%@?%@",requestUrlString, params];
    
    
    NSDictionary* postParams = [[NSDictionary alloc] initWithDictionary:urlParameters];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    UIWebView* webV= [[UIWebView alloc] init];
    NSString* userAgent = [NSString stringWithFormat:@"%@", [webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    
    
    
    
    
    
    NSMutableDictionary *paramsToPost = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *subParams = [[NSMutableDictionary alloc]init];
    [paramsToPost setObject:subParams forKey:@"customer"];
    [subParams setObject:@"rishabh" forKey:@"first_name"];
    
    
    
    
    
    
    
    [manager POST:finalUrlStr parameters:paramsToPost success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
