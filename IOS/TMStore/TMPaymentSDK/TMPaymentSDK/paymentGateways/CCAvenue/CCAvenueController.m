//
//  CCAvenueController.m
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 04/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "CCAvenueController.h"
#import "CCTool.h"

@implementation CCAvenueController

- (id)initWithDelegate:(TMPaymentSDKDelegate*)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CCAvenueConfig* config= [CCAvenueConfig getInstance];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:
                                   config.backButtonTitle style:UIBarButtonItemStyleBordered target:
                                   self action:@selector(backButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
  
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    _webView.backgroundColor = [UIColor whiteColor];
//    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];

    NSString* accessCode = config.accessCode;
    NSString* merchantId = config.merchantId;
    NSString* orderId = [NSString stringWithFormat:@"%d", config.orderId];
    NSString* amount = [NSString stringWithFormat:@"%f", config.amount];
    NSString* currency = config.currency;
    NSString* redirectUrl = config.redirectUrl;
    NSString* cancelUrl = config.cancelUrl;
    NSString* rsaKeyUrl = config.rsaKeyUrl;

    //Getting RSA Key
    NSString *rsaKeyDataStr = [NSString stringWithFormat:@"access_code=%@&order_id=%@", accessCode, orderId];
    NSData *requestData = [NSData dataWithBytes: [rsaKeyDataStr UTF8String] length: [rsaKeyDataStr length]];
    NSMutableURLRequest *rsaRequest = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: rsaKeyUrl]];
    [rsaRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [rsaRequest setHTTPMethod: @"POST"];
    [rsaRequest setHTTPBody: requestData];
    NSData *rsaKeyData = [NSURLConnection sendSynchronousRequest: rsaRequest returningResponse: nil error: nil];
    NSString *rsaKey = [[NSString alloc] initWithData:rsaKeyData encoding:NSASCIIStringEncoding];
    rsaKey = [rsaKey stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    rsaKey = [NSString stringWithFormat:@"-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----\n",rsaKey];
    NSLog(@"%@",rsaKey);

    //Encrypting Card Details
    NSString *myRequestString = [NSString stringWithFormat:@"amount=%@&currency=%@", amount, currency];
    CCTool *ccTool = [[CCTool alloc] init];
    NSString *encVal = [ccTool encryptRSA:myRequestString key:rsaKey];
    encVal = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                   (CFStringRef)encVal,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8 ));
    //Preparing for a webview call
    NSString *urlAsString = [NSString stringWithFormat:@"https://secure.ccavenue.com/transaction/initTrans"];
    NSString *encryptedStr = [NSString stringWithFormat:@"merchant_id=%@&order_id=%@&redirect_url=%@&cancel_url=%@&enc_val=%@&access_code=%@",merchantId,orderId,redirectUrl,cancelUrl,encVal,accessCode];

    NSData *myRequestData = [NSData dataWithBytes: [encryptedStr UTF8String] length: [encryptedStr length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: urlAsString]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:urlAsString forHTTPHeaderField:@"Referer"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: myRequestData];
    [_webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [PaymentUtility stopGrayLoadingBar];
    NSString *string = webView.request.URL.absoluteString;
    if ([string rangeOfString:@"/ccavResponseHandler.php"].location != NSNotFound) {
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        if (([html rangeOfString:@"Success"].location != NSNotFound)) {
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"Payment successful for non seamless CCAvenue gateway.");
                [self.delegate postCompletionCallbackWithSuccess:nil];
                self.delegate = nil;
            }];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"Payment failure for non seamless CCAvenue gateway.");
                [self.delegate postCompletionCallbackWithFailure:nil];
                self.delegate = nil;
            }];
        }
    }
}
- (void)backButtonClicked:(id)sender{
    [PaymentUtility stopGrayLoadingBar];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate postCompletionCallbackWithFailure:nil];
        self.delegate = nil;
    }];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //NSLog(@"webViewDidStartLoad");
    UIActivityIndicatorView* sV = [PaymentUtility startGrayLoadingBar:true];
    sV.center = self.view.center;
}
@end
