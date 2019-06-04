//
//  PaystackViewController.m
//
//  Created by Alex MacCaw on 2/14/13.
//  Copyright (c) 2013 Paystack. All rights reserved.
//
#import "PaystackViewController.h"
#if ENABLE_PAYSTACK
@interface PaystackViewController () <PSTCKPaymentCardTextFieldDelegate>
@property (weak, nonatomic) PSTCKPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation PaystackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    PaystackConfig* paystackConfig = [PaystackConfig sharedManager];
    self.title = paystackConfig.cTitle;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Setup save button
    NSString *title = [NSString stringWithFormat:@"Pay %@", paystackConfig.infoCurrencyString];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    saveButton.enabled = NO;
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Setup payment view
    PSTCKPaymentCardTextField *paymentTextField = [[PSTCKPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    paymentTextField.cursorColor = [UIColor purpleColor];
    self.paymentTextField = paymentTextField;
    [self.view addSubview:paymentTextField];
    
    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat padding = 15;
    CGFloat width = CGRectGetWidth(self.view.frame) - (padding * 2);
    self.paymentTextField.frame = CGRectMake(padding, padding, width, 44);
    
    self.activityIndicator.center = self.view.center;
}

- (void)paymentCardTextFieldDidChange:(nonnull PSTCKPaymentCardTextField *)textField {
    self.navigationItem.rightBarButtonItem.enabled = textField.isValid;
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save:(id)sender {
    if (![self.paymentTextField isValid]) {
        return;
    }
    if (![Paystack defaultPublicKey]) {
        NSError *error = [NSError errorWithDomain:PaystackDomain
                                             code:PSTCKInvalidRequestError
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Please specify a Paystack Publishable Key in Constants.m"
                                                    }];
        [self paystackPaymentViewController:self didFinish:error];
        return;
    }
    [self.activityIndicator startAnimating];
    
    
    PSTCKTransactionParams* transactionParams = [[PSTCKTransactionParams alloc] init];
//    transactionParams.access_code = @"";
    transactionParams.email = @"e@m.ail";
//    transactionParams.reference = @"";
//    transactionParams.subaccount = @"";
//    transactionParams.bearer = @"";
//    transactionParams.metadata = @"";
//    transactionParams.plan = @"";
    transactionParams.currency = @"NGN";
    transactionParams.amount =  1.0f * 100.0f;
//    transactionParams.transaction_charge = 0.0f;

    
    
    
    [[PSTCKAPIClient sharedClient] chargeCard:self.paymentTextField.cardParams forTransaction:transactionParams onViewController:self didEndWithError:^(NSError * _Nonnull error, NSString * _Nullable reference) {
//        [self handleError:error];
        // handle error here
    } didRequestValidation:^(NSString * _Nonnull reference) {
        // an OTP was requested, transaction has not yet succeeded
    } didTransactionSuccess:^(NSString * _Nonnull reference) {
        // transaction may have succeeded, please verify on backend
    }];
    
//    [[PSTCKAPIClient sharedClient] createTokenWithCard:self.paymentTextField.cardParams completion:^(PSTCKToken *token, NSError *error) {
//                                              [self.activityIndicator stopAnimating];
//                                              if (error) {
//                                                  [self paystackPaymentViewController:self didFinish:error];
//                                                  return;
//                                              }
//                                              [self createBackendChargeWithToken:token completion:^(PSTCKBackendChargeResult result, NSError *error) {
//                                                  if (error) {
//                                                      [self paystackPaymentViewController:self didFinish:error];
//                                                      return;
//                                                  }
//                                                  [self paystackPaymentViewController:self didFinish:nil];
//                                              }];
//                                          }];
}
- (void)createBackendChargeWithToken:(PSTCKToken *)token completion:(PSTCKTokenSubmissionHandler)completion {
    PaystackConfig* paystackConfig = [PaystackConfig sharedManager];
    NSString* BackendChargeURLString = paystackConfig.cBackendChargeURLString;
    if (!BackendChargeURLString) {
        NSError *error = [NSError
                          errorWithDomain:PaystackDomain
                          code:PSTCKInvalidRequestError
                          userInfo:@{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news! Paystack turned your credit card into a token: %@ \nYou can follow the "
                                                                 @"instructions in the README to set up an example backend, or use this "
                                                                 @"token to manually create charges at dashboard.paystack.com .",
                                                                 token.tokenId]
                                     }];
        completion(PSTCKBackendChargeResultFailure, error);
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your Paystack account's secret key
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURL *url = [NSURL URLWithString:BackendChargeURLString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *postBody = [NSString stringWithFormat:@"paystackToken=%@&amount=%@&apikey=%@&currency=%@&description=%@", token.tokenId, [NSNumber numberWithFloat:paystackConfig.infoTotalAmount/* * 100.0f */], paystackConfig.cPaystackSecretKey, paystackConfig.infoCurrency, paystackConfig.infoDescription];
    NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response String = %@" ,newStr);
        if (error == nil) {
            if ([newStr isEqualToString:@"SUCCESS"]) {
                completion(PSTCKBackendChargeResultSuccess, nil);
            } else {
                NSError *errorViaResponseData = [NSError errorWithDomain:PaystackDomain
                                                                    code:PSTCKInvalidRequestError
                                                                userInfo:@{
                                                                           NSLocalizedDescriptionKey: newStr
                                                                           }];
                completion(PSTCKBackendChargeResultFailure, errorViaResponseData);
            }
        } else {
            completion(PSTCKBackendChargeResultFailure, error);
        }
    }];
    [uploadTask resume];
}
- (void)paystackPaymentViewController:(PaystackViewController *)controller didFinish:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        [_responseDelegate postCompletionCallbackWithFailure:error];
    } else {
        [_responseDelegate postCompletionCallbackWithSuccess:nil];
    }
}
@end
#else
@implementation PaystackViewController
@end
#endif
