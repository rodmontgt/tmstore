//
//  HesabePaymentViewController.m
//  PaymentGateway
//
//  Created by Rishabh Jain on 12/05/17.
//

#import "HesabePaymentViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "TMPaymentSDK.h"

@interface HesabePaymentViewController(){
    UIActivityIndicatorView *activityIndicatorView;
    NSString *strMIHPayID;
    UIWebView *webviewPaymentPage;
}
@end

@implementation HesabePaymentViewController
- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        self.successURL = @"";
        self.failureURL = @"";
        self.baseURL = @"";
        self.amountStr = @"";
        self.amount = 0.0f;
        _responseDelegate = (TMPaymentSDKDelegate*)delegate;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    HesabePaymentConfig* config = [HesabePaymentConfig sharedManager];
    [self setTitle:config.paymentPageTitle];
    [self pay];
}
- (void)viewWillDisappear:(BOOL)animated {
    [PaymentUtility stopGrayLoadingBar];
    [super viewWillDisappear:YES];
    [self setTitle:@""];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    HesabePaymentConfig* config = [HesabePaymentConfig sharedManager];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:
                                   config.backButtonTitle style:UIBarButtonItemStyleBordered target:
                                   self action:@selector(backButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    activityIndicatorView.center = self.view.center;
    [activityIndicatorView setColor:[UIColor blackColor]];
    [self.view addSubview:activityIndicatorView];
    if (webviewPaymentPage == nil) {
        CGRect rect = self.view.frame;
        rect.origin.y = self.navigationController.navigationBar.frame.size.height + 20;
        rect.size.height -= rect.origin.y;
        webviewPaymentPage = [[UIWebView alloc] initWithFrame:rect];
        [webviewPaymentPage setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:webviewPaymentPage];
        [webviewPaymentPage setScalesPageToFit:false];
        [webviewPaymentPage setDelegate:self];
    }
}
- (void)backButtonClicked:(id)sender{
    [self operationResult:false];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)pay {
    UIActivityIndicatorView* sV = [PaymentUtility startGrayLoadingBar:true];
    sV.center = self.view.center;
    HesabePaymentConfig* config = [HesabePaymentConfig sharedManager];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    self.amountStr = [NSString stringWithFormat:@"%.2f", config.infoTotalAmount];
    self.successURL = config.cSuccessUrl;
    self.failureURL = config.cFailureUrl;
    [params setObject:base64_str(self.amountStr) forKey:@"amount"];
    [params setObject:base64_str(self.successURL) forKey:@"surl"];
    [params setObject:base64_str(self.failureURL) forKey:@"furl"];
    [params setObject:base64_str(config.infoName) forKey:@"name"];
    [params setObject:base64_str(config.infoPhone) forKey:@"phonenumber"];
    [params setObject:base64_str(config.infoEmail) forKey:@"email"];
    [params setObject:base64_str(config.infoDescription) forKey:@"description"];
    [params setObject:base64_str(config.infoOrderId) forKey:@"orderid"];

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
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",config.cBaseUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    [webviewPaymentPage setDelegate:self];
    [webviewPaymentPage loadRequest:request];
}

- (NSString *)createSHA512:(NSString *)string {
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

#pragma UIWebView - Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)type {
    NSURL *requestURL = [[webviewPaymentPage request] URL];
    NSString *getStringFromUrl = [NSString stringWithFormat:@"%@",requestURL];
    if ([self containsString:getStringFromUrl:self.successURL]) {
        [self operationResult:true];
        return NO;
    } else if ([self containsString:getStringFromUrl:self.failureURL]) {
        [self operationResult:false];
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    PLOG(@"%s", __PRETTY_FUNCTION__);
    UIActivityIndicatorView* sV = [PaymentUtility startGrayLoadingBar:true];
    sV.center = self.view.center;
    NSURL *requestURL = [[webviewPaymentPage request] URL];
    NSString *getStringFromUrl = [NSString stringWithFormat:@"%@",requestURL];
    if ([self containsString:getStringFromUrl:self.successURL]) {
        [self operationResult:true];
    } else if ([self containsString:getStringFromUrl:self.failureURL]) {
        [self operationResult:false];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    PLOG(@"%s", __PRETTY_FUNCTION__);
    [PaymentUtility stopGrayLoadingBar];
    NSURL *requestURL = [[webviewPaymentPage request] URL];
    NSString *getStringFromUrl = [NSString stringWithFormat:@"%@",requestURL];
    if ([self containsString:getStringFromUrl:self.successURL]) {
        [self operationResult:true];
    } else if ([self containsString:getStringFromUrl:self.failureURL]) {
        [self operationResult:false];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    PLOG(@"%s", __PRETTY_FUNCTION__);
    NSURL *requestURL = [[webviewPaymentPage request] URL];
    NSString *getStringFromUrl = [NSString stringWithFormat:@"%@",requestURL];
    if ([self containsString:getStringFromUrl:self.successURL]) {
        [self operationResult:true];
        return;
    } else if ([self containsString:getStringFromUrl:self.failureURL]) {
        [self operationResult:false];
        return;
    }
    PLOG(@"WebView failed loading with requestURL: %@ with error: %@ & error code: %ld",requestURL, [error localizedDescription], (long)[error code]);
    if (error.code == -1009 || error.code == -1003 || error.code == -1001) { //error.code == -999
        [self operationResult:false];
    }
}
- (BOOL)containsString: (NSString *)string : (NSString*)substring {
    PLOG(@"%s", __PRETTY_FUNCTION__);
    return [string rangeOfString:substring].location != NSNotFound;
}
- (void)operationResult:(BOOL)success{
    PLOG(@"%s", __PRETTY_FUNCTION__);
    [PaymentUtility stopGrayLoadingBar];
    [webviewPaymentPage setDelegate:nil];
    [webviewPaymentPage stopLoading];
    [activityIndicatorView stopAnimating];
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
