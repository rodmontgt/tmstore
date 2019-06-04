//
//  StripePaymentViewController.m
//
//  Created by Alex MacCaw on 2/14/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//
#import "StripePaymentViewController.h"
#import <Stripe/Stripe.h>
#import "TMPaymentSDK.h"


@interface StripePaymentViewController () <STPPaymentCardTextFieldDelegate>
@property (weak, nonatomic) STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation StripePaymentViewController
- (instancetype) init {
    if (self = [super initWithNibName:@"StripePaymentViewController" bundle:nil]) {
        // init stuff for subclass
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    StripeConfig* stripeConfig = [StripeConfig sharedManager];
    self.title = stripeConfig.cTitle;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Setup save button
    NSString *title = [NSString stringWithFormat:@"Pay %@", stripeConfig.infoCurrencyString];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    saveButton.enabled = NO;
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Setup payment view
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
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

- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    self.navigationItem.rightBarButtonItem.enabled = textField.isValid;
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save:(id)sender {
    if (![self.paymentTextField isValid]) {
        return;
    }
    if (![Stripe defaultPublishableKey]) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constants.m"
                                                    }];
        [self stripePaymentViewController:self didFinish:error];
        return;
    }
    [self.activityIndicator startAnimating];
    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.cardParams
                                          completion:^(STPToken *token, NSError *error) {
                                              [self.activityIndicator stopAnimating];
                                              if (error) {
                                                  [self stripePaymentViewController:self didFinish:error];
                                                  return;
                                              }
                                              [self createBackendChargeWithToken:token completion:^(STPBackendChargeResult result, NSError *error) {
                                                  if (error) {
                                                      [self stripePaymentViewController:self didFinish:error];
                                                      return;
                                                  }
                                                  [self stripePaymentViewController:self didFinish:nil];
                                              }];
                                          }];
}
- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    StripeConfig* stripeConfig = [StripeConfig sharedManager];
    NSString* BackendChargeURLString = stripeConfig.cBackendChargeURLString;
    if (!BackendChargeURLString) {
        NSError *error = [NSError
                          errorWithDomain:StripeDomain
                          code:STPInvalidRequestError
                          userInfo:@{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
                                                                 @"instructions in the README to set up an example backend, or use this "
                                                                 @"token to manually create charges at dashboard.stripe.com .",
                                                                 token.tokenId]
                                     }];
        completion(STPBackendChargeResultFailure, error);
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURL *url = [NSURL URLWithString:BackendChargeURLString];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *postBody = [NSString stringWithFormat:@"stripeToken=%@&amount=%@&apikey=%@&currency=%@&description=%@", token.tokenId, [NSNumber numberWithFloat:stripeConfig.infoTotalAmount/* * 100.0f */], stripeConfig.cStripeSecretKey, stripeConfig.infoCurrency, stripeConfig.infoDescription];
    NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response String = %@" ,newStr);
        if (error == nil) {
            if ([newStr isEqualToString:@"SUCCESS"]) {
                completion(STPBackendChargeResultSuccess, nil);
            } else {
                NSError *errorViaResponseData = [NSError errorWithDomain:StripeDomain
                                                     code:STPInvalidRequestError
                                                 userInfo:@{
                                                            NSLocalizedDescriptionKey: newStr
                                                            }];
                completion(STPBackendChargeResultFailure, errorViaResponseData);
            }
        } else {
            completion(STPBackendChargeResultFailure, error);
        }
    }];
    [uploadTask resume];
}
- (void)stripePaymentViewController:(StripePaymentViewController *)controller didFinish:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        [_responseDelegate postCompletionCallbackWithFailure:error];
    } else {
        [_responseDelegate postCompletionCallbackWithSuccess:nil];
    }
}
@end
