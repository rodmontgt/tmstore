//
//  KentPaymentViewController.m
//
//
//  Created by Rishabh Jain on 17/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "KentPaymentViewController.h"
#import "TMPaymentSDK.h"

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





@interface KentPaymentViewController (SEWebviewJSListenerNew)

@end
@implementation KentPaymentViewController

- (void)backButtonClicked:(id)sender{
    [self operationResult:false];
}

- (void)viewDidDisappear:(BOOL)animated {
    [PaymentUtility stopGrayLoadingBar];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    
    KentPaymentConfig* config= [KentPaymentConfig sharedManager];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:
                                 config.backButtonTitle style:UIBarButtonItemStyleBordered target:
                                 self action:@selector(backButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

    
    
    
//    [self.navigationItem set]
    //    NSString* linkStr = @"https://www.premihair.co.uk/apppayment/sagepay/";
    //    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    //    [webView setDelegate:self];
    //    [self.view addSubview:webView];
    //    NSURL *url = [NSURL URLWithString:linkStr];
    //    NSString *body = [NSString stringWithFormat:@"vendorname=%@&totalamount=%@&currency=%@&description=%@&billingsurname=%@&billingfirstname=%@&address=%@&city=%@&postcode=%@&country=%@&billingcountry=%@&platform=%@", @"firstcapitalltd", @"200", @"GBP", @"payment for my site", @"surname",  @"name", @"clifton", @"Bristol", @"BS82UE", @"GB", @"GB", @"ios"];
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    //    [request setHTTPMethod:@"POST"];
    //    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //    [webView loadRequest:request];
    
    
    
    //    NSString* linkStr = @"https://www.premihair.co.uk/apppayment/sagepay/success.php";
    //    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    //    [webView setDelegate:self];
    //    [self.view addSubview:webView];
    //    NSURL *url = [NSURL URLWithString:linkStr];
    //    NSString *body = [NSString stringWithFormat:@"\
    //                      vendorname=%@&\         //parse//
    //                      totalamount=%@&\        //customer
    //                      currency=%@&\           //customer
    //                      description=%@&\        //customer
    //                      billingsurname=%@&\     //customer
    //                      billingfirstname=%@&\   //customer
    //                      address=%@&\            //customer
    //                      city=%@&\               //customer
    //                      postcode=%@&\           //customer
    //                      country=%@&\            //customer
    //                      billingcountry=%@&\     //customer
    //                      platform=%@", @"firstcapitalltd", @"200", @"GBP", @"payment for my site", @"surname",  @"name", @"clifton", @"Bristol", @"BS82UE", @"GB", @"GB", @"ios"];
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    //    [request setHTTPMethod:@"POST"];
    //    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //    [webView loadRequest:request];
    [self pay];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        _responseDelegate = (TMPaymentSDKDelegate*)delegate;
    }
    return self;
}
- (void)pay {
    KentPaymentConfig* config = [KentPaymentConfig sharedManager];
    NSString* linkStr = config.cAccessUrl;//config.cVendorUrl;
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [webView setDelegate:self];
    [self.view addSubview:webView];
    NSURL *url = [NSURL URLWithString:linkStr];
//    NSString *body = [NSString stringWithFormat:@"vendorid=%@&totalamount=%@&currency=%@&description=%@&billingsurname=%@&billingfirstname=%@&address=%@&city=%@&postcode=%@&country=%@&billingcountry=%@&platform=%@&vendorpassword=%@&paymenturl=%@&responseurl=%@", config.cVendorId, [NSString stringWithFormat:@"%.2f", config.infoTotalAmount], config.infoCurrency, config.infoDescription, config.infoLastName, config.infoFirstName, config.infoAddress, config.infoCity, config.infoPostCode, config.infoCountry, config.infoCountry, config.infoPlatform, config.cVendorPassword, config.cVendorPaymentUrl, config.cVendorResponseUrl];
    
    NSString *body = [NSString stringWithFormat:@"totalamount=%@", [NSString stringWithFormat:@"%.2f", config.infoTotalAmount]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [webView loadRequest:request];
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
