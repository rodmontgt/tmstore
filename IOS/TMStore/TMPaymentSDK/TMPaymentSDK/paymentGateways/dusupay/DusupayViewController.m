//
//  DusupayViewController.m
//  PaymentGateway
//
//  Created by Rishabh Jain on 25/11/16.
//

#import "DusupayViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "TMPaymentSDK.h"

@interface DusupayViewController(){
//    UIActivityIndicatorView *activityIndicatorView;
    UIWebView *webviewPaymentPage;
    NSString* baseURL;
}
@end

@implementation DusupayViewController

- (id)initWithPayment:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _responseDelegate = (TMPaymentSDKDelegate*)[dict valueForKey:@"Delegate"];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    DusupayConfig* config = [DusupayConfig sharedManager];
    [self setTitle:config.paymentPageTitle];
    [self initPayment];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self setTitle:@""];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    DusupayConfig* config = [DusupayConfig sharedManager];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:
                                   config.backButtonTitle style:UIBarButtonItemStyleBordered target:
                                   self action:@selector(backButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

    
    
//    activityIndicatorView = [[UIActivityIndicatorView alloc] init];
//    activityIndicatorView.center = self.view.center;
//    [activityIndicatorView setColor:[UIColor blackColor]];
//    [self.view addSubview:activityIndicatorView];
    if (webviewPaymentPage == nil) {
        webviewPaymentPage = [[UIWebView alloc] initWithFrame:self.view.frame];
        [webviewPaymentPage setDelegate:self];
        [self.view addSubview:webviewPaymentPage];
        
        
//        webviewPaymentPage = [[UIWebView alloc] initWithFrame:self.view.frame];
//        [webviewPaymentPage setBackgroundColor:[UIColor clearColor]];
//        [self.view addSubview:webviewPaymentPage];
//        [webviewPaymentPage setScalesPageToFit:false];
//        [webviewPaymentPage setDelegate:self];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initPayment {
    UIActivityIndicatorView* sV = [PaymentUtility startGrayLoadingBar:true];
    sV.center = self.view.center;
    
    
    DusupayConfig* config = [DusupayConfig sharedManager];
     if (config.cIsSandboxMode) {
        baseURL = @"http://sandbox.dusupay.com/dusu_payments/dusupay";
        self.dusupay_environment = @"sandbox";
    } else {
        baseURL = @"https://dusupay.com/dusu_payments/dusupay";
        self.dusupay_environment = @"";
    }
    self.dusupay_hash = @"";
    self.dusupay_itemId = @"Item";
    self.dusupay_itemName = @"MyItem";
    self.dusupay_transactionReference = @"";
    
    
    
    int i = arc4random() % 9999999999;
    NSString *strHash = [self createSHA1:[NSString stringWithFormat:@"%d%@",i,[NSDate date]]];
    self.dusupay_transactionReference = [strHash substringToIndex:20];
    
    self.dusupay_amount = [NSString stringWithFormat:@"%.2f", config.infoTotalAmount];
    self.dusupay_currency = config.infoCurrency;
    self.dusupay_merchantId = config.cMerchantId;
    self.dusupay_redirectURL = config.cRedirectUrl;
    self.dusupay_successURL = config.cSuccessUrl;
    
//    NSString *hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@", _dusupay_merchantId, _dusupay_amount, _dusupay_currency, _dusupay_itemId, _dusupay_itemName, _dusupay_transactionReference];
//    self.dusupay_hash = [self createSHA1:hashValue];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:base64_str(self.dusupay_merchantId) forKey:@"dusupay_merchantId"];
    [params setObject:base64_str(self.dusupay_amount) forKey:@"dusupay_amount"];
    [params setObject:base64_str(self.dusupay_currency) forKey:@"dusupay_currency"];
    [params setObject:base64_str(self.dusupay_itemId) forKey:@"dusupay_itemId"];
    [params setObject:base64_str(self.dusupay_itemName) forKey:@"dusupay_itemName"];
    [params setObject:base64_str(self.dusupay_transactionReference) forKey:@"dusupay_transactionReference"];
    [params setObject:base64_str(self.dusupay_redirectURL) forKey:@"dusupay_redirectURL"];
    [params setObject:base64_str(self.dusupay_successURL) forKey:@"dusupay_successURL"];
//    [params setObject:base64_str(self.dusupay_hash) forKey:@"dusupay_hash"];
    if (config.cIsSandboxMode) {
        [params setObject:base64_str(self.dusupay_environment) forKey:@"dusupay_environment"];
    }
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
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",baseURL]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    [webviewPaymentPage setDelegate:self];
    [webviewPaymentPage loadRequest:request];
//    [activityIndicatorView startAnimating];
}

- (NSString *)createSHA1:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
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
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [self checkURL];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self checkURL];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [PaymentUtility stopGrayLoadingBar];
    [self checkURL];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [PaymentUtility stopGrayLoadingBar];
    [self checkURL];
