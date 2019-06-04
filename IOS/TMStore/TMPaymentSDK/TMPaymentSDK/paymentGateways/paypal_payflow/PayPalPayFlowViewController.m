//
//  PayPalPayFlowViewController.m
//
//
//  Created by Rishabh Jain on 12/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "PayPalPayFlowViewController.h"
#import "TMPaymentSDK.h"
#import <CommonCrypto/CommonDigest.h>
#import "TMPaymentVariables.h"

@implementation NSObject (SEWebviewJSListenerNew)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    //NSLog(@"requestString = %@", requestString);
    
    NSArray *requestArray = [requestString componentsSeparatedByString:@":##sendToApp##"];
    if ([requestArray count] > 1){
        NSString *requestPrefix = [[requestArray objectAtIndex:0] lowercaseString];
        NSString *requestMssg = ([requestArray count] > 0) ? [requestArray objectAtIndex:1] : @"";
        [self webviewMessageKey:requestPrefix value:requestMssg];
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked && [self shouldOpenLinksExternally]) {
        // open links in safari
        //NSLog(@"open links in safari");
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

- (void)webviewMessageKey:(NSString *)key value:(NSString *)val {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    //NSLog(@"key=%@,val=%@", key, val);
}

- (BOOL)shouldOpenLinksExternally {
    return YES;
}

@end



@interface PayPalPayFlowViewController(){
    UIWebView *webviewPaymentPage;
}
@end

@interface PayPalPayFlowViewController (SEWebviewJSListenerNew)

@end
@implementation PayPalPayFlowViewController

- (void)backButtonClicked:(id)sender{
    [self operationResult:false];
}

- (void)viewDidDisappear:(BOOL)animated {
    [PaymentUtility stopGrayLoadingBar];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    PayPalPayFlowConfig* config = [PayPalPayFlowConfig sharedManager];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:
                                   config.backButtonTitle style:UIBarButtonItemStyleBordered target:
                                   self action:@selector(backButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    if (webviewPaymentPage == nil) {
        webviewPaymentPage = [[UIWebView alloc] initWithFrame:self.view.frame];
        [webviewPaymentPage setDelegate:self];
        [self.view addSubview:webviewPaymentPage];
    }
    [self pay];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    PayPalPayFlowConfig* config = [PayPalPayFlowConfig sharedManager];
    [self setTitle:config.paymentPageTitle];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self setTitle:@""];
}
- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        _responseDelegate = (TMPaymentSDKDelegate*)delegate;
    }
    return self;
}


//"amount"
//"first_name"
//"last_name"
//"email"
//"phone"
//"billingAddress1"
//"billingAddress2"
//"billingCity"
//"billingState"
//"billingZip"
//"billingCountry"
//"PARTNER"
//"VENDOR"
//"USER"
//"PWD"

- (void)pay {
    if (0) {
        PayPalPayFlowConfig* config = [PayPalPayFlowConfig sharedManager];
        NSString* linkStr = config.cBackendUrl;
        UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        [webView setDelegate:self];
        [self.view addSubview:webView];
        NSURL *url = [NSURL URLWithString:linkStr];
        //    NSString *body = [NSString stringWithFormat:@"totalamount=%@", [NSString stringWithFormat:@"%.2f", config.infoTotalAmount]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        //    [request setHTTPMethod:@"POST"];
        //    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [webView loadRequest:request];
    }
    else {
        UIActivityIndicatorView* sV = [PaymentUtility startGrayLoadingBar:true];
        sV.center = self.view.center;
        PayPalPayFlowConfig* config = [PayPalPayFlowConfig sharedManager];
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        NSString* amtStr = [NSString stringWithFormat:@"%.2f", config.infoTotalAmount];
        [params setObject:base64_str(amtStr) forKey:@"amount"];
        [params setObject:base64_str(config.infoFirstName) forKey:@"first_name"];
        [params setObject:base64_str(config.infoLastName) forKey:@"last_name"];
        [params setObject:base64_str(config.infoEmail) forKey:@"email"];
        [params setObject:base64_str(config.infoPhone) forKey:@"phone"];
        [params setObject:base64_str(config.infoBillingAdd1) forKey:@"billingAddress1"];
        [params setObject:base64_str(config.infoBillingAdd2) forKey:@"billingAddress2"];
        [params setObject:base64_str(config.infoCity) forKey:@"billingCity"];
        [params setObject:base64_str(config.infoState) forKey:@"billingState"];
        [params setObject:base64_str(config.infoPostCode) forKey:@"billingZip"];
        [params setObject:base64_str(config.infoCountry) forKey:@"billingCountry"];
        [params setObject:base64_str(config.infoCurrency) forKey:@"currency"];
        [params setObject:base64_str(config.infoPlatform) forKey:@"platform"];
        
        
//        [params setObject:(amtStr) forKey:@"amount"];
//        [params setObject:(config.infoFirstName) forKey:@"first_name"];
//        [params setObject:(config.infoLastName) forKey:@"last_name"];
//        [params setObject:(config.infoEmail) forKey:@"email"];
//        [params setObject:(config.infoPhone) forKey:@"phone"];
//        [params setObject:(config.infoBillingAdd1) forKey:@"billingAddress1"];
//        [params setObject:(config.infoBillingAdd2) forKey:@"billingAddress2"];
//        [params setObject:(config.infoCity) forKey:@"billingCity"];
//        [params setObject:(config.infoState) forKey:@"billingState"];
//        [params setObject:(config.infoPostCode) forKey:@"billingZip"];
//        [params setObject:(config.infoCountry) forKey:@"billingCountry"];
//        [params setObject:(config.infoCurrency) forKey:@"currency"];
//        [params setObject:(config.infoPlatform) forKey:@"platform"];
        __block NSString *post = @"";
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([post isEqualToString:@""]) {
                post = [NSString stringWithFormat:@"%@=%@", key, obj];
            } else {
                post = [NSString stringWithFormat:@"%@&%@=%@", post, key, obj];
            }
        }];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",config.cBackendUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        [request setHTTPBody:postData];
        [webviewPaymentPage setDelegate:self];
        [webviewPaymentPage loadRequest:request];
        //    [activityIndicatorView startAnimating];
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //NSLog(@"webViewDidStartLoad");
    UIActivityIndicatorView* sV = [PaymentUtility startGrayLoadingBar:true];
    sV.center = self.view.center;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //NSLog(@"webViewDidFinishLoad");
    [PaymentUtility stopGrayLoadingBar];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(/*nullable*/ NSError *)error {
    //NSLog(@"webView didFailLoadWithError");
    PLOG(@"WebView failed loading with requestURL: %@ with error: %@ & error code: %ld",requestURL, [error localizedDescription], (long)[error code]);
    if (error.code == -1009 || error.code == -1003 || error.code == -1001) { //error.code == -999
        [self operationResult:false];
    }
}
- (void)webviewMessageKey:(NSString *)key value:(NSString *)val {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    //NSLog(@"key=%@,val=%@", key, val);
    BOOL success = false;
    if ([[key lowercaseString] isEqualToString:@"payment"]) {
        if ([[val lowercaseString] isEqualToString:@"success"]) {
            success = true;
        }
    }
    [self operationResult:success];
}
- (BOOL)shouldOpenLinksExternally {
    return NO;
}
- (void)operationResult:(BOOL)success{
    [PaymentUtility stopGrayLoadingBar];
    if (success) {
        [self dismissViewControllerAnimated:YES completion:^{
            [_responseDelegate postCompletionCallbackWithSuccess:nil];
            _responseDelegate = nil;
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [_responseDelegate postCompletionCallbackWithFailure:nil];
            _responseDelegate = nil;
        }];
    }
}
@end