//    NSLog(@"WebView failed loading with requestURL: %@ with error: %@ & error code: %ld",[[webviewPaymentPage request] URL], [error localizedDescription], (long)[error code]);
    if (error.code == -1009 || error.code == -1003 || error.code == -1001) { //error.code == -999
        [self operationResult:false];
    }
}
- (BOOL)containsString: (NSString *)string : (NSString*)substring {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [string rangeOfString:substring].location != NSNotFound;
}
- (void)checkDusupayStatus {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [webviewPaymentPage setDelegate:nil];
    [webviewPaymentPage stopLoading];
//    [activityIndicatorView stopAnimating];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dusupay_checkUrl]]];
//    [webviewPaymentPage loadRequest:request];
    
    NSURL *jsonURL = [NSURL URLWithString:self.dusupay_checkUrl];
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL];
    NSError *error = nil;
    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    NSLog(@"dataDictionary = %@", dataDictionary);
}
- (void)operationResult:(BOOL)success{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [webviewPaymentPage setDelegate:nil];
    [webviewPaymentPage stopLoading];
    [PaymentUtility stopGrayLoadingBar];
//    [activityIndicatorView stopAnimating];
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
- (BOOL)checkURL {
    NSURL *requestURL = [[webviewPaymentPage request] URL];
    NSString *getStringFromUrl = [NSString stringWithFormat:@"%@",requestURL];
    NSLog(@"%@",getStringFromUrl);
    if ([self containsString:getStringFromUrl:self.dusupay_successURL]) {
        [self operationResult:true];
        return NO;
    } else if ([self containsString:getStringFromUrl:self.dusupay_redirectURL]) {
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [getStringFromUrl componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            [queryStringDictionary setObject:value forKey:key];
        }
        NSString* dusupay_transactionReference = [queryStringDictionary objectForKey:@"dusupay_transactionReference"];
        NSString* dusupay_merchantId = self.dusupay_merchantId;
//        Live URL
//    https://dusupay.com/transactions/check_status/param1/param2.json
//        Sandbox URl
//    http://sandbox.dusupay.com/transactions/check_status/param1/param2.json
        
        NSString* statusJsonUrl = [NSString stringWithFormat:@"https://dusupay.com/transactions/check_status/%@/%@.json", dusupay_merchantId, dusupay_transactionReference];
        DusupayConfig* config = [DusupayConfig sharedManager];
        if (config.cIsSandboxMode) {//sandbox
            statusJsonUrl = [NSString stringWithFormat:@"http://sandbox.dusupay.com/transactions/check_status/%@/%@.json", dusupay_merchantId, dusupay_transactionReference];
        }
        
        self.dusupay_checkUrl = statusJsonUrl;
        NSURL *jsonURL = [NSURL URLWithString:self.dusupay_checkUrl];
        NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL];
        NSError *error = nil;
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
//        {
//            "Response":
//            {
//                "dusupay_transactionId":"1151001074",
//                "dusupay_amount":5000,
//                "dusupay_currency":"UGX",
//                "dusupay_itemId":"Item1",
//                "dusupay_transactionReference":"740",
//                "dusupay_charge":0,
//                "dusupay_chargeCurrency":"USD",
//                "dusupay_transactionStatus":"COMPLETE",
//                "status":"success"
//            }
//        }
        if (dataDictionary) {
            if (IS_NOT_NULL(dataDictionary, @"Response")) {
                NSDictionary* responseDict = GET_VALUE_OBJECT(dataDictionary, @"Response");
                if (IS_NOT_NULL(responseDict, @"status")) {
                    NSString* status = GET_VALUE_OBJECT(responseDict, @"status");
                    //                NSString* dusupay_transactionStatus = GET_VALUE_OBJECT(responseDict, @"dusupay_transactionStatus");
                    if ([status isEqualToString:@"success"]) {
                        [self operationResult:true];
                    } else {
                        [self operationResult:false];
                    }
                }
            }
        }
//        [self operationResult:false];
        return NO;
    }
    return YES;
    
//    httpdds://in.yahoo.com/?p=us&dusupay_itemId=Item1&dusupay_transactionReference=32448edb6b8929a2e773
}
- (void)backButtonClicked:(id)sender{
    [self operationResult:false];
}

@end
